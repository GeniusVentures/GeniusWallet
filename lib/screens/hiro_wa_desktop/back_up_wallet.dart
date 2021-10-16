import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/navigation_back.dart';
import '../../view/symbols/cover_text_desktop.dart';
import '../../view/symbols/genius_checkbox.dart';
import '../../view/symbols/button_inactive_desktop.dart';

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
                  left: MediaQuery.of(context).size.width * 0.104,
                  right: MediaQuery.of(context).size.width * 0.506,
                  top: MediaQuery.of(context).size.height * 0.083,
                  bottom: MediaQuery.of(context).size.height * 0.848,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return NavigationBack(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.324,
                  right: MediaQuery.of(context).size.width * 0.324,
                  top: MediaQuery.of(context).size.height * 0.088,
                  bottom: MediaQuery.of(context).size.height * 0.531,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return CoverTextDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.409,
                  right: MediaQuery.of(context).size.width * 0.409,
                  top: MediaQuery.of(context).size.height * 0.378,
                  bottom: MediaQuery.of(context).size.height * 0.284,
                  child: Image.asset(
                    'assets/images/0_229.png',
                    width: MediaQuery.of(context).size.width * 0.181,
                    height: MediaQuery.of(context).size.height * 0.338,
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.365,
                  right: MediaQuery.of(context).size.width * 0.344,
                  top: MediaQuery.of(context).size.height * 0.779,
                  bottom: MediaQuery.of(context).size.height * 0.089,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.290,
                      height: MediaQuery.of(context).size.height * 0.132,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 27,
                                child: Padding(
                                    padding: EdgeInsets.only(),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return GeniusCheckboxcustom(
                                        constraints,
                                      );
                                    })),
                              ),
                              Spacer(
                                flex: 29,
                              ),
                              Flexible(
                                flex: 45,
                                child: Padding(
                                    padding: EdgeInsets.only(),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return ButtonInactiveDesktop(
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
