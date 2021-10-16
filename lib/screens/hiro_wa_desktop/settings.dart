import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/settings_card.dart';
import '../../view/symbols/cover_balance_desktop.dart';
import '../../view/symbols/settings_card_6_o_ptions.dart';
import '../../view/symbols/crypto_item.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Settings extends StatefulWidget {
  const Settings() : super();
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  _Settings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(0.00, -1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 1.048,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.986,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return NavbarDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.660,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.048,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.340,
                    height: MediaQuery.of(context).size.height * 1.000,
                    decoration: BoxDecoration(
                      color: Color(0xff003698),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.001,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.048,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return BackgroundDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.017,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.983,
                      height: MediaQuery.of(context).size.height * 1.048,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 8,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.69,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard(
                                        constraints,
                                      );
                                    })),
                              ),
                              Flexible(
                                flex: 5,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.83,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.146,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.045,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Settings',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 32.29999923706055,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              letterSpacing: 0.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ))),
                              ),
                              Flexible(
                                flex: 3,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.27,
                                      right: MediaQuery.of(context).size.width *
                                          0.69,
                                    ),
                                    child: Image.asset(
                                      'assets/images/0_339.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.017,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.031,
                                    )),
                              ),
                              Flexible(
                                flex: 96,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.32,
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.660,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1.000,
                                      decoration: BoxDecoration(
                                        color: Color(0xff003698),
                                      ),
                                    )),
                              ),
                              Flexible(
                                flex: 8,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.69,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard(
                                        constraints,
                                      );
                                    })),
                              ),
                              Flexible(
                                flex: 45,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.31,
                                      right: MediaQuery.of(context).size.width *
                                          0.32,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return CoverBalanceDesktop(
                                        constraints,
                                      );
                                    })),
                              ),
                              Flexible(
                                flex: 43,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.69,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard6OPtions(
                                        constraints,
                                      );
                                    })),
                              ),
                              Flexible(
                                flex: 5,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.83,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.146,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.045,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Join Community',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 32.29999923706055,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              letterSpacing: 0.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ))),
                              ),
                              Spacer(
                                flex: 51,
                              ),
                              Flexible(
                                flex: 8,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.69,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard(
                                        constraints,
                                      );
                                    })),
                              ),
                              Flexible(
                                flex: 36,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.35,
                                      right: MediaQuery.of(context).size.width *
                                          0.37,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.264,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.369,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 34,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return CryptoItem(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 34,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return CryptoItem(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 34,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return CryptoItem(
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
