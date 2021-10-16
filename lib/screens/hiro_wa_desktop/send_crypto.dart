import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/navigation_next.dart';
import '../../view/symbols/cover_send_crypto_desktop.dart';
import '../../view/symbols/button_active.dart';

class SendCrypto extends StatefulWidget {
  const SendCrypto() : super();
  @override
  _SendCrypto createState() => _SendCrypto();
}

class _SendCrypto extends State<SendCrypto> {
  _SendCrypto();

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
                  left: MediaQuery.of(context).size.width * 0.135,
                  right: MediaQuery.of(context).size.width * 0.135,
                  top: MediaQuery.of(context).size.height * 0.114,
                  bottom: MediaQuery.of(context).size.height * 0.073,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.730,
                      height: MediaQuery.of(context).size.height * 0.813,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 89,
                                child: Padding(
                                    padding: EdgeInsets.only(),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.730,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.719,
                                        child: Align(
                                          alignment: Alignment(0.00, 0.00),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  flex: 10,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.only(),
                                                      child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                        return NavigationNext(
                                                          constraints,
                                                        );
                                                      })),
                                                ),
                                                Flexible(
                                                  flex: 100,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.19,
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.19,
                                                      ),
                                                      child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.352,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.719,
                                                          child: Align(
                                                            alignment:
                                                                Alignment(
                                                                    0.00, 0.00),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 55,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(),
                                                                        child: LayoutBuilder(builder: (context, constraints) {
                                                                          return CoverSendCryptoDesktop(
                                                                            constraints,
                                                                          );
                                                                        })),
                                                                  ),
                                                                  Spacer(
                                                                    flex: 3,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 44,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          left: MediaQuery.of(context).size.width *
                                                                              0.10,
                                                                          right:
                                                                              MediaQuery.of(context).size.width * 0.10,
                                                                        ),
                                                                        child: Image.asset(
                                                                          'assets/images/0_480.png',
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.152,
                                                                          height:
                                                                              MediaQuery.of(context).size.height * 0.312,
                                                                        )),
                                                                  ),
                                                                ]),
                                                          ))),
                                                ),
                                              ]),
                                        ))),
                              ),
                              Spacer(
                                flex: 5,
                              ),
                              Flexible(
                                flex: 7,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.23,
                                      right: MediaQuery.of(context).size.width *
                                          0.22,
                                    ),
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return ButtonActive(
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
