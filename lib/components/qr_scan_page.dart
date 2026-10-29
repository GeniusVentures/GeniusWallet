import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Whether this platform has a `mobile_scanner` camera backend -- it has
/// none on Windows or Linux, so a Scan button is hidden rather than shown
/// disabled or crashing on tap.
bool get defaultCanScanQr => !(Platform.isWindows || Platform.isLinux);

/// A full-screen camera view that pops with the first detection's raw value.
/// `onDetect` keeps firing while the camera is open, so each callback checks
/// the route is still current -- a second detection would otherwise pop twice.
class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  /// Opens the camera and returns the first code's raw text, or null when the
  /// user backs out.
  static Future<String?> scan(BuildContext context) => Navigator.of(
    context,
  ).push<String>(MaterialPageRoute(builder: (_) => const QrScanPage()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a QR code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
            return;
          }
          final barcodes = capture.barcodes;
          final raw = barcodes.isEmpty ? null : barcodes.first.rawValue;
          if (raw != null) {
            Navigator.of(context).pop(raw);
          }
        },
      ),
    );
  }
}
