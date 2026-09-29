import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';

/// How long a confirmed switch is given to land before this gives up and
/// tells the user nothing was sent. The node's account switch runs in a
/// background isolate and can take real seconds, so the delete flow's 3s
/// (a same-isolate list re-read) would misreport a real switch as failed.
const _switchTimeout = Duration(seconds: 30);

/// Guards every main-side action against running as the wrong account.
/// Returns true once the node runs as [requiredAccount] -- either because it
/// already did, or because the user confirmed a switch that then actually
/// landed.
Future<bool> ensureRunningAs(
  BuildContext context,
  String requiredAccount,
) async {
  final registry = context.read<ChildOperationsCubit>();
  final running = registry.runningAccount;
  if (running != null &&
      running.toLowerCase() == requiredAccount.toLowerCase()) {
    return true;
  }

  // Root navigator: survives the menu or card that triggered this action,
  // the same pattern every other dialog in this file family uses.
  final navigator = Navigator.of(context, rootNavigator: true);

  if (running != null && registry.hasPendingFrom(running)) {
    await GWDialog.show<void>(
      context: navigator.context,
      title: "Can't switch right now",
      message:
          'Waiting for a child operation from ${registry.labelFor(running)} '
          'to confirm.',
      actions: [GWDialogAction(label: 'OK', onPressed: () => navigator.pop())],
    );
    return false;
  }

  final requiredLabel = registry.labelFor(requiredAccount);
  final confirmed = await GWDialog.show<bool>(
    context: navigator.context,
    title: 'Switch to $requiredLabel?',
    message:
        'This action needs to run as $requiredLabel, not the account '
        'currently earning.',
    actions: [
      GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
      GWDialogAction(
        label: 'Switch and continue',
        variant: GWButtonVariant.primary,
        onPressed: () => navigator.pop(true),
      ),
    ],
  );

  // The ORIGINAL context, not the navigator's: `AppBloc` is provided as an
  // ancestor of the widget that called this, not of the root Navigator
  // itself, so a lookup from `navigator.context` would miss it.
  if (confirmed != true || !context.mounted) {
    return false;
  }

  final bloc = context.read<AppBloc>();
  if (bloc.state.selectedSDKAccount?.toLowerCase() ==
      requiredAccount.toLowerCase()) {
    return true;
  }

  final required = requiredAccount.toLowerCase();
  var started = bloc.state.switchingSDKAccount?.toLowerCase() == required;
  bloc.add(SelectSDKAccount(requiredAccount));
  showToast(
    // ignore: use_build_context_synchronously
    navigator.context,
    'Switching to $requiredLabel…',
  );

  // Lands only when the node reports the account. Once our switch has shown
  // up as pending, its end without that report is a refusal, not a wait.
  final landed = await bloc.stream
      .map<bool?>((s) {
        final switching = s.switchingSDKAccount?.toLowerCase();
        if (s.selectedSDKAccount?.toLowerCase() == required) {
          return true;
        }
        started = started || switching == required;
        return started && switching == null ? false : null;
      })
      .firstWhere((outcome) => outcome != null, orElse: () => false)
      .timeout(_switchTimeout, onTimeout: () => false);

  if (!navigator.context.mounted) {
    return false;
  }
  if (landed != true) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      "Couldn't switch earning to $requiredLabel. Nothing was sent.",
      type: ToastType.error,
    );
    return false;
  }
  return true;
}
