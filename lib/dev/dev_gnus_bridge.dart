import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_consent/gnus_prompts.dart';
import 'package:genius_wallet/submit_job/job_submission.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Fake origins for the dev bubble; `.invalid` can never resolve.
final GnusOrigin kDevGnusOrigin = GnusOrigin.parse(
  GnusTransport.webview,
  'https://dashboard.dev.invalid',
);
final GnusOrigin kDevGnusOtherOrigin = GnusOrigin.parse(
  GnusTransport.walletconnect,
  'https://other.dev.invalid',
);

const String kDevGnusNeedsFixture = 'Arm a JOB fixture first';

/// A made-up 130-character earning account for the spend preview.
final String kDevGnusEarningAccount = '0x${'ab' * 64}';

/// The toast text for [call]: `ok`, or the error code and its reason. Never a
/// result body.
Future<String> devGnusOutcome(Future<Object?> call) async {
  try {
    await call;
    return 'ok';
  } on GnusRpcError catch (e) {
    final reason = e.data?['reason'];
    return reason == null ? '${e.code}' : '${e.code} $reason';
  }
}

/// Submits a throwaway job as the dev origin, but only while a JOB fixture is
/// armed, so a dev button never burns real GNUS.
Future<String> devGnusSubmit(GnusRpcHandler handler) {
  if (!JobSubmission.devToolsEnabled ||
      DevMockJob.instance.scenario.value == null) {
    return Future.value(kDevGnusNeedsFixture);
  }
  return devGnusOutcome(
    handler.handle(kDevGnusOrigin, GnusRpcMethod.submitJob, {
      'job': {'dev': 'bridge'},
      'idempotencyKey': 'dev-${DateTime.now().microsecondsSinceEpoch}',
    }),
  );
}

/// Opens the spend drawer with fixture values and calls no handler, so nothing
/// can spend.
Future<bool> devGnusPreview(WalletDetailsState details) {
  final network = details.selectedNetwork;
  return showGnusSpendConfirm(
    origin: kDevGnusOrigin,
    cost: gnusCostBaseUnits(DevMockJob.jobCost) ?? '0',
    gas: {
      'gasPriceGwei': '1.00',
      'symbol': (network?.nativeSymbol ?? network?.symbol ?? 'POL')
          .toUpperCase(),
    },
    payer: details.selectedWallet?.address ?? '0x${'1' * 40}',
    nodeAccount: kDevGnusEarningAccount,
  );
}
