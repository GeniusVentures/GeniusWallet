import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SlidingDrawerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon; // Optional icon
  final Color? color; // Configurable color for both text and icon

  const SlidingDrawerButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.color, // Color is now required for customization
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding:
            const EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
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
          )),
        ],
      ),
    );
  }
}
