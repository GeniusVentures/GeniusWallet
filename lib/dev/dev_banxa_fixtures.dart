import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:genius_wallet/banxa/banxa_model.dart';

// DEV-ONLY: makes the Banxa order surfaces reachable without the sandbox.
//
// Why this exists. The Banxa screens are the least walkable in the app: the
// orders list, the order card, the order-details card and its page all render
// nothing until a real order exists, and creating one means a live
// `banxa-sandbox.com` round trip with KYC and a payment method. Phase 9
// re-skinned all of them and its own decision record (09-CONTEXT.md D-03)
// forbade exactly that round trip — so ten re-skinned surfaces shipped without
// anyone having seen six of them. This closes that gap.
//
// Shape is deliberately copied from `dev_fault_injector.dart`: a private
// singleton, sticky `ValueNotifier` overrides, an explicit disarm, and reads
// gated at exactly one call site behind `kDebugMode && kShowDevTools`.
//
// ponytail: process-lifetime in-memory state, one fixture set, deliberately
// not persisted and not generalised into a fixture registry. The upgrade path
// for a second fixture set is one more field plus one more gated read, the
// same way the markets fault was added alongside the account fault.

/// What the orders list should render on its next fetch. `null` means "no
/// override — run the real fetch against the sandbox".
enum DevBanxaOrders {
  /// Four orders, one per status bucket of the 09-01 ladder — completed,
  /// pending, declined, and an unrecognised status that must land in the
  /// neutral bucket rather than crashing or defaulting to a happy colour.
  seeded,

  /// A successful fetch that returns zero orders — the `GWEmptyState` branch
  /// 09-02 added. Distinct from [DevBanxaOrders.error]: this is "the call
  /// worked, you have no orders", which is the state a new wallet is in.
  empty,

  /// A failed fetch — the `GWErrorState` branch 09-02 added, which replaced a
  /// bare `"❌ …"` string that offered no way forward.
  error,
}

class DevBanxaFixtures {
  DevBanxaFixtures._();

  static final DevBanxaFixtures instance = DevBanxaFixtures._();

  /// Sticky override for the orders list, read by `OrdersCubit.fetchOrders`.
  ///
  /// Sticky rather than one-shot for the same reason `marketsFault` is: a
  /// walk needs the state to survive window resizes and appearance toggles.
  /// [disarm] is the explicit off, and it matters here more than usual —
  /// while [DevBanxaOrders.error] is armed, the error state's own Retry
  /// button re-runs a fetch that reproduces the same error, so without a
  /// disarm nobody could ever watch it genuinely recover.
  final ValueNotifier<DevBanxaOrders?> orders = ValueNotifier(null);

  /// Arms a sticky override. Assigns rather than toggling, so repeated
  /// presses of the same button are idempotent.
  void arm(DevBanxaOrders mode) {
    orders.value = mode;
  }

  /// Clears the override so the next fetch runs for real.
  void disarm() {
    orders.value = null;
  }

  /// The seeded fixture set — four orders spanning every bucket of
  /// `order_status_style.dart`'s ladder.
  ///
  /// Built here rather than reusing `test/banxa/fixtures.dart` because that
  /// file lives under `test/` and cannot be imported from `lib/`. The two are
  /// intentionally similar in spirit; if the `Order` model changes, both need
  /// updating and the analyzer will say so.
  ///
  /// Dates are fixed offsets from a single `now` so the list has a stable,
  /// readable ordering rather than four identical timestamps.
  static OrdersResponse seededOrders() {
    final now = DateTime.now().toUtc();

    Order order({
      required String id,
      required String status,
      required String fiatAmount,
      required String cryptoAmount,
      required String cryptoId,
      required int daysAgo,
      String? txHash,
    }) => Order(
      id: id,
      externalId: 'dev_$id',
      externalCustomerId: 'dev-walker',
      country: 'US',
      orderStatusUrl: '',
      orderType: 'CRYPTO-BUY',
      crypto: Crypto(id: cryptoId, blockchain: cryptoId, network: ''),
      fiat: 'USD',
      fiatAmount: fiatAmount,
      cryptoAmount: cryptoAmount,
      paymentMethodId: '1',
      paymentMethodName: 'Credit Card',
      processingFee: '2.50',
      networkFee: '1.20',
      transactionHash: txHash,
      walletAddress: '0xb4B8C167e23FB3Ed1E27bCE67EBff961369De9d8',
      walletAddressTag: null,
      status: status,
      metadata: null,
      createdAt: now.subtract(Duration(days: daysAgo)),
      updatedAt: now.subtract(Duration(days: daysAgo)),
    );

    final list = <Order>[
      // success bucket
      order(
        id: 'dev-completed',
        status: 'completed',
        fiatAmount: '250.00',
        cryptoAmount: '0.0031',
        cryptoId: 'ETH',
        daysAgo: 1,
        txHash:
            '0x0f9b1b9a7c65dd5c1c0c0ef879b1dd73bb7f7f2187bbf1a8329c7edc9b3d4abc',
      ),
      // warning bucket — the one that must NOT use GWColors.statusWarning,
      // because that field does not exist (09-01's finding).
      order(
        id: 'dev-pending',
        status: 'pendingPayment',
        fiatAmount: '75.00',
        cryptoAmount: '0.00093',
        cryptoId: 'ETH',
        daysAgo: 2,
      ),
      // error bucket — the branch order_details_card.dart did NOT have before
      // Phase 9 (it was a 2-way green/orange ternary).
      order(
        id: 'dev-declined',
        status: 'declined',
        fiatAmount: '1000.00',
        cryptoAmount: '0.0124',
        cryptoId: 'ETH',
        daysAgo: 5,
      ),
      // neutral bucket — a status the ladder does not recognise. Deliberately
      // not a typo: an unknown status must degrade to neutral rather than be
      // painted as success, which is the failure mode a 2-way ternary had.
      order(
        id: 'dev-unknown',
        status: 'someFutureBanxaStatus',
        fiatAmount: '42.00',
        cryptoAmount: '0.00052',
        cryptoId: 'ETH',
        daysAgo: 9,
      ),
    ];

    return OrdersResponse(
      orders: list,
      total: list.length,
      pageTotal: list.length,
    );
  }
}
