import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/dapp_call_details.dart';

const _connectWarning =
    'This site will see your earning account, paying wallet and jobs. It '
    'cannot spend: you approve every job.';

/// Asks whether [origin] may use the bridge, in a drawer on the root
/// navigator. Only Approve answers true; a dismissal, or no navigator, is a
/// decline.
Future<bool> showGnusConnectPrompt({required String origin}) async {
  final context = navigatorKey.currentContext;
  if (context == null) {
    return false;
  }
  // No icon: nothing a page supplies is drawn on a consent prompt.
  final answer = await ApproveTransactionDrawer.show(
    context: context,
    title: origin,
    dappName: origin,
    dappUrl: origin,
    content: const DappCallDetails(
      headline: 'Connect this site?',
      warning: _connectWarning,
      rows: [],
    ),
  );
  return answer == true;
}
