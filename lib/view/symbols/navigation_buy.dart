import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NavigationBuy extends StatelessWidget {
  final constraints;

  NavigationBuy(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.816,
        height: constraints.maxHeight * 0.568,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 100,
                  child: Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.08,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.737,
                          height: constraints.maxHeight * 0.568,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.24,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                        ),
                                        child: Image.asset(
                                          'assets/images/0_12079.png',
                                          width: constraints.maxWidth * 0.024,
                                          height: constraints.maxHeight * 0.243,
                                        )),
                                  ),
                                  Spacer(
                                    flex: 88,
                                  ),
                                  Flexible(
                                    flex: 10,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: Container(
                                            width: constraints.maxWidth * 0.069,
                                            height:
                                                constraints.maxHeight * 0.568,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: AutoSizeText(
                                                'Buy',
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
                                  )
                                ]),
                          ))),
                ),
                Flexible(
                  flex: 77,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.77,
                      ),
                      child: Image.asset(
                        'assets/images/0_12083.png',
                        width: constraints.maxWidth * 0.043,
                        height: constraints.maxHeight * 0.432,
                      )),
                ),
              ]),
        ));
  }
}
