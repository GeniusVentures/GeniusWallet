import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class CopyButton extends StatefulWidget {
  final String textToCopy;
  final String buttonText;
  final double? width;

  const CopyButton({
    Key? key,
    required this.textToCopy,
    this.buttonText = "Copy",
    this.width, // Default button text
  }) : super(key: key);

  @override
  CopyButtonState createState() => CopyButtonState();
}

class CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    setState(() {
      _copied = true;
    });

    // Reset back to original after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: ElevatedButton(
        onPressed: _copyToClipboard,
        style: ElevatedButton.styleFrom(
          backgroundColor: GeniusWalletColors.deepBlueCardColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _copied ? Icons.check : Icons.content_copy, // Change icon on copy
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between icon & text
            Flexible(
                child: AutoSizeText(
              _copied ? "Copied!" : widget.buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
