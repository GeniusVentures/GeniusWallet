import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' show GeniusNodeReturnValue;
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
      return 'Funding ${_amountText(op)}';
    case ChildOperationKind.recover:
      return 'Recovering ${_amountText(op)}';
    case ChildOperationKind.revoke:
      return 'Revoking';
    case ChildOperationKind.detach:
      return 'Detaching';
    case ChildOperationKind.register:
      return 'Registering';
    case ChildOperationKind.move:
      return 'Moving to ${labelFor(op.newMain!)}';
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

/// The pending, or timed-out, badge for one row. A notConfirmed op adds
/// "Check again"; a stale one offers "Try again" and "Dismiss" instead.
// No spinner while pending: the write is synchronous, so the badge is the
// in-flight state.
class ChildOperationBadge extends StatefulWidget {
  const ChildOperationBadge({
    super.key,
    required this.op,
    required this.registry,
  });

  final ChildOperation op;
  final ChildOperationsCubit registry;

  @override
  State<ChildOperationBadge> createState() => _ChildOperationBadgeState();
}

class _ChildOperationBadgeState extends State<ChildOperationBadge> {
  bool _checking = false;

  Future<void> _checkAgain() async {
    setState(() => _checking = true);
    // The read is synchronous FFI: let the spinner paint before it blocks.
    await WidgetsBinding.instance.endOfFrame;
    widget.registry.resolve();
    // Judged on this op alone: another op resolving must not hide the message,
    // and going stale changes the badge itself.
    final stillWaiting = widget.registry.state.operations.any(
      (o) =>
          o.submittedAt == widget.op.submittedAt &&
          o.kind == widget.op.kind &&
          o.target == widget.op.target &&
          !o.stale,
    );
    if (!mounted) {
      return;
    }
    setState(() => _checking = false);
    if (stillWaiting) {
      showToast(context, 'Still waiting for the network.');
    }
  }

  void _retry() {
    // Never auto-resubmitted: the first write may still land late.
    if (widget.registry.retry(widget.op) !=
        GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      showToast(
        context,
        'Nothing was sent. Check your connection and try again.',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.op;
    final badge = GWRowBadge(
      label: op.stale
          ? 'This may not have reached the network.'
          : op.notConfirmed
          ? 'Not confirmed yet'
          : pendingText(op, widget.registry.labelFor),
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
        if (op.stale) ...[
          GWButton(
            label: 'Try again',
            variant: GWButtonVariant.ghost,
            size: GWButtonSize.sm,
            onPressed: _retry,
          ),
          GWButton(
            label: 'Dismiss',
            variant: GWButtonVariant.ghost,
            size: GWButtonSize.sm,
            onPressed: () => widget.registry.dismiss(op),
          ),
        ] else
          GWButton(
            label: 'Check again',
            variant: GWButtonVariant.ghost,
            size: GWButtonSize.sm,
            isLoading: _checking,
            onPressed: _checking ? null : _checkAgain,
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
