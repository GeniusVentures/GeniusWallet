import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/dapp_call_details.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';

const _connectWarning =
    'This site will see your earning account, paying wallet and jobs. It '
    'cannot spend: you approve every job.';

const _spendWarning =
    'Approving burns this GNUS from your paying wallet to run the job. It '
    'cannot be undone.';

/// Closes its own route after [kGnusConfirmTimeout], the moment the handler
/// gives up on the prompt, so a late tap can never look like consent.
class _ClosesWithHandler extends StatefulWidget {
  const _ClosesWithHandler({required this.child});

  final Widget child;

  @override
  State<_ClosesWithHandler> createState() => _ClosesWithHandlerState();
}

class _ClosesWithHandlerState extends State<_ClosesWithHandler> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(kGnusConfirmTimeout, _close);
  }

  void _close() {
    if (!mounted) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route != null) {
      // Not pop: another route may sit above this one.
      Navigator.of(context).removeRoute(route);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Asks whether [origin] may use the bridge, in a drawer on the root
/// navigator. Only Approve answers true; a dismissal, or no navigator, is a
/// decline.
Future<bool> showGnusConnectPrompt({required GnusOrigin origin}) async {
  final context = navigatorKey.currentContext;
  if (context == null) {
    return false;
  }
  // No icon: nothing a page supplies is drawn on a consent prompt.
  final answer = await ApproveTransactionDrawer.show(
    context: context,
    // A fixed title: the title bar cuts text to one line, and a look-alike
    // origin must be read whole, so the origin is the wrapping headline.
    title: 'Connect a site',
    dappName: origin.value,
    dappUrl: origin.value,
    content: _ClosesWithHandler(
      child: DappCallDetails(
        headline: origin.value,
        warning: _connectWarning,
        rows: [DappCallRow(label: 'Through', value: origin.transport.label)],
      ),
    ),
  );
  return answer == true;
}

/// The [GnusConfirm] seam: shows what a submit costs and who pays, and
/// answers true only on Approve. A cost that does not parse is a decline.
Future<bool> showGnusSpendConfirm({
  required GnusOrigin origin,
  required String cost,
  required Map<String, String>? gas,
  required String payer,
  required String nodeAccount,
}) async {
  final context = navigatorKey.currentContext;
  final amount = BigInt.tryParse(cost);
  if (context == null || amount == null || amount.isNegative) {
    return false;
  }
  final gasPrice = gas == null
      ? 'Not available'
      : '${gas['gasPriceGwei']} Gwei (${gas['symbol']})';
  final answer = await ApproveTransactionDrawer.show(
    context: context,
    title: 'Pay for a processing job',
    dappName: origin.value,
    dappUrl: origin.value,
    content: _ClosesWithHandler(
      child: DappCallDetails(
        headline: '${formatTokenAmount(amount, kGnusDecimals)} GNUS',
        warning: _spendWarning,
        rows: [
          DappCallRow(label: 'Bridge gas', value: gasPrice),
          DappCallRow(label: 'Through', value: origin.transport.label),
          DappCallRow(label: 'Paying wallet', value: payer, copyable: true),
          DappCallRow(
            label: 'Earning account',
            value: nodeAccount,
            copyable: true,
          ),
        ],
      ),
    ),
  );
  return answer == true;
}
