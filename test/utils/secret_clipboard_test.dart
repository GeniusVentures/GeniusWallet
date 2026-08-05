import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/secret_clipboard.dart';

/// The check owed by `scheduleSecretClipboardClear`.
///
/// Two properties matter and they pull against each other: the secret must be
/// gone when the window closes, and anything the user copied in the meantime
/// must survive. A clear that only did the first would be a data-loss bug
/// dressed as a security fix.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String? clipboardText;
  late int setDataCalls;

  setUp(() {
    clipboardText = null;
    setDataCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              setDataCalls++;
              clipboardText = (call.arguments as Map)['text'] as String?;
              return null;
            case 'Clipboard.getData':
              return <String, dynamic>{'text': clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('the secret is cleared once the window closes', (tester) async {
    clipboardText = 'ripple cabbage twelve word phrase';

    scheduleSecretClipboardClear(
      'ripple cabbage twelve word phrase',
      after: const Duration(seconds: 60),
    );

    // Still there before the window closes.
    await tester.pump(const Duration(seconds: 59));
    expect(clipboardText, 'ripple cabbage twelve word phrase');

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(clipboardText, isEmpty);
  });

  testWidgets('a value copied since is NOT destroyed', (tester) async {
    clipboardText = 'ripple cabbage twelve word phrase';
    scheduleSecretClipboardClear(
      'ripple cabbage twelve word phrase',
      after: const Duration(seconds: 60),
    );

    // The common case: the user copies something else before the timer fires.
    clipboardText = '0xSomeAddressTheUserCopiedAfterwards';
    setDataCalls = 0;

    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();

    expect(clipboardText, '0xSomeAddressTheUserCopiedAfterwards');
    expect(
      setDataCalls,
      0,
      reason: 'clearing unconditionally would destroy the user\'s own copy',
    );
  });

  testWidgets('an empty secret schedules nothing', (tester) async {
    clipboardText = 'untouched';
    scheduleSecretClipboardClear('', after: const Duration(seconds: 1));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(clipboardText, 'untouched');
    expect(setDataCalls, 0);
  });
}
