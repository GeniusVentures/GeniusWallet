import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/double_info_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_button_desktop.g.dart';

class NewWalletHorizontal extends StatefulWidget {
  const NewWalletHorizontal() : super();
  @override
  _NewWalletHorizontal createState() => _NewWalletHorizontal();
}

class _NewWalletHorizontal extends State<NewWalletHorizontal> {
  _NewWalletHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: MediaQuery.of(context).size.width * 0.001,
          width: MediaQuery.of(context).size.width * 0.999,
          top: 0,
          height: MediaQuery.of(context).size.height * 1.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
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
              ovrShield: Image.asset(
                'assets/images/I0_343;0_12560.png',
                height: MediaQuery.of(context).size.height * 0.026,
                width: MediaQuery.of(context).size.width * 0.012,
              ),
              ovrsettings: 'settings',
              ovrEllipseXor: Image.asset(
                'assets/images/I0_343;0_12570.png',
                height: MediaQuery.of(context).size.height * 0.021,
                width: MediaQuery.of(context).size.width * 0.012,
              ),
              ovrDex2: 'Dex',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.144,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.229,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return DoubleInfoDesktop(
              constraints,
              ovrTypesomething: 'Buy Genius Tokens',
              ovrTypesomethingCopy: 'gnus.ai',
              ovrRectangle2: Image.asset(
                'assets/images/I206_3656;206_3652.png',
                height: 60.000,
                width: 60.000,
              ),
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.518,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.309,
          height: MediaQuery.of(context).size.height * 0.381,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverButtonDesktop(
              constraints,
              ovrTitle:
                  'connect your wallet with walletconnect to make transactions',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.214,
          width: MediaQuery.of(context).size.width * 0.15,
          top: MediaQuery.of(context).size.height * 0.402,
          height: MediaQuery.of(context).size.height * 0.415,
          child: Image.asset(
            'assets/images/222_3743.png',
            height: MediaQuery.of(context).size.height * 0.415,
            width: MediaQuery.of(context).size.width * 0.150,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.144,
          width: MediaQuery.of(context).size.width * 0.237,
          top: MediaQuery.of(context).size.height * 0.16,
          height: MediaQuery.of(context).size.height * 0.045,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.237,
              child: AutoSizeText(
                'Main wallet 1',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 36.0,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
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
