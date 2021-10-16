import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverText extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrLoremipsumdolorsitametco;
  CoverText(
    this.constraints, {
    Key key,
    this.ovrTitle,
    this.ovrLoremipsumdolorsitametco,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.003,
        top: 0,
        height: 229.0,
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
        height: 229.0,
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
          'assets/images/0_12150.png',
          width: constraints.maxWidth * 376.000,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: 68.6,
        right: 69.4,
        top: 18.45,
        height: 27.0,
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
        left: 40.6,
        right: 40.4,
        top: 68.45,
        height: 105.0,
        child: Container(
            width: constraints.maxWidth * 295.000,
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
    ]);
  }
}
