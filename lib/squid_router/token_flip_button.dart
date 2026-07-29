import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class TokenFlipButton extends StatefulWidget {
  final VoidCallback onFlip;

  const TokenFlipButton({super.key, required this.onFlip});

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
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return AnimatedRotation(
      turns: _rotationTurns,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Semantics(
        label: 'Flip tokens',
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handlePress,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: GeniusWalletGradient.brandCta,
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radiusMd,
                ),
                border: Border.all(color: gw.surfaceElevated, width: 5),
              ),
              child: Icon(Icons.swap_vert, color: gw.textOnBrand, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
