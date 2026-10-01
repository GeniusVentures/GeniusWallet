import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/data/gw_row_badge.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/squid_router/squid_util.dart'
    show formatTokenAmount;
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

String _amountText(ChildOperation op) =>
    '${formatTokenAmount(op.amountMinions!, 6)} GNUS';

/// The present-participle phrase [op] shows while still pending.
String pendingText(ChildOperation op, String Function(String) labelFor) {
  switch (op.kind) {
    case ChildOperationKind.fund:
      return 'Funding ${_amountText(op)}…';
    case ChildOperationKind.recover:
      return 'Recovering ${_amountText(op)}…';
    case ChildOperationKind.revoke:
      return 'Revoking…';
    case ChildOperationKind.detach:
      return 'Detaching…';
    case ChildOperationKind.register:
      return 'Registering…';
    case ChildOperationKind.move:
      return 'Moving to ${labelFor(op.newMain!)}…';
  }
}

/// The one-shot toast copy for [op] once its real resolution signal lands.
String resolvedText(ChildOperation op, String Function(String) labelFor) {
  switch (op.kind) {
    case ChildOperationKind.fund:
      return 'Funded ${_amountText(op)} to ${labelFor(op.target)}';
    case ChildOperationKind.recover:
      return 'Recovered ${_amountText(op)} from ${labelFor(op.target)}';
    case ChildOperationKind.revoke:
      return 'Revoked ${labelFor(op.target)}';
    case ChildOperationKind.detach:
      return 'Detached from ${labelFor(op.main)}';
    case ChildOperationKind.register:
      return 'Registered as a child of ${labelFor(op.main)}';
    case ChildOperationKind.move:
      return 'Moved to ${labelFor(op.newMain!)}';
  }
}

/// The pending, or timed-out, badge for one row. No spinner by construction:
/// the write is synchronous, so this badge IS the in-flight state. A
/// notConfirmed op adds a "Check again" button beside it.
class ChildOperationBadge extends StatelessWidget {
  const ChildOperationBadge({
    super.key,
    required this.op,
    required this.labelFor,
    required this.onCheckAgain,
  });

  final ChildOperation op;
  final String Function(String) labelFor;
  final VoidCallback onCheckAgain;

  @override
  Widget build(BuildContext context) {
    final badge = GWRowBadge(
      label: op.notConfirmed ? 'Not confirmed yet' : pendingText(op, labelFor),
      color: context.gw.statusWarningText,
    );
    if (!op.notConfirmed) {
      return badge;
    }
    // Wrap, not Row: a narrow row has no space beside the badge for a
    // button too, so this drops to a second line instead of overflowing.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: GeniusWalletConsts.space2,
      children: [
        badge,
        GWButton(
          label: 'Check again',
          variant: GWButtonVariant.ghost,
          size: GWButtonSize.sm,
          onPressed: onCheckAgain,
        ),
      ],
    );
  }
}

/// Fires one success toast per operation the registry just resolved, on the
/// ROOT navigator's context -- this sits above the router, so a fund still
/// toasts after the screen that started it has closed.
class ChildOperationToasts extends StatelessWidget {
  const ChildOperationToasts({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildOperationsCubit, ChildOperationsState>(
      listenWhen: (previous, current) => current.justResolved.isNotEmpty,
      listener: (context, state) => _toastWhenAttached(
        state.justResolved,
        context.read<ChildOperationsCubit>().labelFor,
      ),
      child: child,
    );
  }

  /// Toasts [ops] on the root navigator, or retries after the next frame
  /// while it isn't mounted yet -- this toast is the only place a
  /// resolution is ever announced, so it waits rather than drops it.
  void _toastWhenAttached(
    List<ChildOperation> ops,
    String Function(String) labelFor,
  ) {
    final toastContext = navigatorKey.currentContext;
    if (toastContext == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _toastWhenAttached(ops, labelFor),
      );
      return;
    }
    for (final op in ops) {
      showToast(
        toastContext,
        resolvedText(op, labelFor),
        type: ToastType.success,
      );
    }
  }
}
