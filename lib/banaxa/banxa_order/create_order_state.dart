import 'package:genius_wallet/banaxa/banaxa_model.dart';

enum MakeOrderStep {
  initial,
  loadingCurrencies,
  currenciesLoaded,
  selecting,
  gettingQuote,
  quoteReady,
  creatingOrder,
  orderReady,
  error,
}

class MakeOrderState {
  final MakeOrderStep step;
  final List<FiatCurrency> fiats;
  final List<CryptoCurrency> cryptos;
  final List<PaymentMethod> paymentMethods;
  final FiatCurrency? selectedFiat;
  final CryptoCurrency? selectedCrypto;
  final PaymentMethod? selectedPaymentMethod;
  final String amountText;
  final String walletText;
  final Quote? quote;
  final bool isLoadingOverlay;
  final String loadingMessage;
  final String errorMessage;
  final String? checkoutUrl;
  final String? redirectUrl;
  final String? orderId; 

  const MakeOrderState({
    required this.step,
    required this.fiats,
    required this.cryptos,
    required this.paymentMethods,
    required this.selectedFiat,
    required this.selectedCrypto,
    required this.selectedPaymentMethod,
    required this.amountText,
    required this.walletText,
    required this.quote,
    required this.isLoadingOverlay,
    required this.loadingMessage,
    required this.errorMessage,
    required this.checkoutUrl,
    required this.redirectUrl,
    this.orderId,
  });

  factory MakeOrderState.initial() => const MakeOrderState(
        step: MakeOrderStep.initial,
        fiats: [],
        cryptos: [],
        paymentMethods: [],
        selectedFiat: null,
        selectedCrypto: null,
        selectedPaymentMethod: null,
        amountText: '',
        walletText: '',
        quote: null,
        isLoadingOverlay: false,
        loadingMessage: '',
        errorMessage: '',
        checkoutUrl: null,
        redirectUrl: null,
        orderId: null,
      );

  MakeOrderState copyWith({
    MakeOrderStep? step,
    List<FiatCurrency>? fiats,
    List<CryptoCurrency>? cryptos,
    List<PaymentMethod>? paymentMethods,
    FiatCurrency? selectedFiat,
    CryptoCurrency? selectedCrypto,
    PaymentMethod? selectedPaymentMethod,
    String? amountText,
    String? walletText,
    Quote? quote,
    bool? isLoadingOverlay,
    String? loadingMessage,
    String? errorMessage,
    String? checkoutUrl,
    String? redirectUrl,
    bool clearSelectedFiat = false,
    bool clearSelectedCrypto = false,
    bool clearSelectedPaymentMethod = false,
    bool clearQuote = false,
    bool clearError = false,
    bool clearCheckout = false,
    String? orderId,
     bool clearOrderId = false,
    bool clearRedirectUrl = false, 
  }) {
    return MakeOrderState(
      step: step ?? this.step,
      fiats: fiats ?? this.fiats,
      cryptos: cryptos ?? this.cryptos,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedFiat:
          clearSelectedFiat ? null : (selectedFiat ?? this.selectedFiat),
      selectedCrypto:
          clearSelectedCrypto ? null : (selectedCrypto ?? this.selectedCrypto),
      selectedPaymentMethod: clearSelectedPaymentMethod
          ? null
          : (selectedPaymentMethod ?? this.selectedPaymentMethod),
      amountText: amountText ?? this.amountText,
      walletText: walletText ?? this.walletText,
      quote: clearQuote ? null : (quote ?? this.quote),
      isLoadingOverlay: isLoadingOverlay ?? this.isLoadingOverlay,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      checkoutUrl: clearCheckout ? null : (checkoutUrl ?? this.checkoutUrl),
      redirectUrl: clearRedirectUrl ? null : (redirectUrl ?? this.redirectUrl),
      orderId: clearOrderId ? null : (orderId ?? this.orderId),
    );
  }

  double? get amountValue {
    final v = double.tryParse(amountText.trim());
    return (v == null || v.isNaN || v.isInfinite) ? null : v;
    
  }
   bool get hasOrder => (orderId != null && orderId!.isNotEmpty);

  num? get minAmount => selectedPaymentMethod?.minimum;
  num? get maxAmount => selectedPaymentMethod?.maximum;
  bool get hasSelections =>
      selectedFiat != null &&
      selectedCrypto != null &&
      selectedPaymentMethod != null;

  bool get isAmountWithinRange {
    final amt = amountValue;
    if (amt == null) return false;
    final min = minAmount;
    final max = maxAmount;
    if (min != null && amt < min) return false;
    if (max != null && amt > max) return false;
    return true;
  }

  bool get canGetQuote => hasSelections && isAmountWithinRange;
  bool get hasQuote => quote != null;
  bool get canCreateOrder =>
      hasQuote &&
      (walletText.trim().isNotEmpty) &&
      selectedCrypto?.defaultBlockchain != null;
  bool get showOverlay => isLoadingOverlay;
  String get fiatCode => selectedFiat?.code ?? '';
  String get cryptoCode => selectedCrypto?.code ?? '';
  String get paymentMethodName => selectedPaymentMethod?.name ?? '';


}
