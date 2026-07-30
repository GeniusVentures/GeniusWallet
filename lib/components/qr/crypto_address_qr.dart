import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Sketch 034-A2 "Grouped address" (.planning/sketches/034-receive-qr,
/// .planning/sketches/drawers-final): a CONTAINED QR with the coin/network
/// chip ABOVE it, and the full address below as a tappable, borderless
/// 4-character-chunked mono block -- every character on screen, wrapped
/// across lines rather than middle-truncated, with the first two and last
/// two groups emphasised (copy-only). This is the panel a person uses to
/// eyeball-verify an address against one they already hold, which is exactly
/// the case where a truncated form is useless. A quiet bordered amber
/// network-mismatch note follows. Copy-only — no Share, no set-default (the
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

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final groups = _addressGroups(widget.address);

    // The amber this file worked out -- statusWarning is a FILL token and
    // measures ~1.6:1 on white -- now lives in `GWWarningNote`, along with the
    // note that used it. See that component for the reasoning and the ceiling.

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
          // `AssetImage("")` when there is no icon - which is every coin
          // without an asset, and every drawer opened from Markets - throws
          // *"Unable to load asset"* into the log on every build. `null` is
          // the API's own way to say "no embedded logo"; the empty string was
          // a `??` reaching for a non-nullable type that did not need one.
          embeddedImage: widget.iconPath == null
              ? null
              : AssetImage(widget.iconPath!),
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        // Full address — borderless, wrapped 4-char groups (034-A2). The
        // whole block is one tap target; tapping still copies the FULL
        // address via the unchanged `_copyAddress`/`_copied` cycle.
        //
        // Token pair for the sketch's `gap: 6px 10px` (row-gap, column-gap):
        // there is no 10px step on the 4-pt scale, so `space4` (8) stands in
        // for the horizontal gap and `space3` (6, the scale's one documented
        // half-step) is exact for the vertical one.
        GestureDetector(
          onTap: _copyAddress,
          behavior: HitTestBehavior.opaque,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: GeniusWalletConsts.space4,
            runSpacing: GeniusWalletConsts.space3,
            children: [
              for (var i = 0; i < groups.length; i++)
                Text(
                  groups[i],
                  style: GeniusWalletTypography.bodySm.copyWith(
                    fontFamily: GeniusWalletTypography.monoFamily,
                    color: _isEmphasised(i, groups.length)
                        ? gw.textPrimary
                        : gw.textSecondary,
                    fontWeight: _isEmphasised(i, groups.length)
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              // The copy glyph trails the last group, same flowing block —
              // sketch's `groupAddr()` appends its `.icon-btn.copy` span the
              // same way, after the chunk loop rather than beside it.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: GeniusWalletConsts.space2),
                  // Copied → keep the Material check (sketch has no check
                  // glyph); resting → the sketch 152 `.copy` SVG, same tint
                  // as before.
                  _copied
                      ? Icon(Icons.check, size: 16, color: gw.statusSuccess)
                      : SketchIcon(
                          SketchIcons.copy,
                          size: 16,
                          color: context.gw.brandPrimaryOnSurface,
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
            ],
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        // Network warning — quiet bordered amber note (034-A2). Copy-only
        // footer stays the caller's CopyButton/ActionButton; this widget adds
        // no Share / set-default action (respects the documented audit gap).
        // This note WAS this treatment; it is now `GWWarningNote`, which took
        // its values verbatim so nothing here moves a pixel. The light-mode
        // amber worked out in this file is the reason the component exists.
        GWWarningNote(
          "Only send ${widget.network}-network assets to this address.",
        ),
      ],
    );
  }
}

/// Splits [address] into 4-character groups over the WHOLE string, including
/// any `0x` prefix — the sketch's own `groupAddr()` runs
/// `ADDR.match(/.{1,4}/g)` over the full value, so the first group is
/// literally `0x1d`, not a bare prefix plus a shifted grid. The final group
/// is short rather than padded when the length is not a multiple of 4.
List<String> _addressGroups(String address) => [
  for (var i = 0; i < address.length; i += 4)
    address.substring(i, i + 4 > address.length ? address.length : i + 4),
];

/// A group is emphasised at index 0, 1, or one of the final two — the
/// sketch's own `i === 0 || i === 1 || i >= chunks.length - 2`: the two ends
/// a person actually checks an address against.
bool _isEmphasised(int index, int length) =>
    index == 0 || index == 1 || index >= length - 2;
