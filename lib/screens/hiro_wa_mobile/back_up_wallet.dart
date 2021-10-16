import 'package:flutter/material.dart';
import '../../view/symbols/cover_text.dart';
import '../../view/symbols/navigation_back.dart';
import '../../view/symbols/genius_checkbox<custom>.dart';
import '../../view/symbols/button_inactive.dart';

class BackUpWallet extends StatefulWidget {
  const BackUpWallet() : super();
  @override
  _BackUpWallet createState() => _BackUpWallet();
}

class _BackUpWallet extends State<BackUpWallet> {
  _BackUpWallet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(1.00, -0.10),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.001,
            height: MediaQuery.of(context).size.height * 0.899,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 32,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.001,
                              height:
                                  MediaQuery.of(context).size.height * 0.281,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Stack(children: [
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.001,
                                    right: MediaQuery.of(context).size.width *
                                        0.000,
                                    top: MediaQuery.of(context).size.height *
                                        0.000,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.000,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return CoverText(
                                        constraints,
                                      );
                                    }),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.000,
                                    right: MediaQuery.of(context).size.width *
                                        0.001,
                                    top: MediaQuery.of(context).size.height *
                                        0.018,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.217,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return NavigationBack(
                                        constraints,
                                      );
                                    }),
                                  ),
                                ]),
                              ))),
                    ),
                    Spacer(
                      flex: 17,
                    ),
                    Flexible(
                      flex: 31,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.21,
                            right: MediaQuery.of(context).size.width * 0.21,
                          ),
                          child: Image.asset(
                            'assets/images/0_3.png',
                            width: MediaQuery.of(context).size.width * 0.573,
                            height: MediaQuery.of(context).size.height * 0.277,
                          )),
                    ),
                    Spacer(
                      flex: 10,
                    ),
                    Flexible(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return GeniusCheckboxcustom(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 4,
                    ),
                    Flexible(
                      flex: 7,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return ButtonInactive(
                              constraints,
                            );
                          })),
                    ),
                  ]),
            )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
