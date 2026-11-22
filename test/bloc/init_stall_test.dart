// The init feed's stall window is carried on the state as the timestamp of
// the reading's last change: it starts on the first tick, survives frozen
// ticks, restarts when the reading moves, and Retry restarts it while the
// poll keeps running. The compute panel derives the stalled state from this
// timestamp (the same split as processingCompletedAt/sinceJobFinished), so
// the frozen-past-deadline crossing itself is a pure-module test, not a
// timed one.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
  GeniusInitStatus status = const GeniusInitStatus(
    percentage: 0.6,
    message: 'starting',
  );

  @override
  GeniusInitStatus getInitializationStatus() => status;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => const {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  Stream<List<Wallet>> getWallets() => Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the init stall window tracks the reading, Retry restarts it', (
    tester,
  ) async {
    final api = _Api();
    final bloc = AppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      ),
      networkProvider: NetworkProvider(),
    );

    // The first reading lands on the first tick and starts the window.
    await tester.pump(const Duration(seconds: 3));
    expect(bloc.state.initPercentage, 0.6);
    final firstChange = bloc.state.initReadingChangedAt;
    expect(firstChange, isNotNull);

    // Frozen ticks keep the window - this is what lets it grow past the
    // stall deadline at the panel.
    await tester.pump(const Duration(seconds: 9));
    expect(bloc.state.initReadingChangedAt, firstChange);

    // A moved reading restarts the window.
    api.status = const GeniusInitStatus(percentage: 0.65, message: 'more');
    await tester.pump(const Duration(seconds: 3));
    final secondChange = bloc.state.initReadingChangedAt;
    expect(secondChange!.isAfter(firstChange!), isTrue);

    // Retry restarts the window even though the reading stays frozen, and
    // the poll keeps running.
    bloc.add(RetryInitializationStatus());
    await tester.pump(const Duration(seconds: 3));
    expect(bloc.state.initReadingChangedAt, isNot(secondChange));
    expect(bloc.state.initPercentage, 0.65);

    // Inline, not addTearDown: the framework's pending-timer check runs
    // before teardowns, and closing the bloc is what cancels the init poll.
    await tester.runAsync(() => bloc.close());
  });
}
