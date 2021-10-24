import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/buy_crypto_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/navbar.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_button.g.dart';
import 'package:geniuswallet/widgets/symbols/double_info.g.dart';

class NewWalletVertical extends StatefulWidget {
  const NewWalletVertical() : super();
  @override
  _NewWalletVertical createState() => _NewWalletVertical();
}

class _NewWalletVertical extends State<NewWalletVertical> {
  _NewWalletVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0.2,
          right: 0,
          top: 37.0,
          height: 228.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverButton(
              constraints,
              ovrTitle:
                  'connect your wallet with walletconnect to make transactions',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 1.0,
          bottom: 0,
          height: 77.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return Navbar(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_78;0_12369.png',
              ovrDex: 'Dex',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_78;0_12375.png',
            );
          }),
        ),
        Positioned(
          left: 32.0,
          right: 33.2,
          top: 327.0,
          height: 45.0,
          child: BuyCryptoCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return DoubleInfo(
              constraints,
              ovrTypesomething: 'buy genius tokens',
              ovrTypesomethingCopy: 'gnus.ai',
              ovrRectangle2: 'assets/images/I0_79;0_12279.png',
            );
          })),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.287,
          width: MediaQuery.of(context).size.width * 0.426,
          top: 424.211,
          height: 248.789,
          child: Center(
              child: Container(
                  width: 159.60009765625,
                  child: Image.asset(
                    'assets/images/166_1883.png',
                    height: 248.789,
                    width: 159.600,
                  ))),
        ),
        Positioned(
          left: 33.0,
          width: 134.0,
          top: 286.0,
          height: 27.0,
          child: Container(
              height: 27.000,
              width: 134.000,
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
              )),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
