// The add-account dialog used to accept an empty or malformed secret and then
// report "Account added successfully" whatever the SDK said. Two rules pinned:
// Add stays disabled until the repository calls the input valid, and a refusal
// from the SDK is reported as one.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

const _validPhrase = 'a valid phrase';

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _RefusingApi implements GeniusApi {
  int addCalls = 0;

  @override
  bool isValidMnemonic(String mnemonic) => mnemonic == _validPhrase;

  @override
  bool isValidPrivateKey(String privateKeyHex) => false;

  @override
  GeniusNodeReturnValue addAccountWithMnemonic(String mnemonic) {
    addCalls++;
    return GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT;
  }

  @override
  String? getSelectedAccountMnemonic() => null;

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
    emit(state.copyWith(sdkAccounts: const ['0xAAAA']));
  }
}

GWButton _addButton(WidgetTester tester) =>
    tester.widget<GWButton>(find.widgetWithText(GWButton, 'Add account').last);

void main() {
  testWidgets('Add is gated on validity and a refusal is not a success', (
    tester,
  ) async {
    final api = _RefusingApi();
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
    );
    try {
      await tester.pumpWidget(
        BlocProvider<AppBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
            home: const Scaffold(body: SDKAccountManagerButton()),
          ),
        ),
      );
      await tester.tap(find.byType(SDKAccountManagerButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();

      expect(_addButton(tester).onPressed, isNull, reason: 'empty input');
      await tester.enterText(find.byType(TextField), 'not a phrase');
      await tester.pump();
      expect(_addButton(tester).onPressed, isNull, reason: 'malformed input');

      await tester.enterText(find.byType(TextField), _validPhrase);
      await tester.pump();
      expect(_addButton(tester).onPressed, isNotNull);

      await tester.tap(find.widgetWithText(GWButton, 'Add account').last);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));

      expect(api.addCalls, 1);
      expect(find.text('The SDK did not add that account.'), findsOneWidget);
      expect(find.textContaining('added successfully'), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    } finally {
      await tester.runAsync(() => bloc.close());
      await details.close();
    }
  });
}
