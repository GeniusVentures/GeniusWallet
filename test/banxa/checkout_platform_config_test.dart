import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Android declares camera and microphone, camera optional', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    expect(manifest, contains('android.permission.CAMERA'));
    expect(manifest, contains('android.permission.RECORD_AUDIO'));
    expect(
      RegExp(
        r'<uses-feature\s+android:name="android.hardware.camera"\s+'
        r'android:required="false"\s*/>',
      ).hasMatch(manifest),
      isTrue,
    );
  });

  for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
    test('$path explains microphone and names the ID check for the camera', () {
      final plist = _read(path);
      expect(
        plist,
        contains(
          '<key>NSMicrophoneUsageDescription</key>\n'
          '\t<string>Banxa may record a short video to check your ID.</string>',
        ),
      );
      expect(
        RegExp(
          r'<key>NSCameraUsageDescription</key>\s*<string>[^<]*ID[^<]*</string>',
        ).hasMatch(plist),
        isTrue,
      );
    });
  }

  for (final name in ['DebugProfile', 'Release']) {
    test('macOS $name entitlements allow audio input', () {
      final entitlements = _read('macos/Runner/$name.entitlements');
      expect(
        RegExp(
          r'<key>com.apple.security.device.audio-input</key>\s*<true/>',
        ).hasMatch(entitlements),
        isTrue,
      );
    });
  }
}
