import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/buy_crypto_button_custom.dart';
import 'package:geniuswallet/controller/tag/calculator_keyboard_custom.dart';
import 'package:geniuswallet/controller/tag/button_active_custom.dart';
import 'package:geniuswallet/widgets/symbols/dial_pad.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_info.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_buy_crypto.g.dart';
import 'package:geniuswallet/widgets/symbols/double_info.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';

class BuyCryptoVertical extends StatefulWidget {
  const BuyCryptoVertical() : super();
  @override
  _BuyCryptoVertical createState() => _BuyCryptoVertical();
}

class _BuyCryptoVertical extends State<BuyCryptoVertical> {
  _BuyCryptoVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 37.0,
          height: 233.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverBuyCrypto(
              constraints,
              ovrTitle: 'ethereum',
              ovrText: '~ 0.0449 ETH',
              ovrAmount: '\$150',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.087,
          width: MediaQuery.of(context).size.width * 0.827,
          top: 248.122,
          height: 45.0,
          child: BuyCryptoButtonCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return DoubleInfo(
              constraints,
              ovrTypesomething: 'MoonPay',
              ovrTypesomethingCopy: 'Third Party Provider',
              ovrRectangle2: Image.asset(
                'assets/images/I0_116;0_12279.png',
                height: 35.000,
                width: 35.000,
              ),
            );
          })),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.169,
          width: MediaQuery.of(context).size.width * 0.663,
          top: 376.0,
          height: 306.0,
          child: CalculatorKeyboardCustom(
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
          })),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.087,
          width: MediaQuery.of(context).size.width * 0.827,
          top: 722.847,
          height: 45.0,
          child: ButtonActiveCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return ButtonActive(
              constraints,
              ovrTypesomething: 'Next',
            );
          })),
        ),
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 48.963,
          height: 37.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationInfo(
              constraints,
              ovri: 'i',
              ovrEllipse: Image.asset(
                'assets/images/I0_119;0_12072.png',
                height: 20.000,
                width: 20.000,
              ),
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
