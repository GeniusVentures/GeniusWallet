import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_customer_id.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/dev/dev_banxa_fixtures.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

bool _always() => true;

class OrdersCubit extends Cubit<OrdersState> {
  /// [walletDetailsCubit] supplies the wallet whose orders these are. Same
  /// cross-cubit shape `AppBloc` already uses in `main.dart`, and it is what
  /// keeps the screens out of it: a widget reaching for a second cubit just to
  /// name a customer would break AGENTS.md's "widgets do not reach past the
  /// repository layer".
  ///
  /// Nullable so a test can construct a bare cubit; a null one simply has no
  /// wallet and fetches nothing, which is the honest answer.
  ///
  /// Follows the selected wallet: a switch clears the list and refetches.
  OrdersCubit({
    WalletDetailsCubit? walletDetailsCubit,
    required BanxaApiService api,
    this.pollInterval = const Duration(seconds: 15),
    DateTime Function() now = DateTime.now,
    bool Function() hasBuyHistory = _always,
  }) : _walletDetailsCubit = walletDetailsCubit,
       _api = api,
       _now = now,
       _hasBuyHistory = hasBuyHistory,
       super(OrdersState.initial()) {
    _customerKey = _customerId;
    _walletSubscription = _walletDetailsCubit?.stream.listen(_onWalletState);
    if (_customerKey != null) {
      unawaited(fetchOrders());
    }
  }

  final WalletDetailsCubit? _walletDetailsCubit;
  final BanxaApiService _api;
  final DateTime Function() _now;
  // The wallet address only goes to Banxa once the user has a Banxa
  // relationship, never just because the app started.
  final bool Function() _hasBuyHistory;
  StreamSubscription<WalletDetailsState>? _walletSubscription;
  String? _customerKey;

  final Duration pollInterval;
  Timer? _pollTimer;
  bool _polling = false;
  bool _foreground = true;

  // Banxa can revive an expired order on a late payment, so it stays in the
  // open set for this long after its last update.
  static const Duration _expiredGrace = Duration(minutes: 60);

  /// Bumped by every fetch; only the newest fetch's result may land, so a slow
  /// response for wallet A can never appear under wallet B.
  int _fetchGeneration = 0;

  // Orders this session added by id. A list fetch that began before they
  // existed must not erase them.
  final Set<String> _trackedIds = {};

  void _onWalletState(WalletDetailsState _) {
    final key = _customerId;
    if (key == _customerKey) {
      return;
    }
    _customerKey = key;
    _trackedIds.clear();
    emit(OrdersState.initial());
    _syncTimer();
    unawaited(fetchOrders());
  }

  /// The Banxa customer key for the selected wallet, or null when no wallet is
  /// selected. See `banxa_customer_id.dart` for why this is derived rather
  /// than passed in by each caller.
  String? get _customerId =>
      banxaCustomerId(_walletDetailsCubit?.state.selectedWallet?.address);

  Future<void> fetchOrders() async {
    final generation = ++_fetchGeneration;
    final externalCustomerId = _customerId;
    emit(state.copyWith(status: OrdersStatus.loading, error: ''));

    // DEV-ONLY seam. Double-gated: `kDebugMode` is a const so this whole
    // branch is tree-shaken out of profile and release builds, and
    // `kShowDevTools` means even a debug build without
    // `--dart-define=GW_DEV_TOOLS=true` never reads it. Same shape as the
    // dashboard's markets-fault seam.
    //
    // Exists because the Banxa order surfaces are otherwise unreachable
    // without a live sandbox round trip (KYC + payment method + real order),
    // which left six of Phase 9's ten re-skinned surfaces unwalkable. See
    // lib/dev/dev_banxa_fixtures.dart.
    if (kDebugMode && kShowDevTools) {
      final override = DevBanxaFixtures.instance.orders.value;
      if (override != null) {
        switch (override) {
          case DevBanxaOrders.seeded:
            final seeded = DevBanxaFixtures.seededOrders();
            emit(state.copyWith(status: OrdersStatus.success, orders: seeded));
            return;
          case DevBanxaOrders.empty:
            final none = OrdersResponse(orders: [], total: 0, pageTotal: 0);
            emit(state.copyWith(status: OrdersStatus.success, orders: none));
            return;
          case DevBanxaOrders.error:
            emit(
              state.copyWith(
                status: OrdersStatus.error,
                error:
                    'DEV-ONLY: injected by dev_banxa_fixtures.dart (armed via '
                    'the dev-tools bubble BANXA section) — not a real '
                    'orders-load failure.',
              ),
            );
            return;
        }
      }
    }

    if (externalCustomerId == null || !_api.isConfigured || !_hasBuyHistory()) {
      emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: OrdersResponse(orders: const [], total: 0, pageTotal: 0),
        ),
      );
      return;
    }

    final now = DateTime.now().toUtc();
    final oneMonthAgo = now.subtract(const Duration(days: 120));

    try {
      final orders = await _api.fetchAllOrders(
        startDateUtc: oneMonthAgo.toIso8601String(),
        endDateUtc: now.toIso8601String(),
        externalCustomerId: externalCustomerId,
        status: '',
      );
      if (generation != _fetchGeneration || isClosed) {
        return;
      }

      final fetchedIds = {for (final o in orders.orders) o.id};
      final kept = [
        for (final o in state.orders?.orders ?? const <Order>[])
          if (_trackedIds.contains(o.id) && !fetchedIds.contains(o.id)) o,
      ];
      emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: kept.isEmpty
              ? orders
              : OrdersResponse(
                  orders: [...kept, ...orders.orders],
                  total: orders.total + kept.length,
                  pageTotal: orders.pageTotal,
                ),
        ),
      );
      _syncTimer();
    } catch (e) {
      if (generation != _fetchGeneration || isClosed) {
        return;
      }
      emit(state.copyWith(status: OrdersStatus.error, error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _walletSubscription?.cancel();
    return super.close();
  }

  bool _isOpen(Order order) {
    final status = order.banxaStatus;
    if (!status.isFinal) {
      return true;
    }
    // ponytail: a fixed window; Banxa webhooks would replace polling for this.
    return status == BanxaOrderStatus.expired &&
        _now().difference(order.updatedAt) < _expiredGrace;
  }

  // A tracked order whose first read failed is not in the list yet, but it
  // still has to be polled or nothing would ever retry it.
  List<String> _openIds() {
    final orders = state.orders?.orders ?? const <Order>[];
    final known = {for (final order in orders) order.id};
    return [
      for (final order in orders)
        if (_isOpen(order)) order.id,
      for (final id in _trackedIds)
        if (!known.contains(id)) id,
    ];
  }

  void _syncTimer() {
    if (isClosed || !_foreground || _openIds().isEmpty) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    _pollTimer ??= Timer.periodic(pollInterval, (_) => unawaited(_poll()));
  }

  /// The app going to the background stops the polling; coming back reads
  /// every open order at once.
  void setForeground(bool foreground) {
    if (foreground == _foreground) {
      return;
    }
    _foreground = foreground;
    _syncTimer();
    if (foreground && _pollTimer != null) {
      unawaited(_poll());
    }
  }

  /// Reads [orderId], puts it first and keeps it current from now on.
  Future<void> track(String orderId) {
    _trackedIds.add(orderId);
    return _readOrder(orderId, toFront: true);
  }

  /// Reads [orderId] once, now.
  Future<void> refreshOrder(String orderId) => _readOrder(orderId);

  Future<void> _poll() async {
    if (_polling || isClosed) {
      return;
    }
    _polling = true;
    final generation = _fetchGeneration;
    try {
      for (final id in _openIds()) {
        if (generation != _fetchGeneration || isClosed) {
          return;
        }
        await _readOrder(id, generation: generation);
      }
    } finally {
      _polling = false;
    }
    _syncTimer();
  }

  Future<void> _readOrder(
    String orderId, {
    bool toFront = false,
    int? generation,
  }) async {
    final startedFor = _customerKey;
    final Order fresh;
    try {
      fresh = await _api.getOrderById(orderId);
    } catch (_) {
      // The old row stays; the next tick tries again.
      _syncTimer();
      return;
    }
    // A poll tick yields to any newer list fetch; a single read only to a
    // wallet switch.
    final superseded = generation != null
        ? generation != _fetchGeneration
        : startedFor != _customerKey;
    if (superseded || isClosed) {
      return;
    }
    _merge(fresh, toFront: toFront);
    _syncTimer();
  }

  void _merge(Order fresh, {required bool toFront}) {
    final current = state.orders?.orders ?? const <Order>[];
    final before = current.where((o) => o.id == fresh.id).firstOrNull;
    if (before != null &&
        !toFront &&
        before.status == fresh.status &&
        before.updatedAt == fresh.updatedAt) {
      return;
    }
    // A tracked order can be final on its very first read when that read
    // failed earlier; it was still started in this session, so it is news.
    final turnedFinal =
        fresh.banxaStatus.isFinal &&
        (before == null
            ? _trackedIds.contains(fresh.id)
            : before.banxaStatus != fresh.banxaStatus);

    List<Order> put(List<Order> list) {
      final index = list.indexWhere((o) => o.id == fresh.id);
      if (index < 0 || toFront) {
        return [fresh, ...list.where((o) => o.id != fresh.id)];
      }
      return [...list]..[index] = fresh;
    }

    final orders = put(current);
    emit(
      state.copyWith(
        orders: OrdersResponse(
          orders: orders,
          total: before == null
              ? (state.orders?.total ?? 0) + 1
              : state.orders!.total,
          pageTotal: state.orders?.pageTotal ?? 1,
        ),
        justFinished: turnedFinal ? [fresh] : const [],
      ),
    );
  }
}
