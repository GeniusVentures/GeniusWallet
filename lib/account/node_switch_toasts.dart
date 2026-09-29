import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

/// Tells the user when a node account switch ended without the node running
/// as that account, on the ROOT navigator's context so it still shows after
/// the switcher that asked for it has closed.
class NodeSwitchToasts extends StatefulWidget {
  const NodeSwitchToasts({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<NodeSwitchToasts> createState() => _NodeSwitchToastsState();
}

class _NodeSwitchToastsState extends State<NodeSwitchToasts> {
  String? _target;

  void _onSwitchChanged(BuildContext context, AppState state) {
    final target = _target;
    _target = state.switchingSDKAccount;
    if (target == null ||
        state.switchingSDKAccount != null ||
        state.selectedSDKAccount?.toLowerCase() == target.toLowerCase()) {
      return;
    }
    final name = AppBloc.sdkAccountName(
      target,
      state.sdkAccountLinks,
      state.wallets,
    );
    final label = name == 'Unlinked'
        ? WalletUtils.getAddressForDisplay(target)
        : name;
    _toastWhenAttached("The node couldn't switch to $label.");
  }

  void _toastWhenAttached(String message) {
    final toastContext = widget.navigatorKey.currentContext;
    if (toastContext == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _toastWhenAttached(message),
      );
      return;
    }
    showToast(toastContext, message, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) =>
          previous.switchingSDKAccount != current.switchingSDKAccount,
      listener: _onSwitchChanged,
      child: widget.child,
    );
  }
}
