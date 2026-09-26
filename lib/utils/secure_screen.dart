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

  static void acquire() {
    _holders++;
    if (_holders == 1) {
      _set(true);
    }
  }

  static void release() {
    _holders--;
    if (_holders == 0) {
      _set(false);
    }
  }

  static void _set(bool secure) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    // A missing flag is weaker protection, not a failure the screen can act on.
    unawaited(
      _channel
          .invokeMethod<void>('setSecure', secure)
          .catchError((Object _) {}),
    );
  }
}

/// Holds [SecureWindow] for as long as [child] is in the tree.
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    SecureWindow.acquire();
  }

  @override
  void dispose() {
    SecureWindow.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
