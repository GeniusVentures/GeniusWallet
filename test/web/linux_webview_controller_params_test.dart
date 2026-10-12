import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

const _root = 'com.abandoft.webview_all_linux';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <String>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(const MethodChannel(_root), (
      call,
    ) async {
      calls.add('root:${call.method}');
      return call.method == 'createWebView' ? 7 : null;
    });
    messenger.setMockMethodCallHandler(const MethodChannel('$_root/7'), (
      call,
    ) async {
      calls.add(call.method);
      return null;
    });
    messenger.setMockMethodCallHandler(
      const MethodChannel('$_root/7/events'),
      (_) async => null,
    );
  });

  tearDown(() {
    for (final name in [_root, '$_root/7', '$_root/7/events']) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  test(
    'creation params are applied and a later call still completes',
    () async {
      final controller = LinuxWebViewController(
        const LinuxWebViewControllerCreationParams(zoomFactor: 1.5),
      );

      await controller.reload().timeout(const Duration(seconds: 5));

      expect(calls, containsAllInOrder(['applySettings', 'reload']));
      await controller.dispose();
    },
  );
}
