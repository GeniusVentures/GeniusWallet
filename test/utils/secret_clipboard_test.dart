import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/secret_clipboard.dart';

/// The check owed by `SecretClipboard`.
///
/// Three properties, and they pull against each other:
///  - the secret must be gone once its window has passed;
///  - anything the user copied since must survive (a clear that only did the
///    first would be a data-loss bug dressed as a security fix);
///  - and on Android the clipboard is simply unreachable while the app is in
///    the background, so a clear that gives up there would silently protect
///    nothing on the platform that needs it most.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String? clipboardText;
  late int setDataCalls;
  // Android 10+: an app without focus can neither read nor write the
  // clipboard. `Clipboard.getData` comes back null, which is NOT the same as
  // "the clipboard is empty".
  late bool appHasFocus;

  setUp(() {
    clipboardText = null;
    setDataCalls = 0;
    appHasFocus = true;
    SecretClipboard.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              if (!appHasFocus) {
                return null;
              }
              setDataCalls++;
              clipboardText = (call.arguments as Map)['text'] as String?;
              return null;
            case 'Clipboard.getData':
              if (!appHasFocus) {
                return null;
              }
              return <String, dynamic>{'text': clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    SecretClipboard.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  const phrase = 'ripple cabbage twelve word phrase';

  testWidgets('the secret is cleared once the window closes', (tester) async {
    clipboardText = phrase;
    scheduleSecretClipboardClear(phrase, after: const Duration(seconds: 60));

    await tester.pump(const Duration(seconds: 59));
    expect(clipboardText, phrase);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(clipboardText, isEmpty);
    expect(SecretClipboard.hasPendingSecret, isFalse);
  });

  testWidgets('a value copied since is NOT destroyed', (tester) async {
    clipboardText = phrase;
    scheduleSecretClipboardClear(phrase, after: const Duration(seconds: 60));

    clipboardText = '0xSomeAddressTheUserCopiedAfterwards';
    setDataCalls = 0;

    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();

    expect(clipboardText, '0xSomeAddressTheUserCopiedAfterwards');
    expect(
      setDataCalls,
      0,
      reason: "clearing blind would destroy the user's own copy",
    );
  });

  testWidgets('backgrounded on Android: stays pending, clears on resume', (
    tester,
  ) async {
    clipboardText = phrase;
    scheduleSecretClipboardClear(phrase, after: const Duration(seconds: 60));

    // The user switches to another app to paste. This is the ONLY moment the
    // timer ever fires in practice, and the platform refuses both calls.
    appHasFocus = false;
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();

    expect(clipboardText, phrase, reason: 'no focus, so nothing could happen');
    expect(
      SecretClipboard.hasPendingSecret,
      isTrue,
      reason:
          'giving up here is what made the timer-only version a no-op on '
          'Android — the secret must stay armed for the resume path',
    );

    // Back in the app: first moment the clipboard is reachable again.
    appHasFocus = true;
    await clearDueSecretFromClipboard();

    expect(clipboardText, isEmpty);
    expect(SecretClipboard.hasPendingSecret, isFalse);
  });

  testWidgets('resume with nothing pending is a no-op', (tester) async {
    clipboardText = 'something the user copied';
    await clearDueSecretFromClipboard();

    expect(clipboardText, 'something the user copied');
    expect(setDataCalls, 0);
  });

  testWidgets('an empty secret arms nothing', (tester) async {
    clipboardText = 'untouched';
    scheduleSecretClipboardClear('', after: const Duration(seconds: 1));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(clipboardText, 'untouched');
    expect(setDataCalls, 0);
    expect(SecretClipboard.hasPendingSecret, isFalse);
  });
}
