import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/genius_icon.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverTextDesktopShield extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrLoremipsumdolorsitametco;
  final ovrGeniusIcon;
  final ovrNewshape;
  CoverTextDesktopShield(
    this.constraints, {
    Key key,
    this.ovrTitle,
    this.ovrLoremipsumdolorsitametco,
    this.ovrGeniusIcon,
    this.ovrNewshape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.003,
        top: 0,
        height: constraints.maxHeight * 1.004,
        child: Container(
          width: constraints.maxWidth * 376.000,
          height: constraints.maxHeight * 229.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.003,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.004,
        child: Container(
          width: constraints.maxWidth * 375.000,
          height: constraints.maxHeight * 229.000,
          decoration: BoxDecoration(
            color: Color(0xff0050c4),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: 376.0,
        top: 0,
        height: 229.0,
        child: Image.asset(
          'assets/images/222_2605.png',
          width: constraints.maxWidth * 376.000,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: 68.6,
        right: 69.4,
        top: 18.45,
        bottom: 222.7,
        child: Container(
            width: constraints.maxWidth * 238.000,
            height: constraints.maxHeight * 27.000,
            child: AutoSizeText(
              ovrTitle ?? 'Title',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: 51.577,
        right: 52.423,
        top: 67.45,
        bottom: 95.7,
        child: Container(
            width: constraints.maxWidth * 272.000,
            height: constraints.maxHeight * 105.000,
            child: AutoSizeText(
              ovrLoremipsumdolorsitametco ??
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque at luctus tellus. Curabitur nec vestibulum leo, in lobortis ex. Nulla eu quam et odio luctus suscipit. Mauris vehicula, lacus quis rutrum congue.',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
      ),
      Positioned(
        left: constraints.maxWidth * 0.399,
        width: constraints.maxWidth * 0.206,
        top: constraints.maxHeight * 0.838,
        height: constraints.maxHeight * 0.338,
        child: LayoutBuilder(builder: (context, constraints) {
          return GeniusIcon(
            constraints,
            ovrEllipse3: Image.asset(
              'assets/images/I222_2614;0_12263.png',
              width: constraints.maxWidth * 77.100,
              height: constraints.maxHeight * 77.100,
            ),
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.459,
        width: constraints.maxWidth * 0.087,
        top: constraints.maxHeight * 0.919,
        height: constraints.maxHeight * 0.178,
        child: ovrNewshape ??
            Image.asset(
              'assets/images/222_2615.png',
              width: constraints.maxWidth * 32.611,
              height: constraints.maxHeight * 40.500,
            ),
      ),
    ]);
  }
}
