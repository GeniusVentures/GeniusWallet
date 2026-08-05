import 'dart:async';

import 'package:flutter/services.dart';

/// How long a secret is allowed to sit on the clipboard before it is cleared.
///
/// 60s is the interval the mainstream password managers settled on: long
/// enough to switch windows and paste, short enough that the value is gone
/// before the next thing that reads the clipboard.
const Duration kSecretClipboardTtl = Duration(seconds: 60);

/// Clears a copied secret off the clipboard once its window has passed.
///
/// A recovery phrase copied to the clipboard otherwise stays there
/// indefinitely — readable by any other process, and on desktop often synced
/// into a clipboard history the user never thinks about. The copy itself is
/// already gated behind a confirmation dialog; this is the half that ends the
/// exposure.
///
/// **Why this is not just a timer.** On Android 10+ an app that does not have
/// focus can neither read nor write the clipboard
/// (developer.android.com/privacy-and-security/risks/secure-clipboard-handling).
/// A timer alone fires exactly when the user has switched to another app to
/// paste — so on the platform where it matters most it would silently do
/// nothing, which is worse than not shipping it: it looks like protection.
///
/// So the clear is attempted from two places: the timer (which is what
/// actually runs on desktop, and on mobile while the app is still in front),
/// and [clearDueSecretFromClipboard] on app resume (which is the first moment
/// mobile is allowed to touch the clipboard again). Whichever gets there first
/// wins; the other finds nothing pending.
abstract final class SecretClipboard {
  static String? _pending;
  static Timer? _timer;

  /// Visible for tests: whether a secret is still waiting to be cleared.
  static bool get hasPendingSecret => _pending != null;

  /// Arms the clear for [secret]. Call immediately after writing it.
  static void scheduleClear(
    String secret, {
    Duration after = kSecretClipboardTtl,
  }) {
    if (secret.isEmpty) {
      return;
    }
    _timer?.cancel();
    _pending = secret;
    _timer = Timer(after, clearNow);
  }

  /// Clears the pending secret if it is still on the clipboard.
  ///
  /// **Conditional on purpose.** It re-reads the clipboard and only clears
  /// when the contents are still the secret. Clearing unconditionally would
  /// destroy whatever the user copied in the meantime — the common case, since
  /// copying a seed phrase is usually followed by copying something else.
  ///
  /// A failed platform read leaves the secret PENDING rather than clearing
  /// blind: on Android that read fails precisely because the app is in the
  /// background, and the resume path will retry with focus. Clearing blind
  /// there would wipe the clipboard of an app the user is actively pasting
  /// into.
  static Future<void> clearNow() async {
    final secret = _pending;
    if (secret == null) {
      return;
    }
    try {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == secret) {
        await Clipboard.setData(const ClipboardData(text: ''));
      } else if (current == null) {
        // No focus (Android background). Stay pending for the resume path.
        return;
      }
      // Either cleared, or the user has copied something else since — both
      // mean this secret is no longer ours to worry about.
      _pending = null;
      _timer?.cancel();
      _timer = null;
    } catch (_) {
      // Unreadable clipboard: stay pending and retry on resume.
    }
  }

  /// Test seam: drop any pending secret without touching the clipboard.
  static void reset() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }
}

/// Arms the clipboard clear for [secret]. Call straight after the copy.
void scheduleSecretClipboardClear(
  String secret, {
  Duration after = kSecretClipboardTtl,
}) => SecretClipboard.scheduleClear(secret, after: after);

/// Clears a secret the timer could not reach. Called when the app resumes,
/// which on mobile is the first moment the clipboard is reachable again.
Future<void> clearDueSecretFromClipboard() => SecretClipboard.clearNow();
