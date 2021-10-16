import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/cover_send_crypto_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_next.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';

class SendCryptoHorizontal extends StatefulWidget {
  const SendCryptoHorizontal() : super();
  @override
  _SendCryptoHorizontal createState() => _SendCryptoHorizontal();
}

class _SendCryptoHorizontal extends State<SendCryptoHorizontal> {
  _SendCryptoHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.062,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavbarDesktop(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_475;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_475;0_12570.png',
              ovrDex2: 'Dex',
              ovrTriangle: 'assets/images/I0_475;0_12551.png',
              ovrAvatar: 'assets/images/I0_475;0_12550.png',
            );
          }),
        ),
        Positioned(
          left: 814.257,
          width: 291.455,
          top: 562.122,
          height: 336.878,
          child: Image.asset(
            'assets/images/0_480.png',
            height: 336.878,
            width: 291.455,
          ),
        ),
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
          left: MediaQuery.of(context).size.width * 0.324,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.114,
          height: MediaQuery.of(context).size.height * 0.388,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverSendCryptoDesktop(
              constraints,
              ovrPaste: 'Paste',
              ovrMaxETH: 'Max ETH',
              ovrETHAmount: 'ETH Amount',
              ovrRecipientAddress: 'Recipient Address',
              ovrSendeth: 'Send eth',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.135,
          width: MediaQuery.of(context).size.width * 0.73,
          top: MediaQuery.of(context).size.height * 0.127,
          height: MediaQuery.of(context).size.height * 0.069,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationNext(
              constraints,
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.36,
          width: MediaQuery.of(context).size.width * 0.28,
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
