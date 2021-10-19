import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';

class CoverButtonDesktopImage extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrButtonActive;
  CoverButtonDesktopImage(
    this.constraints, {
    Key key,
    this.ovrTitle,
    this.ovrButtonActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
          'assets/images/222_3759.png',
          width: constraints.maxWidth * 376.000,
          height: constraints.maxHeight * 229.000,
        ),
      ),
      Positioned(
        left: 92.577,
        right: 86.423,
        top: 18.45,
        bottom: 183.55,
        child: Container(
            width: constraints.maxWidth * 197.000,
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
        left: constraints.maxWidth * 0.087,
        width: constraints.maxWidth * 0.827,
        top: constraints.maxHeight * 0.647,
        height: constraints.maxHeight * 0.197,
        child: LayoutBuilder(builder: (context, constraints) {
          return ButtonActive(
            constraints,
            ovrTypesomething: 'New Connection',
          );
        }),
      ),
    ]);
  }
}
