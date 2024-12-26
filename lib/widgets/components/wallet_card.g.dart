import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_card_custom.dart';
import 'package:genius_wallet/widgets/components/custom/white_arrow_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/white_arrow/pointing_right.g.dart';

class WalletCard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrEthereum;
  final Widget? ovrEllipse1;

  const WalletCard(
    this.constraints, {
    Key? key,
    this.ovrEthereum,
    this.ovrEllipse1,
  }) : super(key: key);

  @override
  _WalletCard createState() => _WalletCard();
}

class _WalletCard extends State<WalletCard> {
  _WalletCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GeniusWalletColors.blue500,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.borderRadiusButton),
      ),
      child: WalletCardCustom(
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: GeniusWalletColors.blue500,
                  borderRadius: BorderRadius.circular(GeniusWalletConsts.borderRadiusButton),
                ),
              ),
            ),

            // Arrow
            Positioned(
              right: 19.0,
              width: 7.0,
              top: widget.constraints.maxHeight * 0.436,
              height: widget.constraints.maxHeight * 0.164,
              child: Center(
                child: WhiteArrowCustom(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return PointingRight(
                        constraints,
                        ovrWhiteArrowRight: SvgPicture.asset(
                          'assets/images/whitearrowright.svg',
                          package: 'genius_wallet',
                          height: 12.0,
                          width: 7.0,
                          fit: BoxFit.none,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Wallet Name (Proper Alignment)
            Positioned(
              left: 50.0,
              right: 50.0,
              top: widget.constraints.maxHeight * 0.3,
              bottom: widget.constraints.maxHeight * 0.3,
              //child: Center(
                child: AutoSizeText(
                  widget.ovrEthereum ?? 'Ethereum',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1375,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  minFontSize: 10,
                ),
              //),
            ),

            // Icon
            Positioned(
              left: 12.0,
              width: 30.0,
              top: widget.constraints.maxHeight * 0.236,
              height: widget.constraints.maxHeight * 0.545,
              child: Center(
                child: widget.ovrEllipse1 ??
                    Image.asset(
                      'assets/images/ellipse1.png',
                      package: 'genius_wallet',
                      height: 30.0,
                      width: 30.0,
                      fit: BoxFit.scaleDown,
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
