import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';

import 'fake_banxa_api.dart';
import 'fixtures.dart';

const _a = '0xAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAaAa';
const _b = '0xBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBbBb';
const _tick = Duration(seconds: 15);
final _clock = DateTime.utc(2026, 1, 1, 14);

Order _order(String id, String status, {Duration? age}) => testOrder(
  id: id,
  status: status,
  updatedAt: age == null ? null : _clock.subtract(age),
);

OrdersCubit _cubit(
  FakeBanxaApi api, {
  PickableWalletCubit? wallets,
  DateTime Function()? now,
}) => OrdersCubit(
  walletDetailsCubit: wallets ?? PickableWalletCubit(testWallet(_a)),
  api: api,
  now: now ?? () => _clock,
);

List<String> _ids(OrdersCubit cubit) =>
    cubit.state.orders?.orders.map((o) => o.id).toList() ?? const [];

String _statusOf(OrdersCubit cubit, String id) =>
    cubit.state.orders!.orders.firstWhere((o) => o.id == id).status;

void main() {
  test('each tick reads only the open orders', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(
        orders: [_order('p1', 'pendingPayment'), _order('c1', 'complete')],
      );
      final cubit = _cubit(api);
      async.flushMicrotasks();
      expect(api.readIds, isEmpty);

      async.elapse(_tick);
      expect(api.readIds, ['p1']);
      async.elapse(_tick);
      expect(api.readIds, ['p1', 'p1']);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('the state follows the scripted statuses, then reads stop', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('p1', 'pendingPayment')])
        ..statuses['p1'] = ['paymentReceived', 'complete'];
      final cubit = _cubit(api);
      async.flushMicrotasks();

      async.elapse(_tick);
      expect(_statusOf(cubit, 'p1'), 'paymentReceived');
      async.elapse(_tick);
      expect(_statusOf(cubit, 'p1'), 'complete');
      expect(api.readIds.length, 2);

      async.elapse(const Duration(minutes: 5));
      expect(api.readIds.length, 2, reason: 'nothing is open any more');

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('justFinished lists the order once, and never one final at load', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(
        orders: [_order('p1', 'pendingPayment'), _order('c1', 'complete')],
      )..statuses['p1'] = ['complete'];
      final cubit = _cubit(api);
      final seen = <OrdersState>[];
      cubit.stream.listen(seen.add);
      async.flushMicrotasks();

      expect(cubit.state.justFinished, isEmpty);
      expect(seen.any((s) => s.justFinished.isNotEmpty), isFalse);

      async.elapse(_tick);
      expect(cubit.state.justFinished.map((o) => o.id), ['p1']);

      unawaited(cubit.track('c1'));
      async.flushMicrotasks();
      expect(cubit.state.justFinished, isEmpty);
      expect(
        seen.where((s) => s.justFinished.isNotEmpty).length,
        1,
        reason: 'one emit announces it',
      );

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('an expired order is polled for an hour after its last update', () {
    fakeAsync((async) {
      final recent = FakeBanxaApi(
        orders: [_order('e1', 'expired', age: const Duration(minutes: 30))],
      );
      final old = FakeBanxaApi(
        orders: [_order('e1', 'expired', age: const Duration(minutes: 90))],
      );
      final recentCubit = _cubit(recent);
      final oldCubit = _cubit(old);
      async.flushMicrotasks();

      async.elapse(_tick);
      expect(recent.readIds, ['e1']);
      expect(old.readIds, isEmpty);

      unawaited(recentCubit.close());
      unawaited(oldCubit.close());
      async.flushMicrotasks();
    });
  });

  test('a revived expired order is announced when it completes', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(
        orders: [_order('e1', 'expired', age: const Duration(minutes: 5))],
      )..statuses['e1'] = ['paymentReceived', 'complete'];
      final cubit = _cubit(api);
      async.flushMicrotasks();

      async.elapse(_tick);
      expect(_statusOf(cubit, 'e1'), 'paymentReceived');
      async.elapse(_tick);
      expect(cubit.state.justFinished.map((o) => o.id), ['e1']);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('in the background nothing is read; coming back reads at once', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('p1', 'pendingPayment')]);
      final cubit = _cubit(api);
      async.flushMicrotasks();

      cubit.setForeground(false);
      async.elapse(const Duration(minutes: 2));
      expect(api.readIds, isEmpty);

      cubit.setForeground(true);
      async.flushMicrotasks();
      expect(api.readIds, ['p1']);
      async.elapse(_tick);
      expect(api.readIds, ['p1', 'p1']);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('track puts the order first and starts polling it', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('c1', 'complete')]);
      final cubit = _cubit(api);
      async.flushMicrotasks();
      api.orders = [_order('c1', 'complete'), _order('n1', 'pendingPayment')];
      async.elapse(_tick * 2);
      expect(api.readIds, isEmpty, reason: 'nothing open yet');

      unawaited(cubit.track('n1'));
      async.flushMicrotasks();
      expect(_ids(cubit), ['n1', 'c1']);

      async.elapse(_tick);
      expect(api.readIds, ['n1', 'n1']);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('a tracked order whose first read fails is retried by the poll', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('c1', 'complete')]);
      final cubit = _cubit(api);
      async.flushMicrotasks();
      api.orders = [_order('c1', 'complete'), _order('n1', 'pendingPayment')];

      api.orderByIdError = Exception('offline');
      unawaited(cubit.track('n1'));
      async.flushMicrotasks();
      expect(_ids(cubit), ['c1']);

      api.orderByIdError = null;
      async.elapse(_tick);
      expect(_ids(cubit), ['n1', 'c1']);
      expect(_statusOf(cubit, 'n1'), 'pendingPayment');

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('a tracked order already final on its first read is announced', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('c1', 'complete')]);
      final cubit = _cubit(api);
      final finished = <String>[];
      cubit.stream.listen(
        (s) => finished.addAll(s.justFinished.map((o) => o.id)),
      );
      async.flushMicrotasks();
      api.orders = [_order('c1', 'complete'), _order('n1', 'complete')];

      api.orderByIdError = Exception('offline');
      unawaited(cubit.track('n1'));
      async.flushMicrotasks();

      api.orderByIdError = null;
      async.elapse(_tick);
      expect(finished, ['n1']);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('refreshOrder completes once the order has been read', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('p1', 'pendingPayment')])
        ..statuses['p1'] = ['complete'];
      final cubit = _cubit(api);
      async.flushMicrotasks();

      var done = false;
      unawaited(cubit.refreshOrder('p1').then((_) => done = true));
      async.flushMicrotasks();

      expect(done, isTrue);
      expect(_statusOf(cubit, 'p1'), 'complete');

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('a tick in flight during a wallet switch never lands', () {
    fakeAsync((async) {
      final wallets = PickableWalletCubit(testWallet(_a));
      final api = FakeBanxaApi(orders: [_order('p1', 'pendingPayment')])
        ..statuses['p1'] = ['complete'];
      final cubit = _cubit(api, wallets: wallets);
      async.flushMicrotasks();

      final held = Completer<void>();
      api.holdOrderById = held;
      async.elapse(_tick);
      expect(api.readIds, ['p1']);

      api.orders = [_order('b1', 'declined')];
      wallets.pick(testWallet(_b));
      async.flushMicrotasks();
      held.complete();
      async.flushMicrotasks();

      expect(_ids(cubit), ['b1']);
      expect(cubit.state.justFinished, isEmpty);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('a failed read keeps the old order and ticks never overlap', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('p1', 'pendingPayment')])
        ..statuses['p1'] = ['complete'];
      final cubit = _cubit(api);
      async.flushMicrotasks();

      api.orderByIdError = Exception('offline');
      async.elapse(_tick);
      expect(_statusOf(cubit, 'p1'), 'pendingPayment');

      api.orderByIdError = null;
      final held = Completer<void>();
      api.holdOrderById = held;
      async.elapse(_tick * 3);
      expect(api.readIds.length, 2, reason: 'one read in flight, no more');

      api.holdOrderById = null;
      held.complete();
      async.flushMicrotasks();
      expect(_statusOf(cubit, 'p1'), 'complete');

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('a tracked order survives a list fetch that started before it', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('c1', 'complete')]);
      final cubit = _cubit(api);
      async.flushMicrotasks();

      final held = Completer<void>();
      api.holdFetch = (_) => held;
      unawaited(cubit.fetchOrders());
      async.flushMicrotasks();
      api.orders = [_order('c1', 'complete'), _order('n1', 'pendingPayment')];
      unawaited(cubit.track('n1'));
      async.flushMicrotasks();
      held.complete();
      async.flushMicrotasks();

      expect(_ids(cubit), ['n1', 'c1']);

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });

  test('a list fetch started while track is in flight does not drop it', () {
    fakeAsync((async) {
      final api = FakeBanxaApi(orders: [_order('c1', 'complete')]);
      final cubit = _cubit(api);
      async.flushMicrotasks();

      final heldRead = Completer<void>();
      api.holdOrderById = heldRead;
      unawaited(cubit.track('n1'));
      async.flushMicrotasks();

      final heldFetch = Completer<void>();
      api.holdFetch = (_) => heldFetch;
      unawaited(cubit.fetchOrders());
      async.flushMicrotasks();

      api.orders = [_order('c1', 'complete'), _order('n1', 'pendingPayment')];
      heldRead.complete();
      async.flushMicrotasks();
      heldFetch.complete();
      async.flushMicrotasks();

      expect(_ids(cubit), contains('n1'));

      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });
}
