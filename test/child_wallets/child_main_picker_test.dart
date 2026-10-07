// Proves isSdkAddress's exact address-shape check, and the main picker
// dialog: list/manual mode, exclusion, live validation, the empty-list
// fallback, and Back keeping the earlier pick.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_main_picker_dialog.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

const _accountAddress = '0x1111111111111111111111111111111111aaaa';
const _linkedAddress = '0x2222222222222222222222222222222222bbbb';
const _unlinkedAddress = '0x3333333333333333333333333333333333cccc';
const _excludedAddress = '0x4444444444444444444444444444444444dddd';

final _validAddress = '0x${''.padLeft(128, 'a')}';

/// A valid SGNUS-shaped address, but not [_validAddress] -- for the case an
/// excluded typed address must first pass the shape check to reach the
/// "can't be chosen" error rather than the shape error.
final _excludedSgnusAddress = '0x${''.padLeft(128, 'b')}';

const _linkedWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Other Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _linkedAddress,
);

const _appState = AppState(
  selectedSDKAccount: _accountAddress,
  sdkAccounts: [_accountAddress, _linkedAddress, _unlinkedAddress],
  wallets: [_linkedWallet],
  sdkAccountLinks: {
    _linkedAddress: (walletAddress: _linkedAddress, walletName: 'Other Wallet'),
  },
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// The picker makes no SDK call of its own, so this fake exists only to
/// satisfy [ChildOperationsCubit]'s constructor.
class _FakeApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps a button that opens the picker and stashes its result in [result]
/// once the dialog resolves -- [result] is read after the test's own
/// interactions close the dialog.
Future<void> _pumpPicker(
  WidgetTester tester, {
  required List<String> candidates,
  required Set<String> excluded,
  required void Function(String?) onResult,
  AppState appState = _appState,
}) async {
  final operations = ChildOperationsCubit(
    api: _FakeApi(),
    readAppState: () => appState,
  );
  addTearDown(operations.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: BlocProvider<ChildOperationsCubit>.value(
        value: operations,
        child: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final chosen = await showMainPicker(
                  context,
                  title: 'Register as a child of…',
                  candidates: candidates,
                  excluded: excluded,
                );
                onResult(chosen);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('isSdkAddress', () {
    test('0x plus 128 lowercase hex characters is valid', () {
      expect(isSdkAddress(_validAddress), isTrue);
    });

    test('uppercase hex is valid', () {
      expect(isSdkAddress('0x${''.padLeft(128, 'A')}'), isTrue);
    });

    test('mixed-case hex is valid', () {
      final mixed = List.generate(128, (i) => i.isEven ? 'a' : 'A').join();
      expect(isSdkAddress('0x$mixed'), isTrue);
    });

    test('surrounding whitespace is trimmed before the check', () {
      expect(isSdkAddress('  $_validAddress  '), isTrue);
    });

    test('a 42-character EVM address is not valid here', () {
      expect(isSdkAddress('0x${''.padLeft(40, 'a')}'), isFalse);
    });

    test('127 hex characters is not valid', () {
      expect(isSdkAddress('0x${''.padLeft(127, 'a')}'), isFalse);
    });

    test('129 hex characters is not valid', () {
      expect(isSdkAddress('0x${''.padLeft(129, 'a')}'), isFalse);
    });

    test('a non-hex character is not valid', () {
      expect(isSdkAddress('0x${'g'.padLeft(128, 'a')}'), isFalse);
    });

    test('missing the 0x prefix is not valid', () {
      expect(isSdkAddress(''.padLeft(128, 'a')), isFalse);
    });
  });

  group('the main picker', () {
    testWidgets(
      'lists candidates minus excluded as name-or-Unlinked over the short '
      'address, Continue disabled until a pick',
      (tester) async {
        String? result;
        await _pumpPicker(
          tester,
          candidates: [_linkedAddress, _unlinkedAddress, _excludedAddress],
          excluded: {_excludedAddress},
          onResult: (chosen) => result = chosen,
        );

        expect(find.text('Other Wallet'), findsOneWidget);
        expect(find.text('Unlinked'), findsOneWidget);
        expect(
          find.text(WalletUtils.getAddressForDisplay(_linkedAddress)),
          findsOneWidget,
        );
        expect(
          find.text(WalletUtils.getAddressForDisplay(_unlinkedAddress)),
          findsOneWidget,
        );
        expect(
          find.text(WalletUtils.getAddressForDisplay(_excludedAddress)),
          findsNothing,
        );

        final continueButton = tester.widget<GWButton>(
          find.widgetWithText(GWButton, 'Continue'),
        );
        expect(continueButton.onPressed, isNull);

        await tester.tap(find.text('Other Wallet'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(GWButton, 'Continue'));
        await tester.pumpAndSettle();

        expect(result, _linkedAddress);
      },
    );

    testWidgets('Cancel returns null', (tester) async {
      String? result = 'unset';
      await _pumpPicker(
        tester,
        candidates: [_linkedAddress],
        excluded: {},
        onResult: (chosen) => result = chosen,
      );

      await tester.tap(find.widgetWithText(GWButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets(
      'with no other SDK accounts, shows the empty line and manual entry '
      'is still reachable',
      (tester) async {
        await _pumpPicker(
          tester,
          candidates: const [],
          excluded: const {},
          onResult: (_) {},
        );

        expect(
          find.text(
            'You have no other earning accounts. Enter an address instead.',
          ),
          findsOneWidget,
        );
        expect(find.text('Enter an address'), findsOneWidget);

        await tester.tap(find.text('Enter an address'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'a valid, non-excluded typed address enables Continue and returns it '
      'trimmed',
      (tester) async {
        String? result;
        await _pumpPicker(
          tester,
          candidates: [_linkedAddress],
          excluded: {_excludedAddress},
          onResult: (chosen) => result = chosen,
        );

        await tester.tap(find.text('Enter an address'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '  $_validAddress  ');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(GWButton, 'Continue'));
        await tester.pumpAndSettle();

        expect(result, _validAddress);
      },
    );

    testWidgets('an invalid typed address shows the SGNUS error', (
      tester,
    ) async {
      await _pumpPicker(
        tester,
        candidates: const [],
        excluded: const {},
        onResult: (_) {},
      );

      await tester.tap(find.text('Enter an address'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0xnotanaddress');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Not an earning account address - 0x followed by 128 hex characters.',
        ),
        findsOneWidget,
      );
      final continueButton = tester.widget<GWButton>(
        find.widgetWithText(GWButton, 'Continue'),
      );
      expect(continueButton.onPressed, isNull);
    });

    testWidgets(
      "an excluded typed address shows \"That account can't be chosen "
      'here."',
      (tester) async {
        await _pumpPicker(
          tester,
          candidates: const [],
          excluded: {_excludedSgnusAddress},
          onResult: (_) {},
        );

        await tester.tap(find.text('Enter an address'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), _excludedSgnusAddress);
        await tester.pumpAndSettle();

        expect(find.text("That account can't be chosen here."), findsOneWidget);
        final continueButton = tester.widget<GWButton>(
          find.widgetWithText(GWButton, 'Continue'),
        );
        expect(continueButton.onPressed, isNull);
      },
    );

    testWidgets("'‹ Back' returns to the list keeping the earlier pick", (
      tester,
    ) async {
      String? result;
      await _pumpPicker(
        tester,
        candidates: [_linkedAddress, _unlinkedAddress],
        excluded: const {},
        onResult: (chosen) => result = chosen,
      );

      await tester.tap(find.text('Other Wallet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enter an address'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GWButton, '‹ Back'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(GWButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(result, _linkedAddress);
    });
  });
}
