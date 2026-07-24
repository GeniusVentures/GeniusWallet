import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SlidingDrawerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon; // Optional icon
  final Color? color; // Configurable color for both text and icon
  // 07-07 gap-closure (drawer-shell/quiet-band list-row pattern, 030-B1):
  // optional trailing chevron for rows that navigate elsewhere on tap.
  // Defaults to false so every pre-existing caller (markets_search_bar.dart,
  // wallet_information.g.dart, submit_job_button.dart) renders identically.
  final bool showTrailingChevron;

  const SlidingDrawerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color, // Color is now required for customization
    this.icon,
    this.showTrailingChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(
          top: 24,
          bottom: 24,
          left: 24,
          right: 24,
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: color) // Apply the custom color
          else
            const SizedBox(width: 18), // Placeholder to keep spacing consistent

          const SizedBox(width: 16), // Space between icon and text

          Flexible(
            child: AutoSizeText(
              label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: color, // Apply the custom color
              ),
            ),
          ),

          // Only present when requested -- pre-existing callers (which never
          // pass showTrailingChevron) get zero additional widgets, so their
          // rendered Row is byte-for-byte identical to before this change.
          if (showTrailingChevron) ...[
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: color),
          ],
        ],
      ),
    );
  }
}
