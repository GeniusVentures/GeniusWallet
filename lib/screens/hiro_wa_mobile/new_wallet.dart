import 'package:flutter/material.dart';
import '../../view/symbols/cover_button.dart';
import '../../view/symbols/double_info.dart';
import '../../view/symbols/navbar.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NewWallet extends StatefulWidget {
  const NewWallet() : super();
  @override
  _NewWallet createState() => _NewWallet();
}

class _NewWallet extends State<NewWallet> {
  _NewWallet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(0.00, 1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 0.954,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 30,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return CoverButton(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                    Flexible(
                      flex: 4,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.55,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.357,
                              height:
                                  MediaQuery.of(context).size.height * 0.033,
                              child: Align(
                                alignment: Alignment(0.00, 0.00),
                                child: AutoSizeText(
                                  'Main wallet 1',
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: 0.0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Flexible(
                      flex: 6,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.08,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return DoubleInfo(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 7,
                    ),
                    Flexible(
                      flex: 33,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.29,
                            right: MediaQuery.of(context).size.width * 0.29,
                          ),
                          child: Image.asset(
                            'assets/images/0_80.png',
                            width: MediaQuery.of(context).size.width * 0.426,
                            height: MediaQuery.of(context).size.height * 0.306,
                          )),
                    ),
                    Spacer(
                      flex: 9,
                    ),
                    Flexible(
                      flex: 10,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return Navbar(
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
