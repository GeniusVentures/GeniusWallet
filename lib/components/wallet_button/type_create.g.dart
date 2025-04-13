import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/components/custom/type_create_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TypeCreate extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCreateaWallet;
  const TypeCreate(
    this.constraints, {
    Key? key,
    this.ovrCreateaWallet,
  }) : super(key: key);

  @override
  _TypeCreate createState() => _TypeCreate();
}

class _TypeCreate extends State<TypeCreate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            GeniusWalletColors.lightGreenPrimary,
            GeniusWalletColors.lightGreenSecondary,
          ],
        ),
      ),
      child: TypeCreateCustom(
        child: Center(
          child: FittedBox(
            fit: BoxFit
                .scaleDown, // Ensures content scales to fit available space
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AutoSizeText(
                widget.ovrCreateaWallet ?? 'Continue',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: GeniusWalletFontSize.base,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1375,
                  color: GeniusWalletColors.deepBlue,
                ),
                maxLines: 1, // Ensures text does not wrap
                overflow:
                    TextOverflow.ellipsis, // Graceful text truncation if needed
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
