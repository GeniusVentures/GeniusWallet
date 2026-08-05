import 'dart:async';

import 'package:flutter/services.dart';

/// How long a secret is allowed to sit on the clipboard before it is cleared.
///
/// 60s is the interval the mainstream password managers settled on: long
/// enough to switch windows and paste, short enough that the value is gone
/// before the next thing that reads the clipboard.
const Duration kSecretClipboardTtl = Duration(seconds: 60);

/// Clears [secret] off the clipboard after [after], if it is still there.
///
/// A recovery phrase copied to the clipboard otherwise stays there
/// indefinitely — readable by any other process on the machine, and on desktop
/// often synced into a clipboard history the user never thinks about. The copy
/// itself is already gated behind a confirmation dialog; this is the other
/// half, the part that ends the exposure.
///
/// **Conditional on purpose.** It re-reads the clipboard and only clears when
/// the contents are still the secret. Clearing unconditionally would destroy
/// whatever the user copied in the meantime — the common case, since copying a
/// seed phrase is usually followed by copying something else.
///
/// Fire-and-forget: callers do not await it, and a failed platform read is
/// swallowed rather than surfaced. A clipboard that cannot be read is a
/// clipboard this cannot safely clear, and there is nothing useful to tell the
/// user at that point.
///
/// ponytail: an in-process timer, so it does not survive the app being killed
/// inside the window — the secret then stays on the clipboard until something
/// overwrites it. Ceiling: process lifetime. Upgrade path: a platform-side
/// clipboard expiry, which neither Windows nor macOS offers today.
void scheduleSecretClipboardClear(
  String secret, {
  Duration after = kSecretClipboardTtl,
}) {
  if (secret.isEmpty) {
    return;
  }
  Timer(after, () async {
    try {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == secret) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } catch (_) {
      // Unreadable clipboard: nothing safe to clear, nothing useful to say.
    }
  });
}
