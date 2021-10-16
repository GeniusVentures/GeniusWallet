import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/price_chart.dart';
import '../../view/symbols/transaction_history.dart';
import '../../view/symbols/cover_buy_crypto_desktop.dart';
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
        alignment: Alignment(0.00, 0.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 1.000,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.938,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return NavbarDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.001,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return BackgroundDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.130,
                  right: MediaQuery.of(context).size.width * 0.162,
                  top: MediaQuery.of(context).size.height * 0.110,
                  bottom: MediaQuery.of(context).size.height * 0.049,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.708,
                      height: MediaQuery.of(context).size.height * 0.841,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 40,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.29,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return PriceChart(
                                        constraints,
                                      );
                                    })),
                              ),
                              Spacer(
                                flex: 5,
                              ),
                              Flexible(
                                flex: 56,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.29,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return TransactionHistory(
                                        constraints,
                                      );
                                    })),
                              ),
                              Flexible(
                                flex: 100,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.45,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.260,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.841,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Stack(children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.260,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.841,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                border: Border.all(
                                                  color: Color(0x00000000),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.000,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.000,
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.000,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.554,
                                              child: LayoutBuilder(builder:
                                                  (context, constraints) {
                                                return CoverBuyCryptoDesktop(
                                                  constraints,
                                                );
                                              }),
                                            ),
                                            Positioned(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.022,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.022,
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.280,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.023,
                                              child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.215,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.538,
                                                  child: Align(
                                                    alignment:
                                                        Alignment(0.00, 0.00),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Flexible(
                                                            flex: 11,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child: LayoutBuilder(
                                                                    builder:
                                                                        (context,
                                                                            constraints) {
                                                                  return DoubleInfo(
                                                                    constraints,
                                                                  );
                                                                })),
                                                          ),
                                                          Spacer(
                                                            flex: 13,
                                                          ),
                                                          Flexible(
                                                            flex: 53,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child: LayoutBuilder(
                                                                    builder:
                                                                        (context,
                                                                            constraints) {
                                                                  return DialPad(
                                                                    constraints,
                                                                  );
                                                                })),
                                                          ),
                                                          Spacer(
                                                            flex: 15,
                                                          ),
                                                          Flexible(
                                                            flex: 11,
                                                            child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(),
                                                                child: LayoutBuilder(
                                                                    builder:
                                                                        (context,
                                                                            constraints) {
                                                                  return ButtonActive(
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
                            ]),
                      )),
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
