// The rename dialog's Rename action must stay disabled until the field holds
// a trimmed, non-empty name that differs from the wallet's current one — an
// unchanged submit used to be dropped silently by the dialog's caller and
// read as the app ignoring the user.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

const _address = '0xaaaa1111';

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main A',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _address,
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
  @override
  List<String> getAvailableAccounts() => const [];

  @override
  String? getSelectedAccountAddress() => null;

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => const {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

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
        sdkAccounts: const [_address],
        wallets: const [_wallet],
        sdkAccountLinks: {
          _address: (walletAddress: _address, walletName: 'Main A'),
        },
        selectedSDKAccount: _address,
      ),
    );
  }
}

Future<(_SeededAppBloc, WalletDetailsCubit)> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final api = _Api();
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
  return (bloc, details);
}

void main() {
  testWidgets('rename stays disabled until the name actually changes', (
    tester,
  ) async {
    final (bloc, details) = await _pump(tester);

    await tester.tap(find.byTooltip('Account options'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Rename'));
    await tester.pumpAndSettle();

    final field = find.descendant(
      of: find.byType(GWDialog),
      matching: find.byType(TextField),
    );
    expect(field, findsOneWidget);
    // The field opens holding the wallet's current name.
    expect(
      find.descendant(of: find.byType(GWDialog), matching: find.text('Main A')),
      findsOneWidget,
    );

    Finder renameButton() => find.widgetWithText(GWButton, 'Rename');
    bool enabled() => tester.widget<GWButton>(renameButton()).onPressed != null;

    // Unchanged name, whitespace-only name, and back to the current name all
    // leave the action disabled; only a real change enables it.
    expect(enabled(), isFalse, reason: 'unchanged prefilled name');

    await tester.enterText(field, 'Main B');
    await tester.pump();
    expect(enabled(), isTrue, reason: 'a genuinely new name');

    await tester.enterText(field, '   ');
    await tester.pump();
    expect(enabled(), isFalse, reason: 'whitespace-only name');

    await tester.enterText(field, 'Main A');
    await tester.pump();
    expect(enabled(), isFalse, reason: 'back to the current name');

    await tester.enterText(field, 'Main B');
    await tester.pump();
    expect(enabled(), isTrue, reason: 'edited back to a new name');

    await tester.runAsync(() => bloc.close());
    await details.close();
  });
}
