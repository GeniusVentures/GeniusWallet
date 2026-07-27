import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';

/// Fixture FACTORY FUNCTIONS for Phase 9's `test/banxa/` suite (09-01-PLAN.md
/// Task 1). Mirrors `test/squid_router/route_details_card_test.dart:15-25`'s
/// `_token()` idiom — a top-level function, not a class.
///
/// This is fixture CONSTRUCTION only: it reads `banxa_model.dart` and
/// `create_order_state.dart` and never modifies either (09-CONTEXT.md D-06).
/// Dates are fixed `DateTime.utc(...)` values, never the current wall-clock
/// time, so date-formatted assertions never drift between runs.
Order testOrder({
  String status = 'completed',
  String id = 'ord_0001',
  String fiat = 'USD',
  String fiatAmount = '100.00',
  String cryptoAmount = '0.0025',
  String cryptoId = 'BTC',
  String paymentMethodName = 'Credit Card',
  String walletAddress = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Order(
    id: id,
    externalId: 'ext_$id',
    externalCustomerId: 'cust_0001',
    orderStatusUrl: 'https://banxa-sandbox.com/orders/$id',
    orderType: 'CRYPTO-BUY',
    crypto: Crypto(id: cryptoId, blockchain: cryptoId, network: 'mainnet'),
    fiat: fiat,
    fiatAmount: fiatAmount,
    cryptoAmount: cryptoAmount,
    paymentMethodId: 'pm_0001',
    paymentMethodName: paymentMethodName,
    processingFee: '2.50',
    networkFee: '1.00',
    walletAddress: walletAddress,
    status: status,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1, 12),
    updatedAt: updatedAt ?? DateTime.utc(2026, 1, 1, 13),
  );
}

/// A `MakeOrderState` carrying a `Quote` plus the selected `FiatCurrency` and
/// `CryptoCurrency` needed for `fiatCode`/`cryptoCode` to resolve, so
/// 09-03's `QuoteCard` test can assert `hasQuote == true` without a cubit or
/// the network (09-CONTEXT.md D-03).
MakeOrderState testQuoteState({
  String cryptoAmount = '0.0025',
  String processingFee = '2.50',
  String networkFee = '1.00',
  String fiatCode = 'USD',
  String cryptoCode = 'BTC',
}) {
  final fiat = FiatCurrency(
    code: fiatCode,
    name: 'US Dollar',
    symbol: '\$',
    supportedPaymentMethods: const [],
  );
  final crypto = CryptoCurrency(
    code: cryptoCode,
    name: 'Bitcoin',
    blockchains: [
      Blockchain(
        id: cryptoCode,
        description: cryptoCode,
        isDefault: true,
        network: 'mainnet',
        minimum: 0,
      ),
    ],
  );
  final quote = Quote(
    paymentMethodId: 'pm_0001',
    cryptoAmount: cryptoAmount,
    fiatAmount: '100.00',
    processingFee: processingFee,
    networkFee: networkFee,
  );
  return MakeOrderState.initial().copyWith(
    step: MakeOrderStep.quoteReady,
    selectedFiat: fiat,
    selectedCrypto: crypto,
    quote: quote,
  );
}
