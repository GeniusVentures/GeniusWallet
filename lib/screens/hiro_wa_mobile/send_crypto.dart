import 'package:flutter/material.dart';
import '../../view/symbols/cover_send_crypto.dart';
import '../../view/symbols/navigation_next.dart';
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
                      flex: 32,
                      child: Padding(
                          padding: EdgeInsets.only(),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 1.001,
                              height:
                                  MediaQuery.of(context).size.height * 0.287,
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
                                      return CoverSendCrypto(
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
                                        0.227,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return NavigationNext(
                                        constraints,
                                      );
                                    }),
                                  ),
                                ]),
                              ))),
                    ),
                    Spacer(
                      flex: 9,
                    ),
                    Flexible(
                      flex: 41,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.16,
                            right: MediaQuery.of(context).size.width * 0.16,
                          ),
                          child: Image.asset(
                            'assets/images/0_154.png',
                            width: MediaQuery.of(context).size.width * 0.688,
                            height: MediaQuery.of(context).size.height * 0.367,
                          )),
                    ),
                    Spacer(
                      flex: 13,
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
