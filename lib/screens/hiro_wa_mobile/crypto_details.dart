import 'package:flutter/material.dart';
import '../../view/symbols/cover_crypto.dart';
import '../../view/symbols/navigation_buy.dart';
import '../../view/symbols/contracts.dart';
import '../../view/symbols/navbar.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CryptoDetails extends StatefulWidget {
  const CryptoDetails() : super();
  @override
  _CryptoDetails createState() => _CryptoDetails();
}

class _CryptoDetails extends State<CryptoDetails> {
  _CryptoDetails();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(1.00, 1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.001,
            height: MediaQuery.of(context).size.height * 0.954,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 37,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.001,
                              height:
                                  MediaQuery.of(context).size.height * 0.345,
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
                                      return CoverCrypto(
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
                                        0.285,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return NavigationBuy(
                                        constraints,
                                      );
                                    }),
                                  ),
                                ]),
                              ))),
                    ),
                    Spacer(
                      flex: 4,
                    ),
                    Flexible(
                      flex: 61,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.000,
                              height:
                                  MediaQuery.of(context).size.height * 0.580,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: Stack(children: [
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.085,
                                    right: MediaQuery.of(context).size.width *
                                        0.085,
                                    top: MediaQuery.of(context).size.height *
                                        0.000,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.066,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.830,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.514,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 6,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.65,
                                                      ),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.181,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.026,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: AutoSizeText(
                                                              'Yesterday',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Prompt',
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                letterSpacing:
                                                                    0.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ))),
                                                ),
                                                Spacer(
                                                  flex: 4,
                                                ),
                                                Flexible(
                                                  flex: 92,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.830,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.470,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 4,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 14,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 12,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return Contracts(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                ]),
                                                          ))),
                                                ),
                                              ]),
                                        )),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.087,
                                    right: MediaQuery.of(context).size.width *
                                        0.721,
                                    top: MediaQuery.of(context).size.height *
                                        0.414,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.141,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.192,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.026,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Past Week',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              letterSpacing: 0.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        )),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.000,
                                    right: MediaQuery.of(context).size.width *
                                        0.000,
                                    top: MediaQuery.of(context).size.height *
                                        0.485,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.000,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return Navbar(
                                        constraints,
                                      );
                                    }),
                                  ),
                                ]),
                              ))),
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
