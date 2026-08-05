import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// A toast card: an opaque `surfaceElevated` panel (so it reads correctly
/// regardless of whatever screen it floats over — it is painted straight
/// into the root `Overlay`, above any page content) with a type-coloured
/// accent (border + icon) and `textPrimary`/`textSecondary` copy.
///
/// Re-derived 23-03 from a fully inverted light-mode palette: every colour
/// here used to be a fixed `Colors.green.shade50`-style literal tuned only
/// for a dark canvas, so light mode painted a near-white toast that read as
/// broken against the light app. See `23-03-CONTRAST.md` for the measured
/// ratio behind every pair below, in both appearance modes.
class ToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const ToastWidget({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  /// The one colour that varies by [type]: the accent used for the border,
  /// the leading icon and (mirrored on the close affordance) nothing else —
  /// title/message/close stay on the neutral `textPrimary`/`textSecondary`
  /// ladder so the toast never depends on a status colour for legibility.
  Color _accentColor(GWColors gw) {
    switch (type) {
      case ToastType.success:
        return gw.statusSuccess;
      case ToastType.error:
        return gw.statusError;
      case ToastType.warning:
        return gw.statusWarningText;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_outlined;
      case ToastType.error:
        return Icons.error_outline_outlined;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    final accent = _accentColor(gw);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        border: Border.all(color: accent, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: GeniusWalletElevation.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(), color: accent, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: gw.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  message,
                  style: TextStyle(fontSize: 14, color: gw.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: const EdgeInsets.all(4), // Padding inside the square
              child: Icon(Icons.close, color: gw.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
