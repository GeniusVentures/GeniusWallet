import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverText extends StatelessWidget {
  final constraints;

  CoverText(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 1.003,
        height: constraints.maxHeight * 1.004,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Stack(children: [
            Image.asset(
              'assets/images/0_12150.png',
              width: constraints.maxWidth * 1.003,
              height: constraints.maxHeight * 1.004,
            ),
            Positioned(
              left: constraints.maxWidth * 0.003,
              right: constraints.maxWidth * 0.000,
              top: constraints.maxHeight * 0.000,
              bottom: constraints.maxHeight * 0.000,
              child: Container(
                width: constraints.maxWidth * 1.000,
                height: constraints.maxHeight * 1.004,
                decoration: BoxDecoration(
                  color: Color(0xff0050c4),
                ),
              ),
            ),
            Positioned(
              left: constraints.maxWidth * 0.183,
              right: constraints.maxWidth * 0.185,
              top: constraints.maxHeight * 0.081,
              bottom: constraints.maxHeight * 0.805,
              child: Container(
                  width: constraints.maxWidth * 0.635,
                  height: constraints.maxHeight * 0.118,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: AutoSizeText(
                      'Title',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
            ),
            Positioned(
              left: constraints.maxWidth * 0.108,
              right: constraints.maxWidth * 0.108,
              top: constraints.maxHeight * 0.300,
              bottom: constraints.maxHeight * 0.244,
              child: Container(
                  width: constraints.maxWidth * 0.787,
                  height: constraints.maxHeight * 0.461,
                  child: Align(
                    alignment: Alignment(0.00, 0.00),
                    child: AutoSizeText(
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
                    ),
                  )),
            ),
          ]),
        ));
  }
}
