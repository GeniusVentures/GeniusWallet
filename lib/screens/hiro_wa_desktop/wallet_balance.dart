import 'package:flutter/material.dart';
import '../../view/symbols/navbar_desktop.dart';
import '../../view/symbols/background_desktop.dart';
import '../../view/symbols/cover_balance_desktop.dart';
import '../../view/symbols/crypto_item.dart';

class WalletBalance extends StatefulWidget {
  const WalletBalance() : super();
  @override
  _WalletBalance createState() => _WalletBalance();
}

class _WalletBalance extends State<WalletBalance> {
  _WalletBalance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Align(
        alignment: Alignment(0.00, -1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.000,
            height: MediaQuery.of(context).size.height * 1.184,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Stack(children: [
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.000,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.000,
                  bottom: MediaQuery.of(context).size.height * 1.122,
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
                  bottom: MediaQuery.of(context).size.height * 0.184,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return BackgroundDesktop(
                      constraints,
                    );
                  }),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.324,
                  right: MediaQuery.of(context).size.width * 0.000,
                  top: MediaQuery.of(context).size.height * 0.114,
                  bottom: MediaQuery.of(context).size.height * 0.000,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.676,
                      height: MediaQuery.of(context).size.height * 1.070,
                      child: Align(
                        alignment: Alignment(0.00, 0.00),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 44,
                                child: Padding(
                                    padding: EdgeInsets.only(
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
                              Spacer(
                                flex: 5,
                              ),
                              Flexible(
                                flex: 35,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.04,
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
                              Flexible(
                                flex: 64,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.36,
                                    ),
                                    child: Image.asset(
                                      'assets/images/0_295.png',
                                      width: MediaQuery.of(context).size.width *
                                          0.312,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.683,
                                    )),
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
