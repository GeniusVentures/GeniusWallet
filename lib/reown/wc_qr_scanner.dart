import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera scanner for WalletConnect `wc:` pairing QR codes.
///
/// Returns the scanned `wc:` URI string via [Navigator.pop], or `null` if the
/// user cancels.
///
/// NOTE: requires the camera permission / entitlement to be configured
/// natively (macOS `NSCameraUsageDescription` + the camera entitlement, iOS
/// `NSCameraUsageDescription`, Android `CAMERA`). See HANDOFF.md — this is not
/// testable in the UI-only stub build.
class WcQrScanner extends StatefulWidget {
  const WcQrScanner({super.key});

  /// Opens the scanner and resolves to the scanned `wc:` URI (or null).
  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const WcQrScanner(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<WcQrScanner> createState() => _WcQrScannerState();
}

class _WcQrScannerState extends State<WcQrScanner> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.startsWith('wc:')) {
        _handled = true;
        Navigator.of(context).pop(raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Scan to connect'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Reticle.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                    color: GeniusWalletColors.brandPrimary, width: 2),
                borderRadius:
                    BorderRadius.circular(GeniusWalletConsts.radiusXl),
              ),
            ),
          ),
          Positioned(
            left: GeniusWalletConsts.space8,
            right: GeniusWalletConsts.space8,
            bottom: GeniusWalletConsts.space24,
            child: Text(
              'Point at a WalletConnect QR code on the dApp',
              textAlign: TextAlign.center,
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: Colors.white.withAlpha(200)),
            ),
          ),
        ],
      ),
    );
  }
}
