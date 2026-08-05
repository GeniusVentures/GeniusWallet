import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_customer_id.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/dev/dev_banxa_fixtures.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class OrdersCubit extends Cubit<OrdersState> {
  /// [walletDetailsCubit] supplies the wallet whose orders these are. Same
  /// cross-cubit shape `AppBloc` already uses in `main.dart`, and it is what
  /// keeps the screens out of it: a widget reaching for a second cubit just to
  /// name a customer would break AGENTS.md's "widgets do not reach past the
  /// repository layer".
  ///
  /// Nullable so a test can construct a bare cubit; a null one simply has no
  /// wallet and fetches nothing, which is the honest answer.
  OrdersCubit({WalletDetailsCubit? walletDetailsCubit})
    : _walletDetailsCubit = walletDetailsCubit,
      super(OrdersState.initial());

  final WalletDetailsCubit? _walletDetailsCubit;

  /// The Banxa customer key for the selected wallet, or null when no wallet is
  /// selected. See `banxa_customer_id.dart` for why this is derived rather
  /// than passed in by each caller.
  String? get _customerId =>
      banxaCustomerId(_walletDetailsCubit?.state.selectedWallet?.address);

  /// [externalCustomerIdOverride] exists for the dev fixtures only; production
  /// call sites pass nothing and get the selected wallet's key.
  Future<void> fetchOrders([String? externalCustomerIdOverride]) async {
    final externalCustomerId = externalCustomerIdOverride ?? _customerId;
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
            emit(
              state.copyWith(
                status: OrdersStatus.success,
                orders: seeded,
                filteredOrders: seeded.orders,
              ),
            );
            return;
          case DevBanxaOrders.empty:
            final none = OrdersResponse(orders: [], total: 0, pageTotal: 0);
            emit(
              state.copyWith(
                status: OrdersStatus.success,
                orders: none,
                filteredOrders: const [],
              ),
            );
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

    final now = DateTime.now().toUtc();
    final oneMonthAgo = now.subtract(const Duration(days: 120));

    try {
      final orders = await BanxaApiService().fetchAllOrders(
        startDateUtc: oneMonthAgo.toIso8601String(),
        endDateUtc: now.toIso8601String(),
        externalCustomerId: externalCustomerId,
        status: '',
      );

      emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: orders,
          filteredOrders: orders.orders,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.error, error: e.toString()));
    }
  }

  void applyFilters({String? status, DateTime? startDate, DateTime? endDate}) {
    if (state.orders == null) {
      return;
    }

    List<Order> filtered = state.orders!.orders;

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((o) => o.status == status).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((o) => o.createdAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((o) => o.createdAt.isBefore(endDate)).toList();
    }

    emit(state.copyWith(filteredOrders: filtered));
  }
}
