import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/secure_screen.dart';

/// The secure flag must be on while any seed screen is mounted, stay on when
/// one seed screen replaces another, and come off once the last one leaves.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('ai.gnus.genius_wallet/platform');
  late List<Object?> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'setSecure') {
            calls.add(call.arguments);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Android: set on enter, kept across a swap, cleared on leave', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(
      const SecureScreen(key: Key('a'), child: SizedBox()),
    );
    expect(calls, [true]);

    // A flow swapping one seed screen for the next.
    await tester.pumpWidget(
      const SecureScreen(key: Key('b'), child: SizedBox()),
    );
    expect(calls, [true]);

    await tester.pumpWidget(const SizedBox());
    expect(calls, [true, false]);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS: never touches the window', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(const SecureScreen(child: SizedBox()));
    await tester.pumpWidget(const SizedBox());
    expect(calls, isEmpty);

    debugDefaultTargetPlatformOverride = null;
  });
}
