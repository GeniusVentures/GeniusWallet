import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class TokenFlipButton extends StatefulWidget {
  final VoidCallback onFlip;

  const TokenFlipButton({
    super.key,
    required this.onFlip,
  });

  @override
  State<TokenFlipButton> createState() => _TokenFlipButtonState();
}

class _TokenFlipButtonState extends State<TokenFlipButton> {
  double _rotationTurns = 0;

  void _handlePress() {
    setState(() {
      _rotationTurns += 1;
    });
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: _rotationTurns,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: FloatingActionButton(
        onPressed: _handlePress,
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        backgroundColor: Colors.greenAccent,
        child: const Icon(
          Icons.swap_vert,
          color: GeniusWalletColors.deepBlueTertiary,
        ),
      ),
    );
  }
}
