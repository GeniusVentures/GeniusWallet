import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/data/gw_row_badge.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/squid_router/squid_util.dart'
    show formatTokenAmount;
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// The present-participle phrase [op] shows while still pending.
String pendingText(ChildOperation op, String Function(String) labelFor) {
  switch (op.kind) {
    case ChildOperationKind.fund:
      return 'Funding ${formatTokenAmount(op.amountMinions!, 6)} GNUS…';
  }
}

/// The one-shot toast copy for [op] once its real resolution signal lands.
String resolvedText(ChildOperation op, String Function(String) labelFor) {
  switch (op.kind) {
    case ChildOperationKind.fund:
      final amount = formatTokenAmount(op.amountMinions!, 6);
      return 'Funded $amount GNUS to ${labelFor(op.target)}';
  }
}

/// The pending badge for one row. No spinner by construction: the write is
/// synchronous, so this badge IS the in-flight state.
class ChildOperationBadge extends StatelessWidget {
  const ChildOperationBadge({
    super.key,
    required this.op,
    required this.labelFor,
  });

  final ChildOperation op;
  final String Function(String) labelFor;

  @override
  Widget build(BuildContext context) {
    return GWRowBadge(
      label: pendingText(op, labelFor),
      color: context.gw.statusWarningText,
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
      listener: (context, state) {
        final toastContext = navigatorKey.currentContext;
        if (toastContext == null) {
          return;
        }
        final labelFor = context.read<ChildOperationsCubit>().labelFor;
        for (final op in state.justResolved) {
          showToast(
            toastContext,
            resolvedText(op, labelFor),
            type: ToastType.success,
          );
        }
      },
      child: child,
    );
  }
}
