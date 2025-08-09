import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:genius_wallet/banxa_order/create_order_state.dart';

class MakeOrderCubit extends Cubit<MakeOrderState> {
  final BanxaApiService _service;

  MakeOrderCubit(this._service) : super(MakeOrderState.initial());

  Future<void> loadCurrencies({
    String? initialFiatCode,
    String? initialCryptoCode,
    String? initialPaymentMethodId,
    String? initialAmount,
    String? initialWalletAddress,
  }) async {
    emit(state.copyWith(
      step: MakeOrderStep.loadingCurrencies,
      isLoadingOverlay: true,
      loadingMessage: 'Loading currencies...',
      clearError: true,
      clearCheckout: true,
    ));
    try {
      final fiats = await _service.getFiatCurrencies();
      final cryptos = await _service.getCryptoCurrencies();

      FiatCurrency? selFiat = initialFiatCode == null
          ? null
          : fiats
              .where((f) => f.code == initialFiatCode)
              .cast<FiatCurrency?>()
              .firstOrNull;
      CryptoCurrency? selCrypto = initialCryptoCode == null
          ? null
          : cryptos
              .where((c) => c.code == initialCryptoCode)
              .cast<CryptoCurrency?>()
              .firstOrNull;

      List<PaymentMethod> methods = selFiat?.supportedPaymentMethods ?? [];
      PaymentMethod? selMethod;
      if (initialPaymentMethodId != null && methods.isNotEmpty) {
        selMethod = methods
                .where((m) => m.id == initialPaymentMethodId)
                .cast<PaymentMethod?>()
                .firstOrNull ??
            methods.first;
      }

      emit(state.copyWith(
        step: MakeOrderStep.currenciesLoaded,
        fiats: fiats,
        cryptos: cryptos,
        selectedFiat: selFiat,
        selectedCrypto: selCrypto,
        paymentMethods: methods,
        selectedPaymentMethod: selMethod,
        amountText: initialAmount ?? state.amountText,
        walletText: initialWalletAddress ?? state.walletText,
        isLoadingOverlay: false,
        loadingMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        step: MakeOrderStep.error,
        isLoadingOverlay: false,
        loadingMessage: '',
        errorMessage: 'Failed to load currencies: $e',
      ));
    }
  }

  void selectFiat(FiatCurrency fiat) {
    emit(state.copyWith(
      step: MakeOrderStep.selecting,
      selectedFiat: fiat,
      paymentMethods: fiat.supportedPaymentMethods,
      clearSelectedPaymentMethod: true,
      clearQuote: true,
      clearError: true,
      clearCheckout: true,
    ));
  }

  void selectCrypto(CryptoCurrency crypto) {
    emit(state.copyWith(
      step: MakeOrderStep.selecting,
      selectedCrypto: crypto,
      clearQuote: true,
      clearError: true,
      clearCheckout: true,
    ));
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(
      step: MakeOrderStep.selecting,
      selectedPaymentMethod: method,
      clearQuote: true,
      clearError: true,
      clearCheckout: true,
    ));
  }

  void setAmountText(String v) {
    emit(state.copyWith(
      amountText: v,
      clearQuote: true,
      clearError: true,
      clearCheckout: true,
    ));
  }

  void setWalletText(String v) {
    emit(state.copyWith(
      walletText: v,
      clearError: true,
    ));
  }

  Future<Quote?> getQuote() async {
    if (!state.canGetQuote) {
      emit(state.copyWith(
        step: MakeOrderStep.error,
        errorMessage:
            'Please select fiat, crypto, method and enter a valid amount.',
      ));
      return null;
    }

    emit(state.copyWith(
      step: MakeOrderStep.gettingQuote,
      isLoadingOverlay: true,
      loadingMessage: 'Fetching quote...',
      clearError: true,
      clearCheckout: true,
    ));

    try {
      final quote = await _service.getQuote(
        orderType: 'buy',
        paymentMethodId: state.selectedPaymentMethod!.id,
        crypto: state.selectedCrypto!.code,
        blockchain: state.selectedCrypto!.defaultBlockchain?.id ?? '',
        fiat: state.selectedFiat!.code,
        fiatAmount: state.amountValue!.toString(),
      );

      emit(state.copyWith(
        step: MakeOrderStep.quoteReady,
        quote: quote,
        isLoadingOverlay: false,
        loadingMessage: '',
      ));
      return quote;
    } catch (e) {
      emit(state.copyWith(
        step: MakeOrderStep.error,
        isLoadingOverlay: false,
        loadingMessage: '',
        errorMessage: 'Could not fetch quote: $e',
      ));
      return null;
    }
  }

  Future<String?> createOrder() async {
    if (!state.canCreateOrder) {
      emit(state.copyWith(
        step: MakeOrderStep.error,
        errorMessage: 'Missing data to create order.',
      ));
      return null;
    }

    emit(state.copyWith(
      step: MakeOrderStep.creatingOrder,
      isLoadingOverlay: true,
      loadingMessage: 'Creating order...',
      clearError: true,
      clearCheckout: true,
    ));

    try {
      const redirectUrl = 'yourapp://banxa-callback';

      final order = await _service.createBuyOrder(
        fiatCurrency: state.selectedFiat!.code,
        cryptoCurrency: state.selectedCrypto!.code,
        blockchain: state.selectedCrypto!.defaultBlockchain!.id,
        paymentMethodId: state.selectedPaymentMethod!.id,
        walletAddress: state.walletText.trim(),
        redirectUrl: redirectUrl,
        cryptoAmount: state.quote!.cryptoAmount,
        fiatAmount: state.quote!.fiatAmount,
        externalCustomerId: 'your-cust-id',
        externalOrderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        email: 'banxa@text.com',
        metadata: 'sandbox-testing',
        subPartnerId: 'macOS-app',
      );

      emit(state.copyWith(
        step: MakeOrderStep.orderReady,
        checkoutUrl: order.checkoutUrl,
        redirectUrl: redirectUrl,
        isLoadingOverlay: false,
        loadingMessage: '',
      ));
      return order.checkoutUrl;
    } catch (e) {
      emit(state.copyWith(
        step: MakeOrderStep.error,
        isLoadingOverlay: false,
        loadingMessage: '',
        errorMessage: 'Failed to create order: $e',
      ));
      return null;
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void clearCheckout() {
    emit(state.copyWith(clearCheckout: true));
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
