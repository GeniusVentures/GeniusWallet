// Proves the read-only child-wallets screen against a fake API: the header
// names the main account in every state, each child shows its linked name
// or "Unlinked" plus its own address, balances render exact, rows keep the
// SDK's own order, and the screen re-reads on demand and on a timer.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _linkedChildAddress = '0x2222222222222222222222222222222222bbbb';
const _unlinkedChildAddress = '0x3333333333333333333333333333333333cccc';
const _otherOwnAddress = '0x9999999999999999999999999999999999ffff';

const _lagNote = 'Balances can take a moment to update.';

const _mainWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainAddress,
);

const _childWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Game Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _linkedChildAddress,
);

const _otherOwnWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Parent Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _otherOwnAddress,
);

const _links = <String, SDKAccountLink>{
  _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
  _linkedChildAddress: (
    walletAddress: _linkedChildAddress,
    walletName: 'Game Wallet',
  ),
  _otherOwnAddress: (
    walletAddress: _otherOwnAddress,
    walletName: 'Parent Wallet',
  ),
};

/// [_mainAddress] plus one other own account ([_otherOwnAddress]) -- the
/// "This account" card's parent-main lookup needs a second own account to
/// have anything to find.
const _withOtherOwnAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress, _otherOwnAddress],
  wallets: [_mainWallet, _childWallet, _otherOwnWallet],
  sdkAccountLinks: _links,
);

const _selectedAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress],
  wallets: [_mainWallet, _childWallet],
  sdkAccountLinks: _links,
);

const _noAccountAppState = AppState(
  selectedSDKAccount: null,
  sdkAccounts: [],
  wallets: [_mainWallet, _childWallet],
  sdkAccountLinks: _links,
);

/// Unlike [_selectedAppState], lists the linked child among [sdkAccounts] --
/// the dev-preset group below needs a real linked sibling for
/// [DevChildWalletsPreset.threeChildren]'s leading slot to resolve to.
const _devSelectedAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress, _linkedChildAddress],
  wallets: [_mainWallet, _childWallet],
  sdkAccountLinks: _links,
);

const _populatedRegistrations = (
  result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  entries: [
    ChildRegistration(
      childAddress: _linkedChildAddress,
      mainAddress: _mainAddress,
      sequence: 0,
    ),
    ChildRegistration(
      childAddress: _unlinkedChildAddress,
      mainAddress: _mainAddress,
      sequence: 1,
    ),
  ],
);

const _emptyOkRegistrations = (
  result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  entries: <ChildRegistration>[],
);

const _notInitializedRegistrations = (
  result: GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
  entries: <ChildRegistration>[],
);

const _queryErrorRegistrations = (
  result: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
  entries: <ChildRegistration>[],
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// [registrations] answers a read for [_mainAddress] itself (the screen's own
/// list); [otherRegistrations] answers a read for any other own account, by
/// lowercased address -- the parent-main lookup's own reads.
class _FakeApi implements GeniusApi {
  _FakeApi({
    required this.registrations,
    this.balances = const {},
    this.otherRegistrations = const {},
  });

  ChildRegistrations registrations;
  Map<String, BigInt> balances;
  Map<String, ChildRegistrations> otherRegistrations;
  int registrationsCallCount = 0;
  int registerCallCount = 0;
  String? lastRegisteredMain;
  ChildRegistrationMetadata? lastRegisteredMetadata;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) {
    registrationsCallCount++;
    if (mainAddress.toLowerCase() == _mainAddress.toLowerCase()) {
      return registrations;
    }
    return otherRegistrations[mainAddress.toLowerCase()] ??
        _emptyOkRegistrations;
  }

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) =>
      balances[childAddress] ?? BigInt.zero;

  // The all-tokens total is not a GNUS amount; a screen that read it would
  // show this instead of the balances above.
  @override
  BigInt getChildBalanceAll(String childAddress) => BigInt.from(987654321000);

  @override
  GeniusNodeReturnValue detachChild(ChildRegistrationMetadata metadata) =>
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  @override
  GeniusNodeReturnValue registerChild(
    String mainAddress,
    ChildRegistrationMetadata metadata,
  ) {
    registerCallCount++;
    lastRegisteredMain = mainAddress;
    lastRegisteredMetadata = metadata;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Delegates to [DevMockChildWallets]' own preset fixtures instead of a
/// canned registration set -- stands in for the cubit's own
/// `kDebugMode && kShowDevTools` branch, which is compiled out under
/// `flutter test` and so cannot be reached through the real gate here.
class _DevPresetApi implements GeniusApi {
  _DevPresetApi({
    required this.preset,
    required this.appState,
    required this.mainAddress,
  });

  final DevChildWalletsPreset preset;
  final AppState appState;
  final String mainAddress;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) =>
      DevMockChildWallets.registrationsFor(preset, appState, mainAddress);

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) =>
      DevMockChildWallets.balanceFor(childAddress);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the screen over a hand-built cubit and returns it -- the caller
/// closes it explicitly, before the test body ends, so its poll timer is
/// cancelled before the test framework's own pending-timer check runs.
Future<ChildWalletsCubit> _pumpScreen(
  WidgetTester tester, {
  required GeniusApi api,
  required AppState appState,
  GWColors? colors,
}) async {
  final cubit = ChildWalletsCubit(
    api: api,
    readAppState: () => appState,
    mainAddress: _mainAddress,
  );
  // Every fund-related assertion lives in child_operation_actions_test.dart;
  // this registry only has to exist so the row's menu/badge can read it.
  final operations = ChildOperationsCubit(
    api: api,
    readAppState: () => appState,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChildWalletsCubit>.value(value: cubit),
          BlocProvider<ChildOperationsCubit>.value(value: operations),
        ],
        child: const ChildWalletsScreen(),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  final appearances = {'dark': GWColors.dark(), 'light': GWColors.light()};

  for (final appearance in appearances.entries) {
    testWidgets('renders the main, each child and their balances in '
        '${appearance.key} appearance', (tester) async {
      final api = _FakeApi(
        registrations: _populatedRegistrations,
        balances: {
          _linkedChildAddress: BigInt.from(1234567),
          _unlinkedChildAddress: BigInt.from(999999),
        },
      );
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _selectedAppState,
        colors: appearance.value,
      );

      expect(find.text('Child wallets'), findsOneWidget);

      // Header: the main's linked name and short address.
      expect(find.text('Main Wallet'), findsOneWidget);
      expect(
        find.text(WalletUtils.getAddressForDisplay(_mainAddress)),
        findsOneWidget,
      );

      // Linked child: its wallet's name, not its own address as a title.
      expect(find.text('Game Wallet'), findsOneWidget);
      expect(
        find.text(WalletUtils.getAddressForDisplay(_linkedChildAddress)),
        findsOneWidget,
      );

      // Unlinked child: honest about having no link.
      expect(find.text('Unlinked'), findsOneWidget);
      expect(
        find.text(WalletUtils.getAddressForDisplay(_unlinkedChildAddress)),
        findsOneWidget,
      );

      // Exact balances, not a rounded guess.
      expect(find.text('1.234567'), findsOneWidget);
      expect(find.text('0.999999'), findsOneWidget);
      expect(find.text(' GNUS'), findsNWidgets(2));

      // Rows keep the SDK's own order: the linked child was returned first.
      final linkedRowTop = tester.getTopLeft(find.text('Game Wallet')).dy;
      final unlinkedRowTop = tester.getTopLeft(find.text('Unlinked')).dy;
      expect(linkedRowTop, lessThan(unlinkedRowTop));

      await cubit.close();
    });
  }

  group('every state keeps the header, and gates the lag note', () {
    testWidgets('connected and populated shows the lag note', (tester) async {
      final api = _FakeApi(
        registrations: _populatedRegistrations,
        balances: {_linkedChildAddress: BigInt.from(1)},
      );
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _selectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text(_lagNote), findsOneWidget);

      await cubit.close();
    });

    testWidgets('connected and empty shows the empty copy and the lag note', (
      tester,
    ) async {
      final api = _FakeApi(registrations: _emptyOkRegistrations);
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _selectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(
        find.text('No child wallets registered under this account.'),
        findsOneWidget,
      );
      expect(find.text(_lagNote), findsOneWidget);

      await cubit.close();
    });

    testWidgets(
      'no selected account shows Node not running, no lag note, no SDK call',
      (tester) async {
        final api = _FakeApi(registrations: _populatedRegistrations);
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _noAccountAppState,
        );

        expect(find.text('Main Wallet'), findsOneWidget);
        expect(find.text('Not earning right now'), findsOneWidget);
        expect(find.text(_lagNote), findsNothing);
        expect(api.registrationsCallCount, 0);

        await cubit.close();
      },
    );

    testWidgets(
      'an uninitialized SDK read also shows Node not running, no lag note',
      (tester) async {
        final api = _FakeApi(registrations: _notInitializedRegistrations);
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _selectedAppState,
        );

        expect(find.text('Main Wallet'), findsOneWidget);
        expect(find.text('Not earning right now'), findsOneWidget);
        expect(find.text(_lagNote), findsNothing);

        await cubit.close();
      },
    );

    testWidgets('a query failure shows the error copy and Retry, no lag note', (
      tester,
    ) async {
      final api = _FakeApi(registrations: _queryErrorRegistrations);
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _selectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text("Couldn't load child wallets"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text(_lagNote), findsNothing);

      await cubit.close();
    });
  });

  testWidgets('a zero-minion child reads 0.00 GNUS, not a syncing guess', (
    tester,
  ) async {
    const registrations = (
      result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
      entries: [
        ChildRegistration(
          childAddress: _linkedChildAddress,
          mainAddress: _mainAddress,
          sequence: 0,
        ),
      ],
    );
    final api = _FakeApi(
      registrations: registrations,
      balances: {_linkedChildAddress: BigInt.zero},
    );
    final cubit = await _pumpScreen(
      tester,
      api: api,
      appState: _selectedAppState,
    );

    expect(find.text('0.00'), findsOneWidget);
    expect(find.text(' GNUS'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('Retry re-reads exactly once', (tester) async {
    final api = _FakeApi(registrations: _queryErrorRegistrations);
    final cubit = await _pumpScreen(
      tester,
      api: api,
      appState: _selectedAppState,
    );
    expect(api.registrationsCallCount, 1);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(api.registrationsCallCount, 2);

    await cubit.close();
  });

  testWidgets('Refresh re-reads exactly once', (tester) async {
    final api = _FakeApi(registrations: _populatedRegistrations);
    final cubit = await _pumpScreen(
      tester,
      api: api,
      appState: _selectedAppState,
    );
    expect(api.registrationsCallCount, 1);

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();

    expect(api.registrationsCallCount, 2);

    await cubit.close();
  });

  testWidgets('polls every 10 seconds while open, and stops once closed', (
    tester,
  ) async {
    final api = _FakeApi(registrations: _populatedRegistrations);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ChildWalletsCubit>(
              create: (_) => ChildWalletsCubit(
                api: api,
                readAppState: () => _selectedAppState,
                mainAddress: _mainAddress,
              ),
            ),
            BlocProvider<ChildOperationsCubit>(
              create: (_) => ChildOperationsCubit(
                api: api,
                readAppState: () => _selectedAppState,
              ),
            ),
          ],
          child: const ChildWalletsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(api.registrationsCallCount, 1);

    await tester.pump(const Duration(seconds: 10));
    expect(api.registrationsCallCount, 2);

    // The route closing in production: the provider that owns the cubit is
    // torn down, which must cancel its timer.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(api.registrationsCallCount, 2);
  });

  test('opened before the node names an account, adopts it once it does '
      'and never queries an empty address', () async {
    final api = _FakeApi(registrations: _populatedRegistrations);
    var appState = _noAccountAppState;
    final cubit = ChildWalletsCubit(
      api: api,
      readAppState: () => appState,
      mainAddress: '',
    );
    expect(cubit.state.status, ChildWalletsStatus.nodeNotRunning);
    expect(api.registrationsCallCount, 0);

    appState = _selectedAppState;
    cubit.refresh();

    expect(cubit.state.mainAddress, _mainAddress);
    expect(cubit.state.status, ChildWalletsStatus.loaded);
    expect(cubit.state.children, hasLength(2));

    await cubit.close();
  });

  testWidgets('a long linked name ellipsizes at one line', (tester) async {
    const longName =
        'A Very Long Wallet Name That Should Not Wrap Or Overflow The Row';
    const longWallet = Wallet(
      coinType: TWCoinType.TWCoinTypeEthereum,
      walletName: longName,
      currencySymbol: 'ETH',
      walletType: WalletType.privateKey,
      balance: 0,
      address: _linkedChildAddress,
    );
    const appState = AppState(
      selectedSDKAccount: _mainAddress,
      wallets: [longWallet],
      sdkAccountLinks: {
        _linkedChildAddress: (
          walletAddress: _linkedChildAddress,
          walletName: longName,
        ),
      },
    );
    const registrations = (
      result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
      entries: [
        ChildRegistration(
          childAddress: _linkedChildAddress,
          mainAddress: _mainAddress,
          sequence: 0,
        ),
      ],
    );
    final api = _FakeApi(registrations: registrations);
    final cubit = await _pumpScreen(tester, api: api, appState: appState);

    final text = tester.widget<Text>(find.text(longName));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);

    await cubit.close();
  });

  testWidgets(
    'two children sharing a wallet name stay distinguishable by address',
    (tester) async {
      const addressA = '0x4444444444444444444444444444444444dddd';
      const addressB = '0x5555555555555555555555555555555555eeee';
      const walletA = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Shared Name',
        currencySymbol: 'ETH',
        walletType: WalletType.privateKey,
        balance: 0,
        address: addressA,
      );
      const walletB = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Shared Name',
        currencySymbol: 'ETH',
        walletType: WalletType.privateKey,
        balance: 0,
        address: addressB,
      );
      const appState = AppState(
        selectedSDKAccount: _mainAddress,
        wallets: [walletA, walletB],
        sdkAccountLinks: {
          addressA: (walletAddress: addressA, walletName: 'Shared Name'),
          addressB: (walletAddress: addressB, walletName: 'Shared Name'),
        },
      );
      const registrations = (
        result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
        entries: [
          ChildRegistration(
            childAddress: addressA,
            mainAddress: _mainAddress,
            sequence: 0,
          ),
          ChildRegistration(
            childAddress: addressB,
            mainAddress: _mainAddress,
            sequence: 1,
          ),
        ],
      );
      final api = _FakeApi(registrations: registrations);
      final cubit = await _pumpScreen(tester, api: api, appState: appState);

      expect(find.text('Shared Name'), findsNWidgets(2));
      expect(
        find.text(WalletUtils.getAddressForDisplay(addressA)),
        findsOneWidget,
      );
      expect(
        find.text(WalletUtils.getAddressForDisplay(addressB)),
        findsOneWidget,
      );

      await cubit.close();
    },
  );

  testWidgets(
    'a child address differing only in case from its link still shows the '
    'wallet name',
    (tester) async {
      const lowerAddress = '0x6666666666666666666666666666666666ffff';
      const upperAddress = '0X6666666666666666666666666666666666FFFF';
      const wallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Cased Wallet',
        currencySymbol: 'ETH',
        walletType: WalletType.privateKey,
        balance: 0,
        address: lowerAddress,
      );
      const appState = AppState(
        selectedSDKAccount: _mainAddress,
        wallets: [wallet],
        sdkAccountLinks: {
          lowerAddress: (
            walletAddress: lowerAddress,
            walletName: 'Cased Wallet',
          ),
        },
      );
      const registrations = (
        result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
        entries: [
          ChildRegistration(
            childAddress: upperAddress,
            mainAddress: _mainAddress,
            sequence: 0,
          ),
        ],
      );
      final api = _FakeApi(registrations: registrations);
      final cubit = await _pumpScreen(tester, api: api, appState: appState);

      expect(find.text('Cased Wallet'), findsOneWidget);

      await cubit.close();
    },
  );

  group('dev presets, fed through the real cubit and screen', () {
    testWidgets('none renders the empty copy and the lag note', (tester) async {
      final api = _DevPresetApi(
        preset: DevChildWalletsPreset.none,
        appState: _devSelectedAppState,
        mainAddress: _mainAddress,
      );
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _devSelectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(
        find.text('No child wallets registered under this account.'),
        findsOneWidget,
      );
      expect(find.text(_lagNote), findsOneWidget);

      await cubit.close();
    });

    testWidgets('oneChild renders exactly one row', (tester) async {
      final api = _DevPresetApi(
        preset: DevChildWalletsPreset.oneChild,
        appState: _devSelectedAppState,
        mainAddress: _mainAddress,
      );
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _devSelectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text('Unlinked'), findsOneWidget);
      expect(
        find.text(
          WalletUtils.getAddressForDisplay(
            DevMockChildWallets.singleChildAddress,
          ),
        ),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets(
      'threeChildren renders its linked sibling, an unlinked balance and a '
      'zero balance, in fixture order',
      (tester) async {
        final api = _DevPresetApi(
          preset: DevChildWalletsPreset.threeChildren,
          appState: _devSelectedAppState,
          mainAddress: _mainAddress,
        );
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _devSelectedAppState,
        );

        expect(find.text('Main Wallet'), findsOneWidget);
        // Linked slot: the real sibling's own wallet name, not "Unlinked".
        expect(find.text('Game Wallet'), findsOneWidget);
        // The unlinked pair: one nonzero, one zero.
        expect(find.text('Unlinked'), findsNWidgets(2));
        expect(find.text('0.00'), findsOneWidget);

        // Fixture order: the linked row sits above both unlinked rows.
        final linkedTop = tester.getTopLeft(find.text('Game Wallet')).dy;
        final firstUnlinkedTop = tester
            .getTopLeft(find.text('Unlinked').at(0))
            .dy;
        final secondUnlinkedTop = tester
            .getTopLeft(find.text('Unlinked').at(1))
            .dy;
        expect(linkedTop, lessThan(firstUnlinkedTop));
        expect(firstUnlinkedTop, lessThan(secondUnlinkedTop));

        await cubit.close();
      },
    );

    testWidgets('queryError renders the error copy and Retry', (tester) async {
      final api = _DevPresetApi(
        preset: DevChildWalletsPreset.queryError,
        appState: _devSelectedAppState,
        mainAddress: _mainAddress,
      );
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _devSelectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text("Couldn't load child wallets"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('nodeNotRunning renders Node not running', (tester) async {
      final api = _DevPresetApi(
        preset: DevChildWalletsPreset.nodeNotRunning,
        appState: _devSelectedAppState,
        mainAddress: _mainAddress,
      );
      final cubit = await _pumpScreen(
        tester,
        api: api,
        appState: _devSelectedAppState,
      );

      expect(find.text('Main Wallet'), findsOneWidget);
      expect(find.text('Not earning right now'), findsOneWidget);

      await cubit.close();
    });
  });

  group('the "This account" card', () {
    testWidgets(
      "reads 'Not registered as a child' when no own account lists the "
      'subject, and shows no Detach button',
      (tester) async {
        final api = _FakeApi(registrations: _emptyOkRegistrations);
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        expect(find.text('Not registered as a child'), findsOneWidget);
        expect(find.widgetWithText(GWButton, 'Detach'), findsNothing);

        await cubit.close();
      },
    );

    testWidgets(
      "reads 'Child of {main}' when another own account's OK list contains "
      'the subject, case-insensitively',
      (tester) async {
        final api = _FakeApi(
          registrations: _emptyOkRegistrations,
          otherRegistrations: {
            _otherOwnAddress.toLowerCase(): (
              result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
              entries: [
                ChildRegistration(
                  childAddress: _mainAddress.toUpperCase(),
                  mainAddress: _otherOwnAddress,
                  sequence: 0,
                ),
              ],
            ),
          },
        );
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        expect(find.text('Child of Parent Wallet'), findsOneWidget);
        expect(find.widgetWithText(GWButton, 'Detach'), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets(
      'a non-OK read from one own account is skipped, keeping the subject '
      'unregistered',
      (tester) async {
        final api = _FakeApi(
          registrations: _emptyOkRegistrations,
          otherRegistrations: {
            _otherOwnAddress.toLowerCase(): (
              result: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
              entries: const [
                ChildRegistration(
                  childAddress: _mainAddress,
                  mainAddress: _otherOwnAddress,
                  sequence: 0,
                ),
              ],
            ),
          },
        );
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        expect(find.text('Not registered as a child'), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets(
      'node down or a read error shows identity only -- no status line, no '
      'buttons',
      (tester) async {
        final api = _FakeApi(registrations: _queryErrorRegistrations);
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        expect(find.text('Not registered as a child'), findsNothing);
        expect(find.widgetWithText(GWButton, 'Detach'), findsNothing);

        await cubit.close();
      },
    );

    testWidgets(
      'Detach confirms the exact copy, sends empty metadata, and resolves '
      'once the old main no longer lists the subject',
      (tester) async {
        final api = _FakeApi(
          registrations: _emptyOkRegistrations,
          otherRegistrations: {
            _otherOwnAddress.toLowerCase(): (
              result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
              entries: const [
                ChildRegistration(
                  childAddress: _mainAddress,
                  mainAddress: _otherOwnAddress,
                  sequence: 0,
                ),
              ],
            ),
          },
        );
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        expect(find.text('Child of Parent Wallet'), findsOneWidget);
        await tester.tap(find.widgetWithText(GWButton, 'Detach'));
        await tester.pumpAndSettle();

        expect(find.text('Detach from main?'), findsOneWidget);
        expect(
          find.text(
            'Detach from Parent Wallet? Main Wallet will no longer be a '
            'child of Parent Wallet.',
          ),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(GWDialog),
            matching: find.widgetWithText(GWButton, 'Detach'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Detaching…'), findsOneWidget);

        // The real signal: an OK read of the old main no longer lists the
        // subject.
        api.otherRegistrations = {
          _otherOwnAddress.toLowerCase(): (
            result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
            entries: const <ChildRegistration>[],
          ),
        };
        await tester.tap(find.byTooltip('Refresh'));
        await tester.pumpAndSettle();

        expect(find.text('Detaching…'), findsNothing);
        expect(find.text('Not registered as a child'), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets(
      "reads 'Register as a child of…' when not registered, with no Detach "
      'button',
      (tester) async {
        final api = _FakeApi(registrations: _emptyOkRegistrations);
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        expect(
          find.widgetWithText(GWButton, 'Register as a child of…'),
          findsOneWidget,
        );
        expect(find.widgetWithText(GWButton, 'Detach'), findsNothing);

        await cubit.close();
      },
    );

    testWidgets(
      'Register picks a main from the picker, confirms the exact copy, '
      'sends empty metadata, and resolves once the chosen main lists the '
      'subject',
      (tester) async {
        final api = _FakeApi(registrations: _emptyOkRegistrations);
        final cubit = await _pumpScreen(
          tester,
          api: api,
          appState: _withOtherOwnAppState,
        );

        await tester.tap(
          find.widgetWithText(GWButton, 'Register as a child of…'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Parent Wallet'), findsOneWidget);
        await tester.tap(find.text('Parent Wallet'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(GWButton, 'Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Register as a child?'), findsOneWidget);
        expect(
          find.text(
            'Register Main Wallet as a child of Parent Wallet? Main Wallet '
            'will be controlled by Parent Wallet until detached.',
          ),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(GWDialog),
            matching: find.widgetWithText(GWButton, 'Register'),
          ),
        );
        await tester.pumpAndSettle();

        expect(api.registerCallCount, 1);
        expect(api.lastRegisteredMain, _otherOwnAddress);
        expect(api.lastRegisteredMetadata, const ChildRegistrationMetadata());
        expect(find.text('Registering…'), findsOneWidget);

        // The real signal: an OK read of the chosen main now lists the
        // subject.
        api.otherRegistrations = {
          _otherOwnAddress.toLowerCase(): (
            result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
            entries: const [
              ChildRegistration(
                childAddress: _mainAddress,
                mainAddress: _otherOwnAddress,
                sequence: 0,
              ),
            ],
          ),
        };
        await tester.tap(find.byTooltip('Refresh'));
        await tester.pumpAndSettle();

        expect(find.text('Registering…'), findsNothing);
        expect(find.text('Child of Parent Wallet'), findsOneWidget);

        await cubit.close();
      },
    );

    testWidgets('a pending Register locks the card button, tooltipped', (
      tester,
    ) async {
      final api = _FakeApi(registrations: _emptyOkRegistrations);
      final operations = ChildOperationsCubit(
        api: api,
        readAppState: () => _withOtherOwnAppState,
      );
      final cubit = ChildWalletsCubit(
        api: api,
        readAppState: () => _withOtherOwnAppState,
        mainAddress: _mainAddress,
      );

      operations.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherOwnAddress,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ChildWalletsCubit>.value(value: cubit),
              BlocProvider<ChildOperationsCubit>.value(value: operations),
            ],
            child: const ChildWalletsScreen(),
          ),
        ),
      );
      await tester.pump();

      final registerButton = tester.widget<GWButton>(
        find.widgetWithText(GWButton, 'Register as a child of…'),
      );
      expect(registerButton.onPressed, isNull);
      expect(
        find.byTooltip('Already registering this account'),
        findsOneWidget,
      );

      await cubit.close();
      await operations.close();
    });
  });

  group('minionsToGnus', () {
    final cases = <BigInt, String>{
      BigInt.zero: '0.000000',
      BigInt.one: '0.000001',
      BigInt.from(999999): '0.999999',
      BigInt.from(1000000): '1.000000',
      BigInt.from(1234567): '1.234567',
      (BigInt.one << 64) - BigInt.one: '18446744073709.551615',
    };

    cases.forEach((minions, expected) {
      test('$minions minions renders as exactly $expected', () {
        expect(minionsToGnus(minions), expected);
      });
    });
  });
}
