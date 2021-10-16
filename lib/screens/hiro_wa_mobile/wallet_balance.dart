import 'package:flutter/material.dart';
import '../../view/symbols/cover_balance.dart';
import '../../view/symbols/navigation_menu.dart';
import '../../view/symbols/crypto_item.dart';
import '../../view/symbols/navbar.dart';

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
        alignment: Alignment(0.39, 1.00),
        child: Container(
            width: MediaQuery.of(context).size.width * 1.002,
            height: MediaQuery.of(context).size.height * 0.954,
            child: Align(
              alignment: Alignment(0.00, 0.00),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                      return CoverBalance(
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
                                        0.018,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.281,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                      return NavigationMenu(
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
                      flex: 10,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.13,
                            right: MediaQuery.of(context).size.width * 0.12,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return CryptoItem(
                              constraints,
                            );
                          })),
                    ),
                    Flexible(
                      flex: 10,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.13,
                            right: MediaQuery.of(context).size.width * 0.12,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return CryptoItem(
                              constraints,
                            );
                          })),
                    ),
                    Flexible(
                      flex: 10,
                      child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.13,
                            right: MediaQuery.of(context).size.width * 0.12,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return CryptoItem(
                              constraints,
                            );
                          })),
                    ),
                    Spacer(
                      flex: 23,
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
