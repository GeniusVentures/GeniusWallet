import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/components/custom/isactive_false_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class IsactiveFalse extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrContinue;
  const IsactiveFalse(
    this.constraints, {
    Key? key,
    this.ovrContinue,
  }) : super(key: key);
  @override
  _IsactiveFalse createState() => _IsactiveFalse();
}

class _IsactiveFalse extends State<IsactiveFalse> {
  _IsactiveFalse();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: IsactiveFalseCustom(
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
                  color: GeniusWalletColors.btnDisabled,
                ),
              ),
            ),
            // Text Section (Updated)
            Positioned(
              left: 16.0, // Adjusted for better responsiveness
              right: 16.0,
              top: widget.constraints.maxHeight *
                  0.3, // Centered more effectively
              bottom: widget.constraints.maxHeight * 0.3,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AutoSizeText(
                    widget.ovrContinue ?? GeniusWalletText.btnContinue,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: GeniusWalletFontSize.medium,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1375,
                      color: GeniusWalletColors.btnTextDisabled,
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
