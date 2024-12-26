import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/custom/genius_back_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/widgets/components/genius_back_button.g.dart';

class RegistrationHeader extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSubtitle;
  final String? ovrTitle;
  const RegistrationHeader(
    this.constraints, {
    Key? key,
    this.ovrSubtitle,
    this.ovrTitle,
  }) : super(key: key);
  @override
  _RegistrationHeader createState() => _RegistrationHeader();
}

class _RegistrationHeader extends State<RegistrationHeader> {
  _RegistrationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 56,
                child: Container(
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: const BoxDecoration(
                    color: GeniusWalletColors.deepBlueCardColor,
                  ),
                ),
              ),
              Positioned(
                left: 30.0,
                right: 30.0,
                top: 100.0,
                height: 192.0,
                child: Container(
                    height: 32.0,
                    width: widget.constraints.maxWidth * 0.84,
                    child: AutoSizeText(
                      widget.ovrSubtitle ??
                          'In the next step you will see 12 words that allows you to recover a wallet.',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.13750000298023224,
                        color: Colors.white,
                      ),
                    )),
              ),
              Positioned(
                left: 74.0,
                right: 74.0,
                top: 16,
                child: SizedBox(
                    width: widget.constraints.maxWidth * 0.6053333333333333,
                    child: AutoSizeText(
                      widget.ovrTitle ?? GeniusWalletText.titleWalletBackup,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: GeniusWalletFontSize.title,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.13750000298023224,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 30.0,
                width: 10.0,
                top: 20.0,
                height: 18.0,
                child: GeniusBackButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return GeniusBackButton(
                    constraints,
                    ovrWhiteArrowBack: SvgPicture.asset(
                      'assets/images/whitearrowback.svg',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.09473684210526316,
                      width: widget.constraints.maxWidth * 0.02666666666666667,
                      fit: BoxFit.fill,
                    ),
                  );
                })),
              ),
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
