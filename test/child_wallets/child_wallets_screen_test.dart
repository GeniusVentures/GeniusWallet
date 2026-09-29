// Proves the read-only child-wallets screen against a fake API: the header
// names the main account, each child shows its linked name or "Unlinked"
// plus its own address, balances render exact, and rows keep the SDK's own
// order.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _linkedChildAddress = '0x2222222222222222222222222222222222bbbb';
const _unlinkedChildAddress = '0x3333333333333333333333333333333333cccc';

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

const _links = <String, SDKAccountLink>{
  _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
  _linkedChildAddress: (
    walletAddress: _linkedChildAddress,
    walletName: 'Game Wallet',
  ),
};

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _FakeApi implements GeniusApi {
  _FakeApi({required this.registrations, required this.balances});

  final ChildRegistrations registrations;
  final Map<String, BigInt> balances;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) => registrations;

  @override
  BigInt getChildBalanceAll(String childAddress) =>
      balances[childAddress] ?? BigInt.zero;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ChildRegistrations registrations,
  required Map<String, BigInt> balances,
  GWColors? colors,
}) async {
  final api = _FakeApi(registrations: registrations, balances: balances);
  final cubit = ChildWalletsCubit(
    api: api,
    readAppState: () => const AppState(
      selectedSDKAccount: _mainAddress,
      sdkAccounts: [_mainAddress],
      wallets: [_mainWallet, _childWallet],
      sdkAccountLinks: _links,
    ),
    mainAddress: _mainAddress,
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
      home: BlocProvider<ChildWalletsCubit>.value(
        value: cubit,
        child: const ChildWalletsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const registrations = (
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
  final balances = <String, BigInt>{
    _linkedChildAddress: BigInt.from(1234567),
    _unlinkedChildAddress: BigInt.from(999999),
  };

  final appearances = {'dark': GWColors.dark(), 'light': GWColors.light()};

  for (final appearance in appearances.entries) {
    testWidgets('renders the main, each child and their balances in '
        '${appearance.key} appearance', (tester) async {
      await _pumpScreen(
        tester,
        registrations: registrations,
        balances: balances,
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
    });
  }

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
