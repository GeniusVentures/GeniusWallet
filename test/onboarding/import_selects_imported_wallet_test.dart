// Importing a wallet while another one is selected must land the dashboard
// on the imported wallet. The completion reload must carry the imported
// address so the wallet loader can select it, the same way a first wallet
// wins on a fresh profile.
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

const _oldAddress = '0x1111111111111111111111111111111111111111';
const _importedAddress = '0x2222222222222222222222222222222222222222';

/// The import succeeds; what the api says about the new wallet is the
/// contract under test.
class _ImportApi implements GeniusApi {
  final failed = ValueNotifier(false);

  @override
  ValueListenable<bool> get secureStorageFailed => failed;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #validateWalletImport) {
      return Future<String?>.value(_importedAddress);
    }
    return super.noSuchMethod(invocation);
  }
}

/// Records what the import flow asks the app bloc to do. `implements`, not
/// `extends`: the real constructor starts init polling against a live api.
class _RecordingAppBloc implements AppBloc {
  final added = <AppEvent>[];

  @override
  Stream<AppState> get stream => const Stream<AppState>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #add) {
      added.add(invocation.positionalArguments.first as AppEvent);
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

/// Two wallets on an offline api, so a real AppBloc can run LoadWallets.
class _WalletsApi implements GeniusApi {
  Wallet _wallet(String address) => Wallet(
    coinType: TWCoinType.TWCoinTypeEthereum,
    walletName: address == _oldAddress ? 'Kept' : 'Imported',
    currencySymbol: 'ETH',
    walletType: WalletType.privateKey,
    balance: 0,
    address: address,
  );

  @override
  Stream<List<Wallet>> getWallets() =>
      Stream.value([_wallet(_oldAddress), _wallet(_importedAddress)]);

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GoRouter _router(AppBloc app, ExistingWalletBloc flow) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const Scaffold(body: Text('landing')),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (_, _) => const Scaffold(body: Text('dashboard')),
    ),
    GoRoute(
      path: '/import',
      builder: (_, _) => MultiBlocProvider(
        providers: [
          BlocProvider<ExistingWalletBloc>.value(value: flow),
          BlocProvider<AppBloc>.value(value: app),
          BlocProvider(create: (_) => NewPinCubit(api: _ImportApi())),
        ],
        child: const ExistingWalletFlow(),
      ),
    ),
  ],
);

void main() {
  testWidgets('importing a wallet reloads with the imported address', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final app = _RecordingAppBloc();
    final api = _ImportApi();
    final flowBloc = ExistingWalletBloc(
      geniusApi: api,
      initialState: const ExistingWalletState(
        currentStep: ImportWalletStep.importWalletSecurity,
        selectedWallet: 'Restored',
      ),
    );
    final router = _router(app, flowBloc);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    );
    unawaited(router.push('/import'));
    await tester.pumpAndSettle();

    flowBloc.add(
      WalletSecurityEntered(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Restored',
        walletType: 'Ethereum',
        securityType: SecurityType.privateKey,
        pasteFieldText:
            '0x${'ab' * 64}', // never decoded: the api import is faked
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(flowBloc.state.importWalletStatus, ExistingWalletStatus.success);
    // The listener's go() lands on the next pump after the state change.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('dashboard'), findsOneWidget);
    final load = app.added.whereType<LoadWallets>().single;
    // The reload must name the wallet it should land on. Until it does, the
    // dashboard restores the previously selected wallet after an import.
    expect(load.selectAddress, _importedAddress);
  });

  test(
    'the loader selects the requested wallet, else the persisted choice',
    () async {
      final dir = await Directory.systemTemp.createTemp('gws-import-select');
      Hive.init(dir.path);
      addTearDown(() async {
        await Hive.close();
        await dir.delete(recursive: true);
      });
      Hive
        ..registerAdapter(TransactionDirectionAdapter(), override: true)
        ..registerAdapter(TransactionStatusAdapter(), override: true)
        ..registerAdapter(TransactionTypeAdapter(), override: true)
        ..registerAdapter(TransferRecipientsAdapter(), override: true)
        ..registerAdapter(TransactionAdapter(), override: true);

      final walletBox = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
      await Hive.openBox(networkBoxName, bytes: Uint8List(0));
      await walletBox.putAll({
        selectedWalletKey: _oldAddress,
        selectedWalletTypeKey: WalletType.privateKey.name,
      });

      final api = _WalletsApi();
      final networkProvider = NetworkProvider();
      await networkProvider.loadNetworks();
      final walletDetails = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = AppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: walletDetails,
        networkProvider: networkProvider,
      );
      addTearDown(bloc.close);

      // Without an address the reload restores what was selected before, the
      // dashboard's pull-to-refresh path.
      bloc.add(LoadWallets());
      await bloc.stream.firstWhere(
        (s) => s.subscribeToWalletStatus == AppStatus.loaded,
      );
      expect(walletDetails.state.selectedWallet?.address, _oldAddress);

      bloc.add(LoadWallets(selectAddress: _importedAddress));
      await bloc.stream.firstWhere(
        (s) => s.subscribeToWalletStatus == AppStatus.loaded,
      );
      expect(walletDetails.state.selectedWallet?.address, _importedAddress);
    },
  );
}
