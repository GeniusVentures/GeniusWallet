import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// How much room a toast is allowed to take, chosen by what it has to say.
///
/// [compact] is a receipt — "Link copied", after the user tapped copy. They
/// already know; a bordered card with a bold title and a close button shouts
/// it back at them. [card] is an alert the user did not ask for and may need
/// to act on, so it earns the title, the dismiss affordance and the longer
/// read.
enum ToastDensity { compact, card }

/// A toast, in one of two densities.
///
/// Painted straight into the root `Overlay`, so it floats above any page
/// content and must read correctly over anything — hence the opaque
/// `surfaceElevated` fill rather than a translucent scrim.
///
/// Colours are the 23-03 palette unchanged: every pair here was measured in
/// both appearance modes (see `23-03-CONTRAST.md`). The status colour is
/// carried by the icon alone — title and message stay on the neutral
/// `textPrimary`/`textSecondary` ladder, so the toast never depends on a
/// status colour for legibility.
class ToastWidget extends StatelessWidget {
  final String message;

  /// Null selects [ToastDensity.compact]. A title is what makes a toast an
  /// alert rather than a confirmation.
  final String? title;
  final ToastType type;
  final VoidCallback onDismiss;

  const ToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.title,
  });

  ToastDensity get density =>
      title == null ? ToastDensity.compact : ToastDensity.card;

  Color _accent(GWColors gw) {
    switch (type) {
      case ToastType.success:
        return gw.statusSuccess;
      case ToastType.error:
        return gw.statusError;
      case ToastType.warning:
        return gw.statusWarningText;
    }
  }

  IconData _icon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_outlined;
      case ToastType.error:
        return Icons.error_outline_outlined;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  /// What a screen reader is handed. An error interrupts; a confirmation
  /// waits its turn — `assertive` vs `polite` is the whole reason
  /// [Semantics.liveRegion] is not enough on its own.
  String get semanticLabel => title == null ? message : '$title. $message';

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    final accent = _accent(gw);

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticLabel,
      // A toast is inserted straight into the root Overlay, which has no
      // Material ancestor. Without this, Text falls back to the debug style —
      // reddish with a yellow double underline — because `decoration` is
      // inherited from the ambient DefaultTextStyle and the typography tokens
      // only set colour and size. It also gives the dismiss IconButton
      // something to paint its ink into. `transparency` so the Container
      // below stays the only thing painting a surface.
      child: Material(
        type: MaterialType.transparency,
        child: density == ToastDensity.compact
            ? _Compact(accent: accent, icon: _icon(), message: message, gw: gw)
            : _Card(
                accent: accent,
                icon: _icon(),
                title: title!,
                message: message,
                onDismiss: onDismiss,
                gw: gw,
              ),
      ),
    );
  }
}

/// The receipt: one line, sized to its own content, no dismiss affordance —
/// it is gone in about two seconds and nothing is lost if it is missed.
class _Compact extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String message;
  final GWColors gw;

  const _Compact({
    required this.accent,
    required this.icon,
    required this.message,
    required this.gw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space3,
      ),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        border: Border.all(color: gw.borderSubtle),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        boxShadow: GeniusWalletElevation.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: GeniusWalletConsts.space3,
        children: [
          Icon(icon, color: accent, size: 16),
          Flexible(
            child: Text(
              message,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The alert: a leading status edge instead of a full ring, so the colour
/// still identifies the kind without the container shouting.
class _Card extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onDismiss;
  final GWColors gw;

  const _Card({
    required this.accent,
    required this.icon,
    required this.title,
    required this.message,
    required this.onDismiss,
    required this.gw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GeniusWalletConsts.space6),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        border: Border.all(color: gw.borderSubtle),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        boxShadow: GeniusWalletElevation.card,
      ),
      // Two rows, not two columns. The icon and the title are one statement -
      // what happened - so they share a line; the message is explanation and
      // gets the full width under it. Side by side, a 20px icon sat against a
      // two-line column with dead space beneath it, and the message lost ~32px
      // of width it needs more on a phone than the indent was buying.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: GeniusWalletConsts.space3,
            children: [
              // The icon is the only thing carrying the status. No leading
              // edge: two coloured objects saying the same thing is one too
              // many, and the glyph distinguishes the three kinds by shape
              // rather than by colour, which is what keeps 1.4.1 satisfied.
              Icon(icon, color: accent, size: 20),
              Expanded(
                child: Text(
                  title,
                  style: GeniusWalletTypography.titleMd.copyWith(
                    color: gw.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DismissButton(onDismiss: onDismiss, gw: gw),
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
          Text(
            message,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  final VoidCallback onDismiss;
  final GWColors gw;

  const _DismissButton({required this.onDismiss, required this.gw});

  @override
  Widget build(BuildContext context) {
    // 44pt, matching the floor phase 25 set for the filter chips. The swipe is
    // the primary dismissal on a phone — the top of the screen is out of thumb
    // reach — but this has to be reachable too.
    //
    // The 18px glyph therefore sits ~13px inside its own box and ~25px from the
    // card edge. Pulling it flush would need a negative margin, which Container
    // turns into a Padding and asserts on — the target keeps its size instead.
    return IconButton(
      onPressed: onDismiss,
      icon: const Icon(Icons.close),
      iconSize: 18,
      color: gw.textSecondary,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      tooltip: 'Dismiss',
    );
  }
}
