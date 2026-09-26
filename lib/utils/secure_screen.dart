import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Android's FLAG_SECURE, held while anything showing a recovery phrase is
/// mounted: it blanks screenshots, screen recordings and the recents preview.
/// Android only, as MetaMask does; iOS has no equivalent short of hiding it.
abstract final class SecureWindow {
  static const _channel = MethodChannel('ai.gnus.genius_wallet/platform');

  /// Counted, not a bool: a flow swaps one seed screen for the next by mounting
  /// the new one before disposing the old, and a bool would clear it there.
  static int _holders = 0;
  static Future<void> _secured = Future.value();

  /// True once Android has confirmed the flag for the current holders.
  static bool get isSecured => _isSecured;
  static bool _isSecured = false;

  static bool get applies =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Completes once the flag is in place, or once setting it has failed.
  static Future<void> acquire() {
    _holders++;
    if (_holders == 1) {
      _secured = _set(true).then((_) {
        _isSecured = _holders > 0;
      });
    }
    return _secured;
  }

  static void release() {
    _holders--;
    if (_holders == 0) {
      _isSecured = false;
      unawaited(_set(false));
    }
  }

  static Future<void> _set(bool secure) {
    if (!applies) {
      return Future.value();
    }
    // Fails open: a missing flag is weaker protection, but hiding the phrase
    // for good would lock the user out of backing up their wallet.
    return _channel
        .invokeMethod<void>('setSecure', secure)
        .catchError((Object _) {});
  }
}

/// Holds [SecureWindow] for as long as [child] is in the tree, and shows
/// [child] only once the flag is in place so no frame is captured before it.
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  late bool _shown;

  @override
  void initState() {
    super.initState();
    _shown = !SecureWindow.applies || SecureWindow.isSecured;
    final secured = SecureWindow.acquire();
    if (!_shown) {
      secured.then((_) {
        if (mounted) {
          setState(() => _shown = true);
        }
      });
    }
  }

  @override
  void dispose() {
    SecureWindow.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _shown ? widget.child : const SizedBox.shrink();
}
