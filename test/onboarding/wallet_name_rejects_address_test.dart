// A pasted 0x address must not become a wallet's name: the header pill shows
// the name alone, so an address-shaped name reads as a rendering bug.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

const _address = '0x71C7656EC7ab88b098defB751B7401B5f6d8976F';

/// Records import attempts; everything else is unreachable from this screen.
class _RecordingApi implements GeniusApi {
  final importedNames = <String>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #validateWalletImport) {
      importedNames.add(invocation.namedArguments[#walletName] as String);
      return Future<bool>.value(false);
    }
    return super.noSuchMethod(invocation);
  }
}

Future<_RecordingApi> _submitName(WidgetTester tester, String name) async {
  final api = _RecordingApi();
  // The form is taller than the default 800x600 test surface.
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: BlocProvider(
          create: (_) => ExistingWalletBloc(geniusApi: api),
          child: const ImportSecurityScreen(
            walletType: 'Ethereum',
            coinType: TWCoinType.TWCoinTypeEthereum,
          ),
        ),
      ),
    ),
  );
  await tester.enterText(find.byType(TextFormField).first, name);
  await tester.tap(find.text('Import'));
  await tester.pump();
  return api;
}

void main() {
  group('walletNameError', () {
    test('rejects empty and address-shaped names', () {
      expect(walletNameError(null), isNotNull);
      expect(walletNameError('   '), isNotNull);
      expect(walletNameError(_address), isNotNull);
      expect(walletNameError(' ${_address.toLowerCase()} '), isNotNull);
      expect(walletNameError('0X${_address.substring(2)}'), isNotNull);
    });

    test('accepts ordinary names, including ones that start with 0x', () {
      expect(walletNameError('Savings'), isNull);
      expect(walletNameError('0x hot wallet'), isNull);
    });
  });

  testWidgets('import refuses an address as the wallet name', (tester) async {
    final api = await _submitName(tester, _address);

    expect(find.text(walletNameIsAddressMessage), findsOneWidget);
    expect(api.importedNames, isEmpty);
  });

  testWidgets('import still accepts an ordinary name', (tester) async {
    final api = await _submitName(tester, 'Savings');

    expect(find.text(walletNameIsAddressMessage), findsNothing);
    expect(api.importedNames, ['Savings']);
  });

  testWidgets('import stores the name trimmed', (tester) async {
    final api = await _submitName(tester, '  Savings  ');

    expect(api.importedNames, ['Savings']);
  });
}
