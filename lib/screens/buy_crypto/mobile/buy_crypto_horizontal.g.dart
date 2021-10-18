import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/dial_pad.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/double_info.g.dart';
import 'package:geniuswallet/widgets/symbols/price_chart.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_buy_crypto_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:geniuswallet/widgets/symbols/transaction_history.g.dart';

class BuyCryptoHorizontal extends StatefulWidget {
  const BuyCryptoHorizontal() : super();
  @override
  _BuyCryptoHorizontal createState() => _BuyCryptoHorizontal();
}

class _BuyCryptoHorizontal extends State<BuyCryptoHorizontal> {
  _BuyCryptoHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 0,
          height: MediaQuery.of(context).size.height * 1.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.578,
          width: MediaQuery.of(context).size.width * 0.26,
          top: MediaQuery.of(context).size.height * 0.11,
          height: MediaQuery.of(context).size.height * 0.841,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.841,
            width: MediaQuery.of(context).size.width * 0.260,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.062,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavbarDesktop(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_262;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_262;0_12570.png',
              ovrDex2: 'Dex',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.578,
          width: MediaQuery.of(context).size.width * 0.26,
          top: MediaQuery.of(context).size.height * 0.11,
          height: MediaQuery.of(context).size.height * 0.287,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverBuyCryptoDesktop(
              constraints,
              ovrTitle: 'ethereum',
              ovrText: '~ 0.0449 ETH',
              ovrAmount: '\$150',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.13,
          width: MediaQuery.of(context).size.width * 0.414,
          top: MediaQuery.of(context).size.height * 0.11,
          height: MediaQuery.of(context).size.height * 0.335,
          child: LayoutBuilder(builder: (context, constraints) {
            return PriceChart(
              constraints,
              ovrPath4: 'assets/images/I0_264;0_12639.png',
              ovr1jan: '1 jan',
              ovr18dec: '18 dec',
              ovr4dec: '4 dec',
              ovr20nov: '20 nov',
              ovr6nov: '6 nov',
              ovr23oct: '23 oct',
              ovr0k: '0k',
              ovr5k: '5k',
              ovr10k: '10k',
              ovr20k: '20k',
              ovr15k: '15k',
              ovrAll: 'All',
              ovr1y: '1y',
              ovr6m: '6m',
              ovr3m: '3m',
              ovr1m: '1m',
              ovrEthereumChart: 'Ethereum Chart',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.6,
          width: MediaQuery.of(context).size.width * 0.215,
          top: MediaQuery.of(context).size.height * 0.39,
          height: MediaQuery.of(context).size.height * 0.056,
          child: LayoutBuilder(builder: (context, constraints) {
            return DoubleInfo(
              constraints,
              ovrTypesomething: 'MoonPay',
              ovrTypesomethingCopy: 'Third Party Provider',
              ovrRectangle2: 'assets/images/I0_268;0_12279.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.6,
          width: MediaQuery.of(context).size.width * 0.215,
          top: MediaQuery.of(context).size.height * 0.513,
          height: MediaQuery.of(context).size.height * 0.283,
          child: LayoutBuilder(builder: (context, constraints) {
            return DialPad(
              constraints,
              ovr9: '9',
              ovr0: '0',
              ovr: '.',
              ovr8: '8',
              ovr7: '7',
              ovr6: '6',
              ovr5: '5',
              ovr4: '4',
              ovr3: '3',
              ovr2: '2',
              ovr1: '1',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.13,
          width: MediaQuery.of(context).size.width * 0.414,
          top: MediaQuery.of(context).size.height * 0.483,
          height: MediaQuery.of(context).size.height * 0.468,
          child: LayoutBuilder(builder: (context, constraints) {
            return TransactionHistory(
              constraints,
              ovrRECENT: 'RECENT',
              ovrSEND: 'SEND',
              ovrALL: 'ALL',
              ovrTransactions: 'Transactions',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.601,
          width: MediaQuery.of(context).size.width * 0.215,
          top: MediaQuery.of(context).size.height * 0.872,
          height: MediaQuery.of(context).size.height * 0.056,
          child: LayoutBuilder(builder: (context, constraints) {
            return ButtonActive(
              constraints,
              ovrTypesomething: 'Next',
            );
          }),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
