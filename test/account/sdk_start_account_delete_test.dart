// Every start imports the start account's key again, so deleting that account
// would silently bring it back. The bloc refuses the delete and the menu
// shows Delete disabled on that row.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _start = '0xAAAA';
const _other = '0xBBBB';
const _selected = '0xCCCC';

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
  final deleted = <String>[];

  @override
  String? getStartAccountAddress() => _start;

  @override
  String? getSelectedAccountAddress() => _selected;

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  List<String> getAvailableAccounts() => const [_start, _other, _selected];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  GeniusNodeReturnValue deleteAccount(String publicAddress) {
    deleted.add(publicAddress);
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  Future<void> removeSDKAccountLink(String sdkAddress) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
  }) {
    emit(
      state.copyWith(
        sdkAccounts: const [_start, _other, _selected],
        selectedSDKAccount: _selected,
        defaultSDKAccount: _start.toLowerCase(),
      ),
    );
  }
}

void main() {
  late _Api api;
  late WalletDetailsCubit details;
  late _SeededAppBloc bloc;

  setUp(() {
    api = _Api();
    details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
    );
  });

  tearDown(() async {
    await bloc.close();
    await details.close();
  });

  test('a late SDK start is recorded on the next account refresh', () async {
    // Fresh install: the bloc starts before any wallet, so nothing is linked.
    final late = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final fresh = AppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: late,
      networkProvider: NetworkProvider(),
    );
    expect(fresh.state.defaultSDKAccount, isNull);

    // The first wallet then starts the SDK; any later refresh must see it.
    fresh.add(RefreshSDKAccounts());
    await fresh.close();
    expect(fresh.state.defaultSDKAccount, _start);
    await late.close();
  });

  test('the start account never reaches the SDK delete', () async {
    bloc.add(DeleteSDKAccount(_start.toLowerCase()));
    bloc.add(DeleteSDKAccount(_other));
    // close() drains the queued events first.
    await bloc.close();

    expect(api.deleted, [_other]);
  });

  testWidgets('Delete is disabled on the start account row', (tester) async {
    // Tall enough that all three rows and the node section's button build
    // without a scroll.
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletDetailsCubit>.value(value: details),
          BlocProvider<AppBloc>.value(value: bloc),
        ],
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AccountDrawer.show(context),
                child: const Text('open drawer'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open drawer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Default account'), findsOneWidget);

    VoidCallback? delete() => tester
        .widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, 'Delete account'),
        )
        .onPressed;

    await tester.tap(find.byTooltip('Account options').at(0));
    await tester.pumpAndSettle();
    expect(delete(), isNull);
    await tester.tap(find.byTooltip('Account options').at(0));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Account options').at(1));
    await tester.pumpAndSettle();
    expect(delete(), isNotNull);

    await tester.runAsync(() => bloc.close());
  });
}
