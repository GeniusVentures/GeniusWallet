import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverTextDesktop extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrLoremipsumdolorsitametco;
  CoverTextDesktop(
    this.constraints, {
    Key key,
    this.ovrTitle,
    this.ovrLoremipsumdolorsitametco,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 68.0,
        right: 69.0,
        top: constraints.maxHeight * 0.079,
        height: constraints.maxHeight * 0.118,
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
        left: 50.978,
        right: 52.022,
        top: constraints.maxHeight * 0.294,
        height: constraints.maxHeight * 0.461,
        child: Center(
            child: Container(
                height: 105.0,
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
                    )))),
      ),
    ]);
  }
}
