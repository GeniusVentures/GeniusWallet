import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/components/custom/isactive_true_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class IsactiveTrue extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrContinue;

  const IsactiveTrue(
    this.constraints, {
    Key? key,
    this.ovrContinue,
  }) : super(key: key);

  @override
  _IsactiveTrue createState() => _IsactiveTrue();
}

class _IsactiveTrue extends State<IsactiveTrue> {
  _IsactiveTrue();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: IsactiveTrueCustom(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              width: widget.constraints.maxWidth * 1.0,
              top: 0,
              height: widget.constraints.maxHeight * 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  gradient: GeniusWalletGradient.greenBlueGreenGradient,
                ),
              ),
            ),

            // Text Section (Adjusted)
            Positioned(
              left: 16.0, // Consistent horizontal padding
              right: 16.0,
              top: widget.constraints.maxHeight *
                  0.3, // Balanced vertical alignment
              bottom: widget.constraints.maxHeight * 0.3,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AutoSizeText(
                    widget.ovrContinue ?? GeniusWalletText.btnContinue,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: GeniusWalletFontSize.medium,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.138,
                      color: GeniusWalletColors.btnText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
