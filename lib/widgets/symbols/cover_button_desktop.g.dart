import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverButtonDesktop extends StatelessWidget {
  final constraints;
  final ovrTitle;
  final ovrButtonActive;
  CoverButtonDesktop(
    this.constraints, {
    Key key,
    this.ovrTitle,
    this.ovrButtonActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: constraints.maxWidth * 0.048,
        width: constraints.maxWidth * 0.864,
        top: 18.0,
        height: 27.0,
        child: Container(
            width: constraints.maxWidth * 324.000,
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
        left: constraints.maxWidth * 0.085,
        width: constraints.maxWidth * 0.827,
        top: constraints.maxHeight * 0.645,
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
