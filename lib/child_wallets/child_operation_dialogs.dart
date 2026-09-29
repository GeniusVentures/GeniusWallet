import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' show GeniusNodeReturnValue;
import 'package:genius_wallet/child_wallets/child_main_picker_dialog.dart';
import 'package:genius_wallet/child_wallets/child_operation_switch_dialog.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet, minionsToGnus;
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// Shows the SDK's refusal reason for [kind]'s [verb] -- shared by every
/// main-side action so the wording only differs by the one clause the
/// UI-SPEC actually varies.
void _showRefusalToast(
  BuildContext context,
  GeniusNodeReturnValue result,
  String verb,
) {
  showToast(context, "Couldn't $verb.", type: ToastType.error);
}

/// Opens the Fund dialog for [child], paid from [mainAddress]. Every write
/// goes through the registry -- this file never calls the SDK directly.
Future<void> startFund(
  BuildContext context, {
  required ChildWallet child,
  required String mainAddress,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  if (!await ensureRunningAs(context, mainAddress) || !context.mounted) {
    return;
  }
  // The poll can be up to 10 s behind, so an earlier fund or recover that
  // has since landed resolves here and lifts the child's lock first.
  registry.resolve();
  // Root navigator, not a route pop: the MenuAnchor this is called from
  // closes itself on selection -- there is no drawer route to close here.
  final navigator = Navigator.of(context, rootNavigator: true);
  final barrierColor = context.gw.surfaceOverlay;
  final mainName = registry.labelFor(mainAddress);
  final childName = registry.labelFor(child.address);

  final amount = await showDialog<BigInt>(
    // ignore: use_build_context_synchronously
    context: navigator.context,
    barrierColor: barrierColor,
    builder: (_) => _AmountDialog(
      registry: registry,
      kind: ChildOperationKind.fund,
      target: child.address,
      title: 'Fund $childName',
      fromToSentence: 'From $mainName to $childName.',
      payerLabel: mainName,
      primaryLabel: 'Fund',
    ),
  );

  if (amount == null) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.fund,
    target: child.address,
    main: mainAddress,
    amountMinions: amount,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    // ignore: use_build_context_synchronously
    _showRefusalToast(navigator.context, result, 'fund this child');
  }
  // OK: no toast here -- the pending badge is the feedback, and the success
  // toast only fires once the registry's own resolve() sees the real signal.
}

/// Opens the Recover dialog for [child], paid to [mainAddress]. Same shape
/// as [startFund], mirrored the other direction.
Future<void> startRecover(
  BuildContext context, {
  required ChildWallet child,
  required String mainAddress,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  if (!await ensureRunningAs(context, mainAddress) || !context.mounted) {
    return;
  }
  registry.resolve();
  final navigator = Navigator.of(context, rootNavigator: true);
  final barrierColor = context.gw.surfaceOverlay;
  final mainName = registry.labelFor(mainAddress);
  final childName = registry.labelFor(child.address);

  final amount = await showDialog<BigInt>(
    // ignore: use_build_context_synchronously
    context: navigator.context,
    barrierColor: barrierColor,
    builder: (_) => _AmountDialog(
      registry: registry,
      kind: ChildOperationKind.recover,
      target: child.address,
      title: 'Recover from $childName',
      fromToSentence: 'From $childName to $mainName.',
      payerLabel: childName,
      primaryLabel: 'Recover',
    ),
  );

  if (amount == null) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.recover,
    target: child.address,
    main: mainAddress,
    amountMinions: amount,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    // ignore: use_build_context_synchronously
    _showRefusalToast(navigator.context, result, 'recover from this child');
  }
}

/// Opens the Revoke confirmation for [child], run as [mainAddress]. No
/// amount -- a destructive confirm, then a plain submit.
Future<void> startRevoke(
  BuildContext context, {
  required ChildWallet child,
  required String mainAddress,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  if (!await ensureRunningAs(context, mainAddress) || !context.mounted) {
    return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final mainName = registry.labelFor(mainAddress);
  final childName = registry.labelFor(child.address);

  final confirmed = await GWDialog.show<bool>(
    // ignore: use_build_context_synchronously
    context: navigator.context,
    title: 'Revoke child?',
    message: 'Revoke $childName? It will no longer be a child of $mainName.',
    actions: [
      GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
      GWDialogAction(
        label: 'Revoke',
        variant: GWButtonVariant.destructive,
        onPressed: () => navigator.pop(true),
      ),
    ],
  );

  if (confirmed != true) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.revoke,
    target: child.address,
    main: mainAddress,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    // ignore: use_build_context_synchronously
    _showRefusalToast(navigator.context, result, 'revoke this child');
  }
}

/// Opens the Detach confirmation for [account], the node's own account,
/// currently registered under [main]. Runs on the child's own node, so
/// [ensureRunningAs] guards the node into running as [account] itself, not
/// [main].
Future<void> startDetach(
  BuildContext context, {
  required String account,
  required String main,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  if (!await ensureRunningAs(context, account) || !context.mounted) {
    return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final mainName = registry.labelFor(main);
  final accountName = registry.labelFor(account);

  final confirmed = await GWDialog.show<bool>(
    // ignore: use_build_context_synchronously
    context: navigator.context,
    title: 'Detach from main?',
    message:
        'Detach from $mainName? $accountName will no longer be a child of '
        '$mainName.',
    actions: [
      GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
      GWDialogAction(
        label: 'Detach',
        variant: GWButtonVariant.destructive,
        onPressed: () => navigator.pop(true),
      ),
    ],
  );

  if (confirmed != true) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.detach,
    target: account,
    main: main,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    // ignore: use_build_context_synchronously
    _showRefusalToast(navigator.context, result, 'detach this account');
  }
}

/// Opens the main picker for [account], the node's own account, then the
/// Register confirmation for the chosen main. Child-side, like [startDetach].
Future<void> startRegister(
  BuildContext context, {
  required String account,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  if (!await ensureRunningAs(context, account) || !context.mounted) {
    return;
  }
  final accountName = registry.labelFor(account);

  // The original context, not the navigator's: showMainPicker reads the
  // registry itself, and only the original context is a descendant of
  // where the registry is provided -- showDialog's own useRootNavigator
  // still anchors the dialog at the app root regardless.
  final main = await showMainPicker(
    // ignore: use_build_context_synchronously
    context,
    title: 'Register as a child of…',
    candidates: registry.ownAccounts,
    excluded: {account},
  );

  if (main == null || !context.mounted) {
    return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final mainName = registry.labelFor(main);

  final confirmed = await GWDialog.show<bool>(
    // ignore: use_build_context_synchronously
    context: navigator.context,
    title: 'Register as a child?',
    message:
        'Register $accountName as a child of $mainName? $accountName will '
        'be controlled by $mainName until detached.',
    actions: [
      GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
      GWDialogAction(
        label: 'Register',
        variant: GWButtonVariant.primary,
        onPressed: () => navigator.pop(true),
      ),
    ],
  );

  if (confirmed != true) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.register,
    target: account,
    main: main,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    // ignore: use_build_context_synchronously
    _showRefusalToast(navigator.context, result, 'register this account');
  }
}

/// Opens the main picker for [account], the node's own account currently
/// registered under [oldMain], then the Move confirmation for the chosen new
/// main. Child-side, like [startDetach] and [startRegister].
Future<void> startMove(
  BuildContext context, {
  required String account,
  required String oldMain,
}) async {
  final registry = context.read<ChildOperationsCubit>();
  if (!await ensureRunningAs(context, account) || !context.mounted) {
    return;
  }
  final accountName = registry.labelFor(account);

  final newMain = await showMainPicker(
    // ignore: use_build_context_synchronously
    context,
    title: 'Move to another main',
    candidates: registry.ownAccounts,
    excluded: {account, oldMain},
  );

  if (newMain == null || !context.mounted) {
    return;
  }
  final navigator = Navigator.of(context, rootNavigator: true);
  final oldMainName = registry.labelFor(oldMain);
  final newMainName = registry.labelFor(newMain);

  final confirmed = await GWDialog.show<bool>(
    // ignore: use_build_context_synchronously
    context: navigator.context,
    title: 'Move to another main?',
    message:
        'Move to $newMainName? $accountName will no longer be a child of '
        '$oldMainName.',
    content: const GWWarningNote(
      'The child keeps its current balance; nothing is transferred by this action.',
    ),
    actions: [
      GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
      GWDialogAction(
        label: 'Move',
        variant: GWButtonVariant.destructive,
        onPressed: () => navigator.pop(true),
      ),
    ],
  );

  if (confirmed != true) {
    return;
  }

  final result = registry.submit(
    kind: ChildOperationKind.move,
    target: account,
    main: oldMain,
    newMain: newMain,
  );

  if (!navigator.context.mounted) {
    return;
  }
  if (result == null) {
    showToast(
      // ignore: use_build_context_synchronously
      navigator.context,
      'Nothing was sent. Try again.',
      type: ToastType.error,
    );
    return;
  }
  if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
    // ignore: use_build_context_synchronously
    _showRefusalToast(navigator.context, result, 'move this account');
  }
}

/// The Fund/Recover confirmation, shaped like `sdk_account_manager.dart`'s
/// `_AddAccountDialog`: a private `StatefulWidget` building `GWDialog` itself
/// so the amount field's error text can update live. Parameterized by
/// [kind]/[title]/[fromToSentence]/[payerLabel]/[primaryLabel] rather than
/// copied, since Fund and Recover differ only in those five values.
class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.registry,
    required this.kind,
    required this.target,
    required this.title,
    required this.fromToSentence,
    required this.payerLabel,
    required this.primaryLabel,
  });

  final ChildOperationsCubit registry;
  final ChildOperationKind kind;
  final String target;
  final String title;
  final String fromToSentence;
  final String payerLabel;
  final String primaryLabel;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Rebuilds on every registry emit: a fund or recover on this child that
  // starts while the dialog is open locks it here too, not only at submit.
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChildOperationsCubit, ChildOperationsState>(
        bloc: widget.registry,
        builder: (context, _) {
          final balance = widget.registry.payingBalance(
            widget.kind,
            widget.target,
          );
          final lockReason = widget.registry.balanceLockReason(widget.target);

          return GWDialog(
            title: widget.title,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fromToSentence),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWTextField(
                  controller: _controller,
                  label: 'Amount',
                  hint: '0.0',
                  errorText: _error,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('GNUS'),
                      const SizedBox(width: GeniusWalletConsts.space4),
                      GWButton(
                        label: 'MAX',
                        variant: GWButtonVariant.ghost,
                        size: GWButtonSize.sm,
                        onPressed: () => setState(() {
                          _controller.text = minionsToGnus(balance);
                          _error = null;
                        }),
                      ),
                    ],
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
                if (lockReason != null) ...[
                  const SizedBox(height: GeniusWalletConsts.space6),
                  GWWarningNote(lockReason),
                ],
              ],
            ),
            actions: [
              GWDialogAction(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              GWDialogAction(
                label: widget.primaryLabel,
                variant: GWButtonVariant.primary,
                onPressed: lockReason != null
                    ? null
                    : () {
                        final parsed = parseGnusAmount(
                          _controller.text,
                          balanceMinions: balance,
                          payer: widget.payerLabel,
                        );
                        if (parsed.minions == null) {
                          setState(() => _error = parsed.error);
                          return;
                        }
                        Navigator.of(context).pop(parsed.minions);
                      },
              ),
            ],
          );
        },
      );
}
