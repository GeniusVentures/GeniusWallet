import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavigationNext extends StatelessWidget {
  final constraints;

  NavigationNext(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.857,
        height: constraints.maxHeight * 0.568,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  flex: 10,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 0.085,
                          height: constraints.maxHeight * 0.568,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Next',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ))),
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.24,
                        top: MediaQuery.of(context).size.height * 0.08,
                      ),
                      child: Image.asset(
                        'assets/images/0_12087.png',
                        width: constraints.maxWidth * 0.024,
                        height: constraints.maxHeight * 0.243,
                      )),
                )
              ]),
        ));
  }
}
