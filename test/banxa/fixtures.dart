import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
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
  String network = 'mainnet',
  String processingFee = '2.50',
  String networkFee = '1.00',
  String? transactionHash,
  String? walletAddressTag,
  String? country,
  Map<String, dynamic>? metadata,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Order(
    id: id,
    externalId: 'ext_$id',
    externalCustomerId: 'cust_0001',
    country: country,
    orderStatusUrl: 'https://banxa-sandbox.com/orders/$id',
    orderType: 'CRYPTO-BUY',
    crypto: Crypto(id: cryptoId, blockchain: cryptoId, network: network),
    fiat: fiat,
    fiatAmount: fiatAmount,
    cryptoAmount: cryptoAmount,
    paymentMethodId: 'pm_0001',
    paymentMethodName: paymentMethodName,
    processingFee: processingFee,
    networkFee: networkFee,
    transactionHash: transactionHash,
    walletAddress: walletAddress,
    walletAddressTag: walletAddressTag,
    status: status,
    metadata: metadata,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1, 12),
    updatedAt: updatedAt ?? DateTime.utc(2026, 1, 1, 13),
  );
}

/// An `OrdersCubit` that emits a fixed state instead of fetching.
///
/// `OrdersCubit.fetchOrders` is DEV-gated (`kDebugMode && kShowDevTools`) and
/// otherwise hits an unreachable sandbox (09-CONTEXT.md D-03), so every test
/// that needs real orders on screen seeds them this way. Legal because `emit`
/// is `@protected` (accessible to subclasses) - it reaches into no private
/// widget.
///
/// Lived privately in `orders_header_track_test.dart` until 260731-ope gave it
/// a second consumer (`order_rail_row_test.dart`), which is where it moved
/// here: `fixtures.dart` is already this suite's shared fixture home.
class SeededOrdersCubit extends OrdersCubit {
  SeededOrdersCubit(this._seeded);

  final OrdersState _seeded;

  @override
  Future<void> fetchOrders([String? externalCustomerIdOverride]) async {
    emit(_seeded);
  }
}

/// An `OrdersState` in the success state carrying [orders].
OrdersState seededOrdersState(List<Order> orders) =>
    OrdersState.initial().copyWith(
      status: OrdersStatus.success,
      orders: OrdersResponse(
        orders: orders,
        total: orders.length,
        pageTotal: orders.length,
      ),
      filteredOrders: orders,
    );

/// A `MakeOrderState` for the Buy GNUS FORM - selected currencies, an optional
/// `Quote`, an optional payment method and an optional typed amount - built
/// without a cubit or the network (09-CONTEXT.md D-03).
///
/// Was `testQuoteState()`, whose one consumer was the hand-copied quote-grid
/// reconstruction in `buy_page_layout_test.dart`. 260731-uhe deleted that
/// reconstruction (the real `BanxaBuyForm` is now reachable) and repurposed
/// this fixture in place rather than adding a second one beside it: the same
/// factory now serves the quote/no-quote pair, the non-USD fiat case and the
/// narrow-payment-method-range case.
///
/// [withQuote] false gives the same state with `quote == null`, which is the
/// other half of the height-invariance comparison.
MakeOrderState testFormState({
  String cryptoAmount = '0.0025',
  String processingFee = '2.50',
  String networkFee = '1.00',
  String fiatCode = 'USD',
  String fiatSymbol = '\$',
  String cryptoCode = 'BTC',
  bool withQuote = true,
  PaymentMethod? paymentMethod,
  String amountText = '',
}) {
  final fiat = FiatCurrency(
    code: fiatCode,
    name: 'US Dollar',
    symbol: fiatSymbol,
    supportedPaymentMethods: paymentMethod == null ? const [] : [paymentMethod],
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
    step: withQuote ? MakeOrderStep.quoteReady : MakeOrderStep.selecting,
    selectedFiat: fiat,
    selectedCrypto: crypto,
    paymentMethods: paymentMethod == null ? const [] : [paymentMethod],
    selectedPaymentMethod: paymentMethod,
    amountText: amountText,
    quote: withQuote ? quote : null,
  );
}
