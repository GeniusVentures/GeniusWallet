import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Extracts a bare wallet address from a scanned QR payload.
///
/// Address QRs come in several shapes — plain (`0xAbC…`, `bc1q…`), EIP-681
/// (`ethereum:0xAbC…@1?value=…`, incl. the `pay-` form), the EIP-681 ERC-20
/// transfer form (`ethereum:0xTOKEN/transfer?address=0xPAYEE&uint256=…`), BIP-21
/// (`bitcoin:bc1q…?amount=…`) and other `<scheme>:<address>` URIs. This strips
/// the scheme, the EIP-681 chain id (`@1`) / function path (`/transfer`) and
/// any query params, returning just the recipient. For the transfer form the
/// recipient is the `address` query param (the leading value is the TOKEN
/// CONTRACT, not the payee). Plain payloads pass through trimmed.
///
/// NOTE: this only normalizes the payload — it does NOT validate that the
/// result is a well-formed address for the selected network. The caller must
/// validate before using it as a real send recipient (see send_screen.dart).
String extractWalletAddress(String raw) {
  var s = raw.trim();
  // A URI scheme starts with a letter — a plain `0x…` address never matches.
  final scheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').firstMatch(s);
  if (scheme != null) s = s.substring(scheme.end);
  if (s.startsWith('pay-')) s = s.substring(4);
  // EIP-681 ERC-20 transfer: the real payee is the `address` query param, not
  // the leading token contract. Prefer it when present.
  // Only the EIP-681 function-call form (`<token>/<fn>?address=…`) carries the
  // payee in a query param; a plain `<addr>?…` has no path slash, so its
  // leading value already IS the recipient.
  final qIndex = s.indexOf('?');
  if (qIndex >= 0 && s.substring(0, qIndex).contains('/')) {
    for (final pair in s.substring(qIndex + 1).split('&')) {
      final eq = pair.indexOf('=');
      if (eq > 0 && pair.substring(0, eq) == 'address') {
        final payee = pair.substring(eq + 1).trim();
        if (payee.isNotEmpty) return Uri.decodeComponent(payee);
      }
    }
  }
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
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            // Permission denied / no camera / unavailable: show a recovery
            // message instead of a blank black screen.
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(GeniusWalletConsts.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_outlined,
                        color: Colors.white70, size: 48),
                    const SizedBox(height: GeniusWalletConsts.space8),
                    Text(
                      'Camera unavailable',
                      textAlign: TextAlign.center,
                      style: GeniusWalletTypography.bodyMd.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: GeniusWalletConsts.space8),
                    Text(
                      'Grant camera access in Settings, then reopen the '
                      'scanner. You can also paste the address manually.',
                      textAlign: TextAlign.center,
                      style: GeniusWalletTypography.bodyMd
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            // Clear the home indicator on bottom-inset devices.
            bottom: GeniusWalletConsts.space24 +
                MediaQuery.of(context).viewPadding.bottom,
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
