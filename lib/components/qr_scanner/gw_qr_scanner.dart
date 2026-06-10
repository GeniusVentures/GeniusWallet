import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Extracts a bare wallet address from a scanned QR payload.
///
/// Address QRs come in several shapes — plain (`0xAbC…`, `bc1q…`), EIP-681
/// (`ethereum:0xAbC…@1?value=…`, incl. the `pay-` form), BIP-21
/// (`bitcoin:bc1q…?amount=…`) and other `<scheme>:<address>` URIs. This strips
/// the scheme, the EIP-681 chain id (`@1`) / function path (`/transfer`) and
/// any query params, returning just the address. Plain payloads pass through
/// trimmed.
String extractWalletAddress(String raw) {
  var s = raw.trim();
  // A URI scheme starts with a letter — a plain `0x…` address never matches.
  final scheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').firstMatch(s);
  if (scheme != null) s = s.substring(scheme.end);
  if (s.startsWith('pay-')) s = s.substring(4);
  for (final cut in ['@', '?', '/']) {
    final i = s.indexOf(cut);
    if (i >= 0) s = s.substring(0, i);
  }
  return s.trim();
}

/// Full-screen camera QR scanner.
///
/// Generic: the WalletConnect connect drawer and the Send screen's recipient
/// field both open it with their own [title]/[hint]/[accept] filter. Returns
/// the accepted payload via [Navigator.pop], or `null` if the user cancels.
///
/// NOTE: requires the camera permission / entitlement to be configured
/// natively (macOS `NSCameraUsageDescription` + the camera entitlement, iOS
/// `NSCameraUsageDescription`, Android `CAMERA`). See HANDOFF.md §5a — this is
/// not testable in the UI-only stub build.
class GWQrScanner extends StatefulWidget {
  const GWQrScanner({
    super.key,
    required this.title,
    required this.hint,
    this.accept,
  });

  final String title;

  /// Helper text shown under the reticle.
  final String hint;

  /// Maps the raw payload to the value to pop with, or returns `null` to
  /// ignore the code and keep scanning. When omitted, any payload is accepted
  /// as-is.
  final String? Function(String raw)? accept;

  /// Opens the scanner and resolves to the accepted payload (or null).
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hint,
    String? Function(String raw)? accept,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => GWQrScanner(title: title, hint: hint, accept: accept),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<GWQrScanner> createState() => _GWQrScannerState();
}

class _GWQrScannerState extends State<GWQrScanner> {
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
      if (raw == null) continue;
      final value = widget.accept == null ? raw : widget.accept!(raw);
      if (value != null && value.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(value);
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
        title: Text(widget.title),
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
              widget.hint,
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
