import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/toast/secure_storage_failure_toasts.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

/// An import that hits a secure store which has just been blocked.
class _BlockedStoreApi implements GeniusApi {
  final failed = ValueNotifier(false);

  @override
  ValueListenable<bool> get secureStorageFailed => failed;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #validateWalletImport) {
      failed.value = true;
      return Future<bool>.error(const SecureStorageWriteError());
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  testWidgets('a blocked store shows the restart message, not the generic '
      'import error', (tester) async {
    final api = _BlockedStoreApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(extensions: [GWColors.dark()]),
        builder: (context, child) => SecureStorageFailureToasts(
          failed: api.secureStorageFailed,
          navigatorKey: navigatorKey,
          child: child!,
        ),
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
    await tester.enterText(find.byType(TextFormField).first, 'Savings');
    await tester.tap(find.text('Import'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(secureStorageFailedTitle), findsOneWidget);
    expect(find.text('Could not import wallet'), findsNothing);

    await tester.pump(const Duration(seconds: 10));
  });
}
