import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';

const secureStorageFailedTitle = 'Secure storage is not reliable';
const secureStorageFailedMessage =
    "This device's secure storage is not keeping data reliably, so nothing "
    'more can be saved. Keep your recovery phrase, fix the keyring, then '
    'restart the app.';

/// Whether secure storage has been blocked for this session. A flow with its
/// own error toast checks this so the user sees only the message below.
bool isSecureStorageFailed(GeniusApi api) => api.secureStorageFailed.value;

/// Tells the user, once, when secure storage becomes unusable, whichever
/// flow (onboarding, import, PIN, rename, delete) hit it.
class SecureStorageFailureToasts extends StatefulWidget {
  const SecureStorageFailureToasts({
    super.key,
    required this.failed,
    required this.navigatorKey,
    required this.child,
  });

  final ValueListenable<bool> failed;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<SecureStorageFailureToasts> createState() =>
      _SecureStorageFailureToastsState();
}

class _SecureStorageFailureToastsState
    extends State<SecureStorageFailureToasts> {
  @override
  void initState() {
    super.initState();
    widget.failed.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.failed.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!widget.failed.value) {
      return;
    }
    _toastWhenAttached();
  }

  void _toastWhenAttached() {
    final toastContext = widget.navigatorKey.currentContext;
    if (toastContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toastWhenAttached());
      return;
    }
    showToast(
      toastContext,
      secureStorageFailedMessage,
      title: secureStorageFailedTitle,
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
