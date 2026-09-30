import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';

import 'fake_banxa_api.dart';
import 'fixtures.dart';

const _a = '0xAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAa';
const _b = '0xBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBb';

List<String> _ids(OrdersCubit cubit) =>
    cubit.state.orders?.orders.map((o) => o.id).toList() ?? const [];

void main() {
  test('a wallet selected at construction loads once, under its own '
      'customer id', () async {
    final api = FakeBanxaApi(orders: [testOrder(id: 'a1')]);
    final cubit = OrdersCubit(
      walletDetailsCubit: PickableWalletCubit(testWallet(_a)),
      api: api,
    );
    await pumpEventQueue();

    expect(api.fetchAllOrdersCalls, 1);
    expect(api.lastCustomerId, 'gw-${_a.toLowerCase()}');
    expect(_ids(cubit), ['a1']);
    await cubit.close();
  });

  test('switching wallets clears the list and fetches once for the new '
      'wallet; the same address in another case does not refetch', () async {
    final wallets = PickableWalletCubit(testWallet(_a));
    final api = FakeBanxaApi(orders: [testOrder(id: 'a1')]);
    final cubit = OrdersCubit(walletDetailsCubit: wallets, api: api);
    await pumpEventQueue();

    final held = Completer<void>();
    api.holdFetch = (_) => held;
    api.orders = [testOrder(id: 'b1')];
    wallets.pick(testWallet(_b));
    await pumpEventQueue();

    expect(cubit.state.orders, isNull, reason: 'A rows are gone at once');
    expect(api.fetchAllOrdersCalls, 2);
    expect(api.lastCustomerId, 'gw-${_b.toLowerCase()}');

    held.complete();
    await pumpEventQueue();
    expect(_ids(cubit), ['b1']);

    wallets.pick(testWallet(_b.toUpperCase().replaceFirst('0X', '0x')));
    await pumpEventQueue();
    expect(api.fetchAllOrdersCalls, 2);
    await cubit.close();
  });

  test('a late response for the previous wallet never lands under the new '
      'one', () async {
    final wallets = PickableWalletCubit(testWallet(_a));
    final api = FakeBanxaApi(orders: [testOrder(id: 'a1')]);
    final heldA = Completer<void>();
    api.holdFetch = (id) => id == 'gw-${_a.toLowerCase()}' ? heldA : null;
    final cubit = OrdersCubit(walletDetailsCubit: wallets, api: api);
    await pumpEventQueue();

    api.orders = [testOrder(id: 'b1')];
    wallets.pick(testWallet(_b));
    await pumpEventQueue();
    expect(_ids(cubit), ['b1']);

    heldA.complete();
    await pumpEventQueue();

    expect(_ids(cubit), ['b1']);
    expect(cubit.state.status, OrdersStatus.success);
    await cubit.close();
  });

  test('a failed fetch for the previous wallet does not show as an error '
      'under the new one', () async {
    final wallets = PickableWalletCubit(testWallet(_a));
    final api = FakeBanxaApi()..fetchOrdersError = Exception('boom');
    final heldA = Completer<void>();
    api.holdFetch = (id) => id == 'gw-${_a.toLowerCase()}' ? heldA : null;
    final cubit = OrdersCubit(walletDetailsCubit: wallets, api: api);
    await pumpEventQueue();

    api.fetchOrdersError = null;
    wallets.pick(testWallet(_b));
    await pumpEventQueue();
    heldA.complete();
    await pumpEventQueue();

    expect(cubit.state.status, OrdersStatus.success);
    expect(cubit.state.error, isEmpty);
    await cubit.close();
  });

  test('with no wallet selected nothing is fetched, and after close a '
      'switch triggers no fetch', () async {
    final wallets = PickableWalletCubit();
    final api = FakeBanxaApi(orders: [testOrder(id: 'a1')]);
    final cubit = OrdersCubit(walletDetailsCubit: wallets, api: api);
    await pumpEventQueue();

    await cubit.fetchOrders();
    expect(api.fetchAllOrdersCalls, 0);
    expect(cubit.state.status, OrdersStatus.success);
    expect(_ids(cubit), isEmpty);

    await cubit.close();
    wallets.pick(testWallet(_a));
    await pumpEventQueue();
    expect(api.fetchAllOrdersCalls, 0);
  });
}
