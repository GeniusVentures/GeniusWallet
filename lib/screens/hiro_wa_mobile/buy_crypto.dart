import 'package:flutter/material.dart';
import '../../view/symbols/cover_buy_crypto.dart';
import '../../view/symbols/navigation_info.dart';
import '../../view/symbols/double_info.dart';
import '../../view/symbols/dial_pad.dart';
import '../../view/symbols/button_active.dart';

class BuyCrypto extends StatefulWidget {
  const BuyCrypto() : super();
  @override
  _BuyCrypto createState() => _BuyCrypto();
}

class _BuyCrypto extends State<BuyCrypto> {
  _BuyCrypto();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(1.00, -0.09),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.001,
            height: MediaQuery.of(context).size.height * 0.900,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 36,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.001,
                              height:
                                  MediaQuery.of(context).size.height * 0.315,
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
                                        0.028,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return CoverBuyCrypto(
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
                                        0.015,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.000,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1.000,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.301,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 16,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return NavigationInfo(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 67,
                                                ),
                                                Flexible(
                                                  flex: 19,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.09,
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.09,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return DoubleInfo(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                              ]),
                                        )),
                                  ),
                                ]),
                              ))),
                    ),
                    Spacer(
                      flex: 12,
                    ),
                    Flexible(
                      flex: 42,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.17,
                            right: MediaQuery.of(context).size.width * 0.17,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return DialPad(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 6,
                    ),
                    Flexible(
                      flex: 7,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return ButtonActive(
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
