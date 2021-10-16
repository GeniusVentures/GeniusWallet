import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/navigation_next.dart';
import '../../view/symbols/text_input_with_button.dart';
import '../../view/symbols/mult_choice.dart';
import '../../view/symbols/genius_slider.dart';
import '../../view/symbols/button_active.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Dapp extends StatefulWidget {
  const Dapp() : super();
  @override
  _Dapp createState() => _Dapp();
}

class _Dapp extends State<Dapp> {
  _Dapp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(-1.00, -1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.051,
            height: MediaQuery.of(context).size.height * 1.017,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.051,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.955,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return NavbarDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.001,
                  right: MediaQuery.of(context).size.width * 0.051,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 0.017,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return BackgroundDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.135,
                  right: MediaQuery.of(context).size.width * 0.186,
                  top: MediaQuery.of(context).size.height * 0.127,
                  bottom: MediaQuery.of(context).size.height * 0.822,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return NavigationNext(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.355,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.143,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.696,
                      height: MediaQuery.of(context).size.height * 0.874,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 6,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.03,
                                      right: MediaQuery.of(context).size.width *
                                          0.38,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.242,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.045,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Job Information',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 32.29999923706055,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              letterSpacing: 0.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ))),
                              ),
                              Spacer(
                                flex: 10,
                              ),
                              Flexible(
                                flex: 6,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.59,
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.055,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.045,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: AutoSizeText(
                                            'Details',
                                            style: TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 32.29999923706055,
                                              fontWeight: FontWeight.w500,
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
                                flex: 9,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.35,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return TextInputWithButton(
                                        constraints,
                                      );
                                    })),
                              ),
                              Spacer(
                                flex: 3,
                              ),
                              Flexible(
                                flex: 9,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.35,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return TextInputWithButton(
                                        constraints,
                                      );
                                    })),
                              ),
                              Spacer(
                                flex: 3,
                              ),
                              Flexible(
                                flex: 58,
                                child: Padding(
                                    padding: EdgeInsets.only(),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.696,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.501,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 42,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.41,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return MultChoice(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Spacer(
                                                  flex: 18,
                                                ),
                                                Flexible(
                                                  flex: 42,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.01,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/0_519.png',
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.287,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.490,
                                                      )),
                                                ),
                                                Flexible(
                                                  flex: 42,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.10,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return GeniusSlider(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 41,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.07,
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.36,
                                                      ),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return ButtonActive(
                                                          constraints,
                                                        );
                                                      })),
                                                )
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
