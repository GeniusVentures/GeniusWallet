// The import screen's phrase and private-key tabs hold live key material.
// They must render obscured with a show/hide control, like the keystore
// password already does — the keystore JSON and the watch-address field are
// not secrets and stay readable.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class _IdleApi implements GeniusApi {
  final failed = ValueNotifier(false);

  @override
  ValueListenable<bool> get secureStorageFailed => failed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _mount(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: BlocProvider(
          create: (_) => ExistingWalletBloc(geniusApi: _IdleApi()),
          child: const ImportSecurityScreen(
            walletType: 'Ethereum',
            coinType: TWCoinType.TWCoinTypeEthereum,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _tabField(String tabLabel) {
  final field = find.descendant(
    of: find.byType(PasteField),
    matching: find.byType(TextFormField),
  );
  // On the phrase tab there is exactly one PasteField; other tabs need the
  // TabBarView switched first.
  expect(
    find.text(tabLabel),
    findsOneWidget,
    reason: 'the $tabLabel tab must be reachable',
  );
  return field;
}

bool _obscured(WidgetTester tester, Finder field) {
  final editable = tester.widget<EditableText>(
    find.descendant(of: field, matching: find.byType(EditableText)),
  );
  return editable.obscureText;
}

Future<void> _goToTab(WidgetTester tester, String label) async {
  // The tab strip is scrollable inside the onboarding column, so the right
  //most tabs (Keystore, Address) sit off-screen at the test viewport and a
  // bare tap would miss.
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the phrase field is obscured until shown', (tester) async {
    await _mount(tester);
    final field = _tabField('Phrase');

    await tester.enterText(field, 'word one word two word three');
    expect(_obscured(tester, field), isTrue);

    await tester.tap(find.byTooltip('Show'));
    await tester.pump();
    expect(_obscured(tester, field), isFalse);

    await tester.tap(find.byTooltip('Hide'));
    await tester.pump();
    expect(_obscured(tester, field), isTrue);
  });

  testWidgets('the private key field is obscured until shown', (tester) async {
    await _mount(tester);
    await _goToTab(tester, 'Private Key');
    final field = _tabField('Private Key');

    await tester.enterText(field, '0x${'ab' * 32}');
    expect(_obscured(tester, field), isTrue);

    await tester.tap(find.byTooltip('Show'));
    await tester.pump();
    expect(_obscured(tester, field), isFalse);
  });

  testWidgets('the keystore password stays obscured, its JSON stays '
      'readable', (tester) async {
    await _mount(tester);
    await _goToTab(tester, 'Keystore');

    // Scoped to the keystore tab: the wallet Name field on the same screen
    // is a TextFormField too and stays out of this assertion.
    final fields = find.descendant(
      of: find.byType(KeystoreTabView),
      matching: find.byType(TextFormField),
    );
    expect(fields, findsNWidgets(2));

    expect(_obscured(tester, fields.first), isFalse);
    expect(_obscured(tester, fields.at(1)), isTrue);
  });

  testWidgets('the watch-address field stays readable', (tester) async {
    await _mount(tester);
    await _goToTab(tester, 'Address');
    final field = _tabField('Address');

    await tester.enterText(field, '0x1111111111111111111111111111111111111111');
    expect(_obscured(tester, field), isFalse);
    expect(find.byTooltip('Show'), findsNothing);
    expect(find.byTooltip('Hide'), findsNothing);
  });
}
