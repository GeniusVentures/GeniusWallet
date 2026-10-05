// A node that is still starting answers "which account?" with a placeholder
// for minutes. The app must treat that as no account, keep the switch
// pending, and only name an account once the node really reports one.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/account/node_switch_toasts.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

const _old = '0xaaaa1111';
const _target = '0xaaaa2222';
const _other = '0xaaaa3333';

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _NodeApi implements GeniusApi {
  _NodeApi({this.selectResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK});

  final GeniusNodeReturnValue selectResult;

  /// What the node names as its account; null stands for the placeholder.
  String? reported = _old;
  int reads = 0;
  final selects = <String>[];

  /// The node keeps naming its old account for a while after the switch.
  bool keepsOldAccount = false;

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(String address) async {
    selects.add(address);
    if (!keepsOldAccount) {
      reported = null;
    }
    return selectResult;
  }

  @override
  String? getSelectedAccountAddress() {
    reads++;
    return reported;
  }

  @override
  List<String> getAvailableAccounts() => const [_old, _target, _other];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  String? getStartAccountAddress() => null;

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Holds each native switch open until the test completes it.
class _GatedNodeApi extends _NodeApi {
  final pending = <String, Completer<GeniusNodeReturnValue>>{};

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(String address) {
    final done = Completer<GeniusNodeReturnValue>();
    pending[address] = done;
    return done.future.then((r) {
      reported = address;
      return r;
    });
  }
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc(GeniusApi api)
    : super(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        ),
        networkProvider: NetworkProvider(),
      ) {
    emit(state.copyWith(selectedSDKAccount: _old));
  }
}

void main() {
  test('only "0x" + 128 hex counts as an SDK address', () {
    final real = '0x${'ab' * 64}';
    expect(sdkAddressOrNull(real), real);
    expect(sdkAddressOrNull('0xUNVAILABLE'), isNull);
    expect(sdkAddressOrNull(''), isNull);
    expect(sdkAddressOrNull('0x${'ab' * 63}'), isNull);
  });

  testWidgets('a switch the node has not confirmed stays pending, names no '
      'account, and lands once the node reports it', (tester) async {
    final api = _NodeApi();
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();

    expect(bloc.state.switchingSDKAccount, _target);
    expect(bloc.state.selectedSDKAccount, isNull);

    await tester.pump(const Duration(seconds: 9));
    expect(bloc.state.switchingSDKAccount, _target);

    api.reported = _target;
    await tester.pump(const Duration(seconds: 3));

    expect(bloc.state.selectedSDKAccount, _target);
    expect(bloc.state.switchingSDKAccount, isNull);

    final readsAfterLanding = api.reads;
    await tester.pump(const Duration(seconds: 12));
    expect(api.reads, readsAfterLanding, reason: 'polling stops once landed');

    await tester.runAsync(() => bloc.close());
  });

  testWidgets('the node naming another account ends the switch on that '
      'account', (tester) async {
    final api = _NodeApi();
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();
    api.reported = _other;
    await tester.pump(const Duration(seconds: 3));

    expect(bloc.state.selectedSDKAccount, _other);
    expect(bloc.state.switchingSDKAccount, isNull);

    await tester.runAsync(() => bloc.close());
  });

  testWidgets('a second switch starts only after the first returns, so the '
      'node ends on the last account requested', (tester) async {
    final api = _GatedNodeApi();
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    bloc.add(SelectSDKAccount(_other));
    await tester.pump();
    expect(api.pending.keys, [_target]);

    api.pending[_target]!.complete(GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
    await tester.pump();
    await tester.pump();
    expect(bloc.state.switchingSDKAccount, _other);

    api.pending[_other]!.complete(GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
    await tester.pump();
    await tester.pump();
    expect(bloc.state.selectedSDKAccount, _other);
    expect(bloc.state.switchingSDKAccount, isNull);

    await tester.runAsync(() => bloc.close());
  });

  testWidgets('no second switch starts while the first is still settling', (
    tester,
  ) async {
    final api = _NodeApi();
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();
    expect(bloc.state.switchingSDKAccount, _target);

    bloc.add(SelectSDKAccount(_other));
    await tester.pump();

    expect(api.selects, [_target]);
    expect(bloc.state.switchingSDKAccount, _target);

    await tester.runAsync(() => bloc.close());
  });

  testWidgets('a read that still names the old account keeps the switch '
      'pending until the target lands', (tester) async {
    final api = _NodeApi()..keepsOldAccount = true;
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();
    expect(bloc.state.switchingSDKAccount, _target);

    await tester.pump(const Duration(seconds: 6));
    expect(bloc.state.switchingSDKAccount, _target);

    api.reported = _target;
    await tester.pump(const Duration(seconds: 3));
    expect(bloc.state.selectedSDKAccount, _target);
    expect(bloc.state.switchingSDKAccount, isNull);

    await tester.runAsync(() => bloc.close());
  });

  testWidgets('a slow switch still lands after minutes on the old account', (
    tester,
  ) async {
    final api = _NodeApi()..keepsOldAccount = true;
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();
    await tester.pump(const Duration(minutes: 3));
    expect(bloc.state.switchingSDKAccount, _target);

    api.reported = _target;
    await tester.pump(const Duration(seconds: 3));
    expect(bloc.state.selectedSDKAccount, _target);
    expect(bloc.state.switchingSDKAccount, isNull);

    await tester.runAsync(() => bloc.close());
  });

  testWidgets('closing the bloc stops the poll', (tester) async {
    final api = _NodeApi();
    final bloc = _SeededAppBloc(api);

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();
    await tester.runAsync(() => bloc.close());

    final readsAtClose = api.reads;
    await tester.pump(const Duration(seconds: 12));
    expect(api.reads, readsAtClose);
  });

  testWidgets('a refused switch clears the target at once and toasts the '
      'account by name', (tester) async {
    final api = _NodeApi(
      selectResult: GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
    );
    final bloc = _SeededAppBloc(api);
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      BlocProvider<AppBloc>.value(
        value: bloc,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(extensions: [GWColors.dark()]),
          builder: (context, child) =>
              NodeSwitchToasts(navigatorKey: navigatorKey, child: child!),
          home: const SizedBox.shrink(),
        ),
      ),
    );

    bloc.add(SelectSDKAccount(_target));
    await tester.pump();
    await tester.pump();

    expect(bloc.state.switchingSDKAccount, isNull);
    expect(bloc.state.selectedSDKAccount, _old);
    expect(
      find.text("Couldn't switch earning to 0xaaaa...2222."),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    await tester.runAsync(() => bloc.close());
  });
}
