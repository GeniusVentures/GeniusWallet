import 'package:flutter/material.dart';
import '../../view/symbols/background.dart';
import '../../view/symbols/settings_card.dart';
import '../../view/symbols/settings_card_6_o_ptions.dart';
import '../../view/symbols/navbar.dart';
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
        alignment: Alignment(0.00, 1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.986,
            height: MediaQuery.of(context).size.height * 0.978,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.093,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Background(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.896,
                  right: MediaQuery.of(context).size.width * 0.898,
                  top: MediaQuery.of(context).size.height * 0.037,
                  bottom: MediaQuery.of(context).size.height * 0.908,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.192,
                      height: MediaQuery.of(context).size.height * 0.033,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: AutoSizeText(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.493,
                  right: MediaQuery.of(context).size.width * 0.492,
                  top: MediaQuery.of(context).size.height * 0.127,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 1.000,
                      height: MediaQuery.of(context).size.height * 0.851,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 7,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.09,
                                      right: MediaQuery.of(context).size.width *
                                          0.09,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard(
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
                                      left: MediaQuery.of(context).size.width *
                                          0.09,
                                      right: MediaQuery.of(context).size.width *
                                          0.09,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard(
                                        constraints,
                                      );
                                    })),
                              ),
                              Spacer(
                                flex: 6,
                              ),
                              Flexible(
                                flex: 4,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.10,
                                      right: MediaQuery.of(context).size.width *
                                          0.48,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.416,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.033,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Join Community',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 18.0,
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
                                flex: 2,
                              ),
                              Flexible(
                                flex: 40,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.09,
                                      right: MediaQuery.of(context).size.width *
                                          0.09,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard6OPtions(
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
                                      left: MediaQuery.of(context).size.width *
                                          0.09,
                                      right: MediaQuery.of(context).size.width *
                                          0.09,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return SettingsCard(
                                        constraints,
                                      );
                                    })),
                              ),
                              Spacer(
                                flex: 8,
                              ),
                              Flexible(
                                flex: 12,
                                child: Padding(
                                    padding: EdgeInsets.only(),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return Navbar(
                                        constraints,
                                      );
                                    })),
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
