import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/mobile_header.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

Wallet _eth(String name, String address) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: address,
);

const _addrA = '0x1111111111111111111111111111111111111111';
const _addrB = '0x2222222222222222222222222222222222222222';

/// Only what a rename or delete reaches; anything else throws. `implements`
/// because the real constructor loads the native SDK.
class _RenameApi implements GeniusApi {
  _RenameApi({this.sgnusAccounts = const []});

  /// Stands in for the wallets that survive a delete: the seeded bloc's own
  /// wallet list is only filled by `LoadWallets`, the SGNUS merge is not.
  final List<String> sgnusAccounts;
  String? deleted;

  @override
  Future<void> renameWallet(String address, String newName) async {}

  @override
  Future<void> deleteWallet(String address) async {
    deleted = address;
  }

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() => Stream.value(
    SGNUSConnection(
      sgnusAddress: '',
      walletAddress: '',
      isConnected: sgnusAccounts.isNotEmpty,
    ),
  );

  @override
  String? getSelectedAccountAddress() => null;

  @override
  String? getStartAccountAddress() => null;

  @override
  List<String> getAvailableAccounts() => sgnusAccounts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.walletDetailsCubit,
    required List<Wallet> wallets,
  }) : super(
         transactionsCubit: TransactionsCubit(),
         networkProvider: NetworkProvider(),
       ) {
    emit(state.copyWith(wallets: wallets));
  }
}

Widget _drawerHost(WalletDetailsCubit cubit, AppBloc appBloc) =>
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>.value(value: cubit),
        BlocProvider<AppBloc>.value(value: appBloc),
      ],
      child: MaterialApp(
        theme: themeFor(GWAppearanceMode.dark),
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                const WalletPill(),
                TextButton(
                  onPressed: () => AccountDrawer.show(context),
                  child: const Text('open drawer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

Future<void> _tapDeleteOnFirstRow(WidgetTester tester) async {
  await tester.tap(find.text('open drawer'));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.more_vert).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();
}

Future<CircleAvatar> _pump(WidgetTester tester, Wallet wallet) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: themeFor(GWAppearanceMode.dark),
      home: WalletIdentityAvatar(wallet: wallet),
    ),
  );
  return tester.widget<CircleAvatar>(find.byType(CircleAvatar));
}

void main() {
  test('monogram rules, address-shaped names first', () {
    expect(walletMonogram('Super Genius Wallet 1'), 'S1');
    expect(walletMonogram('Super Genius Wallet 2'), 'S2');
    expect(walletMonogram('Wallet 10'), 'W10');
    expect(walletMonogram('Wallet 123'), 'W1');
    expect(walletMonogram('Main wallet'), 'MW');
    expect(walletMonogram('Savings'), 'SA');
    expect(walletMonogram('  '), isNull);
    expect(walletMonogram('0x7a3f9b2c0d3f6e21'), isNull);
    expect(
      walletMonogram('bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'),
      isNull,
    );
  });

  test('every identity fill meets AA with textOnBrand in both modes', () {
    for (final mode in GWAppearanceMode.values) {
      final gw = themeFor(mode).extension<GWColors>()!;
      for (final fill in GWColors.walletIdentityFills) {
        expect(contrastRatio(gw.textOnBrand, fill), greaterThanOrEqualTo(4.5));
        expect(
          contrastRatio(fill, gw.surfaceElevated),
          greaterThanOrEqualTo(3.0),
        );
      }
    }
  });

  testWidgets('two ETH wallets render different identities', (tester) async {
    // Pinned so a hash change, which would recolour every wallet, is noticed.
    expect(
      GWColors.walletIdentityFill(_addrA),
      GWColors.walletIdentityFills[0],
    );
    expect(
      GWColors.walletIdentityFill(_addrB),
      GWColors.walletIdentityFills[4],
    );
    expect(
      GWColors.walletIdentityFill(_addrA.toUpperCase()),
      GWColors.walletIdentityFill(_addrA),
    );
    expect(
      GWColors.walletIdentityFill(_addrA),
      isNot(GWColors.walletIdentityFill(_addrB)),
    );
    final a = await _pump(tester, _eth('Main wallet', _addrA));
    expect(find.text('MW'), findsOneWidget);
    final b = await _pump(tester, _eth('Savings', _addrB));
    expect(find.text('SA'), findsOneWidget);
    expect(a.backgroundColor, isNot(b.backgroundColor));
  });

  testWidgets('watch-only keeps its monogram and adds an eye badge', (
    tester,
  ) async {
    Wallet watched(String name) =>
        _eth(name, _addrA).copyWith(walletType: WalletType.tracking);

    await _pump(tester, watched('Cold storage'));
    expect(find.text('CS'), findsOneWidget);
    expect(find.byIcon(Icons.remove_red_eye_outlined), findsOneWidget);

    await _pump(tester, watched('Trading'));
    expect(find.text('TR'), findsOneWidget);

    // No monogram to show: the eye stays the disc's glyph.
    await _pump(tester, watched(_addrA));
    expect(find.byType(Text), findsNothing);
    expect(find.byIcon(Icons.remove_red_eye_outlined), findsOneWidget);
  });

  testWidgets('an address-shaped name falls back to the currency icon', (
    tester,
  ) async {
    await _pump(tester, _eth(_addrA, _addrA));
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('renaming the selected wallet updates the header disc', (
    tester,
  ) async {
    final wallet = _eth('Main wallet', _addrA);
    final api = _RenameApi();
    final cubit = _CountingCubit(
      initialState: WalletDetailsState(selectedWallet: wallet),
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final appBloc = _SeededAppBloc(
      api: api,
      walletDetailsCubit: cubit,
      wallets: [wallet],
    );
    try {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WalletDetailsCubit>.value(value: cubit),
            BlocProvider<AppBloc>.value(value: appBloc),
          ],
          child: MaterialApp(
            theme: themeFor(GWAppearanceMode.dark),
            home: Scaffold(
              body: Builder(
                builder: (context) => Column(
                  children: [
                    const WalletPill(),
                    TextButton(
                      onPressed: () => AccountDrawer.show(context),
                      child: const Text('open drawer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('MW'), findsOneWidget);

      await tester.tap(find.text('open drawer'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Savings');
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      expect(cubit.state.selectedWallet?.walletName, 'Savings');
      expect(cubit.fetches, 0, reason: 'a rename must not refetch holdings');
      expect(find.text('SA'), findsOneWidget);
      expect(find.text('MW'), findsNothing);
    } finally {
      await tester.runAsync(() => appBloc.close());
      await cubit.close();
    }
  });

  test('after a delete, an own wallet is picked before an SDK account', () {
    final sdk = _eth(
      'Super Genius Wallet',
      _addrB,
    ).copyWith(walletType: WalletType.sgnus);
    final own = _eth('Savings', _addrA);
    // SDK accounts are listed first, so "first" alone would pick one.
    expect(AppBloc.replacementWallet([sdk, own]), own);
    expect(AppBloc.replacementWallet([sdk]), sdk);
  });

  group('deleting from the drawer', () {
    late Box box;
    setUp(() async {
      // In-memory backend: real disk I/O never completes inside testWidgets.
      box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
    });
    tearDown(() => box.close());

    testWidgets('deleting the selected wallet deletes it and selects another', (
      tester,
    ) async {
      final main = _eth('Main wallet', _addrA);
      final api = _RenameApi(sgnusAccounts: [_addrB]);
      final cubit = _CountingCubit(
        initialState: WalletDetailsState(selectedWallet: main),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final appBloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: cubit,
        wallets: [main, _eth('Savings', _addrB)],
      );
      try {
        await tester.pumpWidget(_drawerHost(cubit, appBloc));
        expect(find.text('MW'), findsOneWidget);

        await _tapDeleteOnFirstRow(tester);
        expect(find.text('Delete wallet'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(api.deleted, _addrA);
        expect(cubit.state.selectedWallet?.address, _addrB);
        expect(box.get(selectedWalletKey), _addrB);
        expect(box.get(selectedWalletTypeKey), WalletType.sgnus.name);
        expect(find.text('MW'), findsNothing);
      } finally {
        await tester.runAsync(() => appBloc.close());
        await cubit.close();
      }
    });

    testWidgets('the desktop selector follows a delete of the selected '
        'wallet', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final main = _eth('Main wallet', _addrA);
      // The survivor comes from the SDK merge; see _RenameApi.
      final api = _RenameApi(sgnusAccounts: [_addrB]);
      final cubit = _CountingCubit(
        initialState: WalletDetailsState(selectedWallet: main),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final appBloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: cubit,
        wallets: [main, _eth('Savings', _addrB)],
      );
      try {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WalletDetailsCubit>.value(value: cubit),
              BlocProvider<AppBloc>.value(value: appBloc),
            ],
            child: MaterialApp(
              theme: themeFor(GWAppearanceMode.dark),
              home: const Scaffold(body: AccountDropdownSelector()),
            ),
          ),
        );
        expect(find.text(WalletUtils.getAddressForDisplay(_addrA)), findsOne);

        appBloc.add(DeleteWallet(_addrA));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();

        expect(find.text('Super Genius'), findsOne);
        expect(
          find.text(WalletUtils.getAddressForDisplay(_addrA)),
          findsNothing,
        );
      } finally {
        await tester.runAsync(() => appBloc.close());
        await cubit.close();
      }
    });

    testWidgets('the last own wallet cannot be deleted even with an SDK '
        'account connected', (tester) async {
      final main = _eth('Main wallet', _addrA);
      final sdk = _eth(
        'Super Genius Wallet',
        _addrB,
      ).copyWith(walletType: WalletType.sgnus);
      final api = _RenameApi(sgnusAccounts: [_addrB]);
      final cubit = _CountingCubit(
        initialState: WalletDetailsState(selectedWallet: main),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final appBloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: cubit,
        wallets: [sdk, main],
      );
      try {
        // Straight to the bloc: the rule must hold even if a UI skips it.
        appBloc.add(DeleteWallet(_addrA));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        expect(api.deleted, isNull);
        expect(cubit.state.selectedWallet, main);
      } finally {
        await tester.runAsync(() => appBloc.close());
        await cubit.close();
      }
    });

    testWidgets('deleting a local wallet keeps a selected SDK account that '
        'shares its address', (tester) async {
      final local = _eth('Main wallet', _addrA);
      final other = _eth('Savings', _addrB);
      final sdkSameKey = _eth(
        'Super Genius Wallet',
        _addrA,
      ).copyWith(walletType: WalletType.sgnus);
      final api = _RenameApi(sgnusAccounts: [_addrA]);
      final cubit = _CountingCubit(
        initialState: WalletDetailsState(selectedWallet: sdkSameKey),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final appBloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: cubit,
        wallets: [sdkSameKey, local, other],
      );
      try {
        appBloc.add(DeleteWallet(_addrA));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        expect(api.deleted, _addrA);
        expect(cubit.state.selectedWallet, sdkSameKey);
      } finally {
        await tester.runAsync(() => appBloc.close());
        await cubit.close();
      }
    });

    group('restoring the selection', () {
      final local = _eth('Main wallet', _addrA);
      final sdkSameKey = _eth(
        'Super Genius Wallet',
        _addrA,
      ).copyWith(walletType: WalletType.sgnus);
      // SDK accounts are listed first, as the SGNUS merge orders them.
      final wallets = [sdkSameKey, local, _eth('Savings', _addrB)];

      test('matches the stored type when an SDK account shares the '
          'address', () async {
        await box.put(selectedWalletKey, _addrA);
        await box.put(selectedWalletTypeKey, WalletType.privateKey.name);
        expect(WalletDetailsCubit.restoreSelectedWallet(wallets), local);

        await box.put(selectedWalletTypeKey, WalletType.sgnus.name);
        expect(WalletDetailsCubit.restoreSelectedWallet(wallets), sdkSameKey);
      });

      test('without a stored type, the local wallet wins', () async {
        await box.put(selectedWalletKey, _addrA);
        expect(WalletDetailsCubit.restoreSelectedWallet(wallets), local);
      });

      test('nothing stored restores the first wallet', () {
        expect(WalletDetailsCubit.restoreSelectedWallet(wallets), sdkSameKey);
      });
    });

    testWidgets('the last wallet cannot be deleted', (tester) async {
      final main = _eth('Main wallet', _addrA);
      final api = _RenameApi();
      final cubit = _CountingCubit(
        initialState: WalletDetailsState(selectedWallet: main),
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final appBloc = _SeededAppBloc(
        api: api,
        walletDetailsCubit: cubit,
        wallets: [main],
      );
      try {
        await tester.pumpWidget(_drawerHost(cubit, appBloc));

        await _tapDeleteOnFirstRow(tester);
        expect(find.text('You must keep at least one wallet.'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(api.deleted, isNull);
        expect(cubit.state.selectedWallet, main);
        expect(find.text('MW'), findsOneWidget);
      } finally {
        await tester.runAsync(() => appBloc.close());
        await cubit.close();
      }
    });
  });
}

class _CountingCubit extends WalletDetailsCubit {
  _CountingCubit({
    required super.initialState,
    required super.geniusApi,
    required super.networkTokensProvider,
  });

  int fetches = 0;

  @override
  FutureOr<void> getCoins() async {
    fetches++;
  }
}
