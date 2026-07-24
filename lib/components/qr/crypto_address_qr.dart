import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Sketch 034-A2 "Grouped address" (.planning/sketches/034-receive-qr,
/// .planning/sketches/drawers-final): a CONTAINED QR with the coin/network
/// chip ABOVE it, the full address below as a tappable 4-char-chunked mono
/// block (first/last chunks emphasized, copy-only), and a quiet bordered
/// amber network-mismatch note. Copy-only — no Share, no set-default (the
/// widget has no such logic to wire; respected audit gap).
class CryptoAddressQR extends StatefulWidget {
  final String address;
  final String network;
  final String? iconPath;

  const CryptoAddressQR({
    super.key,
    required this.address,
    required this.network,
    this.iconPath,
  });

  @override
  State<CryptoAddressQR> createState() => _CryptoAddressQRState();
}

class _CryptoAddressQRState extends State<CryptoAddressQR> {
  bool _copied = false;

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.address));
    setState(() => _copied = true);

    // Reset back to original after 2 seconds, mirroring CopyButton.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  /// Middle-truncated address for a clean single-line display (the copy action
  /// still copies the FULL address): 0x1234…5678.
  String _shortAddress(String address) => address.length > 16
      ? '${address.substring(0, 8)}…${address.substring(address.length - 6)}'
      : address;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // 034-A2's "bordered amber note". GeniusWalletColors.statusWarning
    // (#FFC42E) is a FILL-ONLY token tuned for the dark badge canvas
    // (~13:1 there) and fails WCAG non-text contrast (~1.6:1) on white — so
    // this mirrors the same light/dark divergence GWColors.light()/.dark()
    // already applies to statusSuccess/statusError: a darkened amber for
    // light-mode text/icon use (7.1:1 on white), the vivid token for dark
    // mode. Scoped locally (not added to GWColors — out of this file's
    // reskin boundary).
    final warningColor = GWAppearance.isLight
        ? const Color(0xFF92400E) // ~7.1:1 on white
        : GeniusWalletColors.statusWarning; // ~13.2:1 on the dark canvas

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Network chip — ABOVE the QR (034-A2), borderless (avatar + text).
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.iconPath != null) ...[
              CircleAvatar(
                radius: 10,
                // §4.4 always-light chip: the coin logo needs a fixed light
                // backing regardless of appearance (NOT an appearance token).
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(widget.iconPath!),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
            ],
            Text(
              widget.network,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        // QR — an EXPLICIT contained size (~60% of the prior ~304px
        // full-bleed fill), self-contained so it no longer depends on the
        // caller's wrapping SizedBox to shrink it (gap 3).
        QrImageView(
          data: widget.address,
          version: QrVersions.auto,
          size: 190,
          // §4.4 always-light exception + finding 16/6: a SOLID light backing
          // in BOTH appearance modes so the default-black QR modules stay
          // scannable by a phone camera over the dark drawer. NEVER an
          // appearance token.
          backgroundColor: Colors.white,
          embeddedImage: AssetImage(widget.iconPath ?? ""),
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        // Full address — a clean tap-to-copy pill: middle-truncated mono
        // address + a Copy affordance (the whole row copies the FULL address).
        GestureDetector(
          onTap: _copyAddress,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space8,
              vertical: GeniusWalletConsts.space6,
            ),
            decoration: GWDecorations.surface(
              radius: GeniusWalletConsts.radiusLg,
              elevated: false,
              border: gw.borderSubtle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _shortAddress(widget.address),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GeniusWalletTypography.bodySm.copyWith(
                      fontFamily: 'JetBrainsMono',
                      color: gw.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: GeniusWalletConsts.space6),
                // Copied → keep the Material check (sketch has no check glyph);
                // resting → the sketch 152 `.copy` SVG, same tint as before.
                _copied
                    ? Icon(Icons.check, size: 16, color: gw.statusSuccess)
                    : SketchIcon(
                        SketchIcons.copy,
                        size: 16,
                        color: GeniusWalletColors.brandPrimaryOnSurface,
                      ),
                const SizedBox(width: GeniusWalletConsts.space2),
                Text(
                  _copied ? "Copied" : "Copy",
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: _copied ? gw.statusSuccess : gw.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        // Network warning — quiet bordered amber note (034-A2). Copy-only
        // footer stays the caller's CopyButton/ActionButton; this widget adds
        // no Share / set-default action (respects the documented audit gap).
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
            vertical: GeniusWalletConsts.space4,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: warningColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: warningColor),
              const SizedBox(width: GeniusWalletConsts.space4),
              Flexible(
                child: Text(
                  "Only send ${widget.network}-network assets to this address.",
                  style: GeniusWalletTypography.bodySm.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
