import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A label/value detail row whose value belongs in the clipboard rather than
/// fully on screen: it truncates for display, and always copies the FULL
/// value.
///
/// **This is a promotion Phase 23 previously refused, now approved on a
/// changed premise.** Two forks of this exact shape already ship:
/// `lib/tokens/token_info_screen.dart`'s `_CopyAddressRow` (:975-1044) and
/// `lib/dashboard/home/widgets/transaction_displays.dart`'s `_CopyRow`
/// (:523-601). Phase 23 re-measured an audit that claimed three consumers,
/// found only these two, and correctly refused the extraction under the
/// repo's Rule of Three (`23-05-PLAN.md:155-166`) - two occurrences do not
/// justify a shared component. The bridge-hash row Phase 14 plan 06 builds in
/// the job-result terminal state is genuinely the third occurrence of this
/// shape (label, truncated mono value, copy glyph, hover, a snackbar naming
/// the row), which is what changes the answer. **The two existing forks are
/// NOT migrated onto this widget here** - that is Phase 7's file
/// (`transaction_displays.dart`) and Phase 23's own file
/// (`token_info_screen.dart`), both out of this phase's fence, and each is a
/// zero-repaint follow-up because this widget's truncation rule and copy
/// behaviour are lifted from them verbatim.
///
/// **Scope constraint (T-14-08):** this component is for public, non-secret
/// on-chain identifiers only - addresses and transaction/job hashes. It is
/// deliberately NOT adopted by the seed-phrase site, which Phase 23 judged
/// heterogeneous and dangerous to merge into a shared clipboard writer. A
/// future caller must not route key material through this widget.
///
/// **Component owns:** the display truncation ([shorten]), copying the FULL
/// [value] (never the truncated form - the security property Phase 23
/// audited at `token_info_screen.dart:993`), the copy confirmation via
/// [showAppSnackBar], the hover state, the copy glyph, and
/// [kGWDetailRowPadding] placed INSIDE the gesture detector so the whole grid
/// cell is the tap target (`gw_detail_grid.dart:5-15` documents why the grid
/// itself does not pad its rows).
///
/// **Call site owns:** wrapping this in a [GWDetailGrid].
class GWCopyRow extends StatelessWidget {
  const GWCopyRow({
    super.key,
    required this.label,
    required this.value,
    this.shorten = true,
  });

  final String label;

  /// The FULL value. What is drawn may be a truncated form (see [shorten]);
  /// what lands in the clipboard on tap is always this, unabridged.
  final String value;

  /// When true (the default) and [value] is longer than twelve characters,
  /// the display shows the first six and last six characters separated by an
  /// ellipsis. The clipboard always receives the full [value] regardless of
  /// this flag - truncation is display-only, by construction.
  final bool shorten;

  String get _displayValue {
    final v = value;
    // Truncation rule copied verbatim from `_CopyAddressRow`
    // (`token_info_screen.dart:999-1001`): only when the value exceeds
    // twelve characters, six from each end.
    if (!shorten || v.length <= 12) {
      return v;
    }
    return '${v.substring(0, 6)}...${v.substring(v.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // The address treatment both existing forks already use: bodySm in
    // the shared mono token (GeniusWalletTypography.monoFamily).
    final mono = GeniusWalletTypography.bodySm.copyWith(
      fontFamily: GeniusWalletTypography.monoFamily,
    );

    // Hover plumbing moved into `GWHoverable` (23-05); this widget held no
    // other state, so it is a `StatelessWidget` now.
    return GWHoverable(
      builder: (hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // The FULL value goes to the clipboard, never the truncated
          // display form - this is the security property Phase 23 audited.
          Clipboard.setData(ClipboardData(text: value));
          showToast(context, '$label copied');
        },
        // The inset is INSIDE the detector, so the whole grid cell is the
        // target - see kGWDetailRowPadding's doc for why GWDetailGrid does
        // not pad its rows itself.
        child: Padding(
          padding: kGWDetailRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textPrimary70,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _displayValue,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mono,
                      ),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space3),
                    Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: hovered ? gw.textPrimary : gw.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
