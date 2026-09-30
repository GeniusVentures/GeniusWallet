import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_customer_id.dart';
import 'package:genius_wallet/banxa/banxa_helpers/buy_defaults.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_state.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

const String _disclaimerKey = 'banxaDisclaimerAccepted';

/// The order Banxa just created. It leaves the cubit once, on a stream, so
/// the id and checkout URL never sit in state.
class BuyOrderStarted {
  const BuyOrderStarted(this.orderId, this.checkoutUrl);

  final String orderId;
  final String checkoutUrl;
}

class BuyGnusCubit extends Cubit<BuyGnusState> {
  BuyGnusCubit(
    BanxaApiService api, {
    this.quoteInterval = const Duration(seconds: 10),
    this.typingDelay = const Duration(milliseconds: 600),
    bool Function()? readDisclaimerAccepted,
    Future<void> Function()? saveDisclaimerAccepted,
  }) : _api = api,
       _readDisclaimer =
           readDisclaimerAccepted ??
           (() => Hive.box(preferencesBoxName).get(_disclaimerKey) == true),
       _saveDisclaimer =
           saveDisclaimerAccepted ??
           (() => Hive.box(preferencesBoxName).put(_disclaimerKey, true)),
       super(BuyGnusState(isSandbox: api.isSandbox));

  static const String createFailedMessage =
      "Couldn't start your order. Try again.";

  final BanxaApiService _api;
  final Duration quoteInterval;
  final Duration typingDelay;
  final bool Function() _readDisclaimer;
  final Future<void> Function() _saveDisclaimer;

  final StreamController<BuyOrderStarted> _started =
      StreamController<BuyOrderStarted>.broadcast();

  Timer? _refreshTimer;
  Timer? _typingTimer;
  bool _paused = false;
  // Bumped whenever the inputs change or quoting stops, so an answer for
  // older inputs is dropped instead of overwriting newer numbers.
  int _generation = 0;

  Stream<BuyOrderStarted> get orderStarted => _started.stream;

  Future<void> load({
    String? localeName,
    String? initialFiat,
    String? initialAmount,
  }) async {
    emit(
      state.copyWith(
        availability: BuyAvailability.loading,
        disclaimerAccepted: _readDisclaimer(),
      ),
    );
    if (!_api.isConfigured) {
      emit(state.copyWith(availability: BuyAvailability.notConfigured));
      return;
    }
    final List<FiatCurrency> fiats;
    final List<CryptoCurrency> cryptos;
    try {
      fiats = (await _api.getFiatCurrencies())
          .where((f) => f.supportedPaymentMethods.isNotEmpty)
          .toList();
      cryptos = await _api.getCryptoCurrencies();
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(availability: BuyAvailability.loadFailed));
      }
      return;
    }
    if (isClosed) {
      return;
    }
    final gnus = cryptos
        .where((c) => c.code.toUpperCase() == 'GNUS')
        .firstOrNull;
    if (gnus == null) {
      emit(state.copyWith(availability: BuyAvailability.notListed));
      return;
    }
    if (fiats.isEmpty) {
      emit(state.copyWith(availability: BuyAvailability.loadFailed));
      return;
    }
    final codes = fiats.map((f) => f.code).toList();
    final wanted = initialFiat != null && codes.contains(initialFiat)
        ? initialFiat
        : defaultFiatCode(localeName ?? Platform.localeName, codes);
    final fiat = fiats.firstWhere(
      (f) => f.code == wanted,
      orElse: () => fiats.first,
    );
    final method = fiat.supportedPaymentMethods.first;
    emit(
      state.copyWith(
        availability: BuyAvailability.ready,
        fiats: fiats,
        gnus: gnus,
        fiat: fiat,
        method: method,
        amountText: initialAmount ?? _defaultAmount(method),
      ),
    );
    unawaited(_fetch());
  }

  void selectFiat(FiatCurrency fiat) {
    if (fiat.supportedPaymentMethods.isEmpty) {
      return;
    }
    final method = fiat.supportedPaymentMethods.first;
    emit(
      state.copyWith(
        fiat: fiat,
        method: method,
        amountText: _defaultAmount(method),
      ),
    );
    _requote(immediate: true);
  }

  void selectMethod(PaymentMethod method) {
    emit(state.copyWith(method: method));
    _requote(immediate: true);
  }

  void setAmountText(String text) {
    emit(state.copyWith(amountText: text));
    _requote(immediate: false);
  }

  Future<void> refreshQuote() async {
    if (_paused) {
      return;
    }
    _cancelTimers();
    await _fetch();
  }

  void pause() {
    _paused = true;
    _cancelTimers();
    _generation++;
    if (state.quoting) {
      emit(state.copyWith(quoting: false));
    }
  }

  void resume() {
    if (!_paused) {
      return;
    }
    _paused = false;
    unawaited(_fetch());
  }

  Future<void> acceptDisclaimer() async {
    await _saveDisclaimer();
    if (!isClosed) {
      emit(state.copyWith(disclaimerAccepted: true));
    }
  }

  /// The address is read from [wallet] now, at the tap, so switching wallets
  /// after the quote still sends the new wallet's address.
  Future<void> createOrder(Wallet? wallet) async {
    final quote = state.quote;
    final fiat = state.fiat;
    final method = state.method;
    final gnus = state.gnus;
    final chain = gnus?.defaultBlockchain;
    if (wallet == null ||
        wallet.walletType == WalletType.tracking ||
        !isEvmAddress(wallet.address) ||
        state.availability != BuyAvailability.ready ||
        state.creating ||
        quote == null ||
        fiat == null ||
        method == null ||
        gnus == null ||
        chain == null) {
      return;
    }
    _cancelTimers();
    _generation++;
    emit(state.copyWith(creating: true, quoting: false, errorMessage: ''));
    try {
      final order = await _api.createBuyOrder(
        fiatCurrency: fiat.code,
        cryptoCurrency: gnus.code,
        blockchain: chain.id,
        paymentMethodId: method.id,
        walletAddress: wallet.address.trim(),
        cryptoAmount: quote.cryptoAmount,
        fiatAmount: quote.fiatAmount,
        externalCustomerId: banxaCustomerId(wallet.address),
        metadata: 'real',
        subPartnerId: 'macOS-app',
      );
      if (order.orderId.isEmpty || order.checkoutUrl.isEmpty) {
        throw const FormatException('empty order');
      }
      if (isClosed) {
        return;
      }
      emit(state.copyWith(creating: false));
      _started.add(BuyOrderStarted(order.orderId, order.checkoutUrl));
    } catch (_) {
      // The exception text can echo request data, so only a fixed line shows.
      if (isClosed) {
        return;
      }
      emit(state.copyWith(creating: false, errorMessage: createFailedMessage));
      _scheduleRefresh();
    }
  }

  String _defaultAmount(PaymentMethod method) {
    final p = presetAmounts(min: method.minimum, max: method.maximum);
    if (p.isEmpty) {
      return '';
    }
    return p[p.length > 1 ? 1 : 0].toString();
  }

  void _cancelTimers() {
    _refreshTimer?.cancel();
    _typingTimer?.cancel();
    _refreshTimer = null;
    _typingTimer = null;
  }

  // The inputs changed, so the old numbers describe something else: drop them.
  void _requote({required bool immediate}) {
    if (state.availability != BuyAvailability.ready) {
      return;
    }
    _cancelTimers();
    _generation++;
    final valid = state.amountInRange && state.method != null;
    emit(
      state.copyWith(
        clearQuote: true,
        quoting: valid && !_paused,
        quoteStale: false,
        errorMessage: '',
      ),
    );
    if (!valid || _paused) {
      return;
    }
    if (immediate) {
      unawaited(_fetch());
    } else {
      _typingTimer = Timer(typingDelay, _fetch);
    }
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    if (_paused || isClosed || !state.amountInRange) {
      return;
    }
    _refreshTimer = Timer(quoteInterval, _fetch);
  }

  Future<void> _fetch() async {
    final fiat = state.fiat;
    final method = state.method;
    final gnus = state.gnus;
    if (isClosed ||
        _paused ||
        state.availability != BuyAvailability.ready ||
        fiat == null ||
        method == null ||
        gnus == null ||
        !state.amountInRange) {
      return;
    }
    final generation = ++_generation;
    emit(state.copyWith(quoting: true));
    try {
      final quote = await _api.getQuote(
        paymentMethodId: method.id,
        crypto: gnus.code,
        blockchain: gnus.defaultBlockchain?.id ?? '',
        fiat: fiat.code,
        fiatAmount: state.amountText.trim(),
      );
      if (isClosed || generation != _generation) {
        return;
      }
      emit(
        state.copyWith(
          quote: quote,
          quoting: false,
          quoteStale: false,
          quoteFetchedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      if (isClosed || generation != _generation) {
        return;
      }
      emit(state.copyWith(quoting: false, quoteStale: true));
    }
    _scheduleRefresh();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    unawaited(_started.close());
    return super.close();
  }
}
