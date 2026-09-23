// RecipientField in isolation: paste, the self-send warning, and (later
// tasks) the contract warning and scan gating -- send_screen_test.dart
// covers the field wired into the full form.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/send/recipient_field.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _walletAddress = '0x1111111111111111111111111111111111111111';
const _otherAddress = '0x2222222222222222222222222222222222222222';

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _maticCoin = Coin(symbol: 'matic', balance: 10);

class _NoopStorage implements TransactionStorageService {
  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// `hasCode` is left unimplemented on purpose: a throw is the field's own
/// "leave the contract flag false" case, exercised once that call exists.
class _FakeApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

String? _clipboardText;

Future<SendCubit> _pump(WidgetTester tester, {String? errorText}) async {
  final cubit = SendCubit(
    api: _FakeApi(),
    walletAddress: _walletAddress,
    network: _amoy,
    transactions: TransactionsCubit(),
    storage: _NoopStorage(),
    initialCoin: _maticCoin,
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    BlocProvider<SendCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(body: RecipientField(errorText: errorText)),
      ),
    ),
  );
  await tester.pump();
  return cubit;
}

void main() {
  setUp(() {
    _clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': _clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('pasting the wallet address fills the field and shows the '
      'self-send note', (tester) async {
    _clipboardText = _walletAddress;
    final cubit = await _pump(tester);

    await tester.tap(find.widgetWithText(GWButton, 'Paste'));
    await tester.pump();

    expect(cubit.state.recipient, _walletAddress);
    expect(find.textContaining('This is your own address'), findsOneWidget);
  });

  testWidgets('pasting a different address shows no self-send note', (
    tester,
  ) async {
    _clipboardText = _otherAddress;
    final cubit = await _pump(tester);

    await tester.tap(find.widgetWithText(GWButton, 'Paste'));
    await tester.pump();

    expect(cubit.state.recipient, _otherAddress);
    expect(find.textContaining('This is your own address'), findsNothing);
  });

  testWidgets(
    'a passed-in errorText shows under the field when the format check has '
    'nothing to say',
    (tester) async {
      await _pump(tester, errorText: 'Enter an amount to send.');

      expect(find.text('Enter an amount to send.'), findsOneWidget);
    },
  );

  testWidgets("the field's own format error wins over a passed-in errorText", (
    tester,
  ) async {
    final cubit = await _pump(tester, errorText: 'Enter an amount to send.');
    cubit.setRecipient('not-an-address');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a 0x address of 40 hex characters.'),
      findsOneWidget,
    );
    expect(find.text('Enter an amount to send.'), findsNothing);
  });
}
