import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';

class ToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const ToastWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade50;
      case ToastType.error:
        return Colors.red.shade50;
      case ToastType.warning:
        return Colors.yellow.shade50;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade400;
      case ToastType.error:
        return Colors.red.shade400;
      case ToastType.warning:
        return Colors.yellow.shade400;
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(color: _getBorderColor(), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIcon(),
            color: _getBorderColor(),
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: const EdgeInsets.all(4), // Padding inside the square
              child: const Icon(
                Icons.close,
                color: Colors.black, // Icon color
                size: 20, // Icon size
              ),
            ),
          ),
        ],
      ),
    );
  }
}
