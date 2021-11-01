import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/text_inputwith_button.g.dart';
import 'package:geniuswallet/widgets/symbols/mult_choice.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_next.g.dart';
import 'package:geniuswallet/widgets/symbols/genius_slider.g.dart';

class DappHorizontal extends StatefulWidget {
  const DappHorizontal() : super();
  @override
  _DappHorizontal createState() => _DappHorizontal();
}

class _DappHorizontal extends State<DappHorizontal> {
  _DappHorizontal();

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
                'assets/images/I0_509;0_12560.png',
                height: MediaQuery.of(context).size.height * 0.026,
                width: MediaQuery.of(context).size.width * 0.012,
              ),
              ovrsettings: 'settings',
              ovrEllipseXor: Image.asset(
                'assets/images/I0_509;0_12570.png',
                height: MediaQuery.of(context).size.height * 0.021,
                width: MediaQuery.of(context).size.width * 0.012,
              ),
              ovrDex2: 'Dex',
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
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.326,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return TextInputwithButton(
              constraints,
              ovrType: 'GNUS Amount',
              ovrPaste: 'MAX GNUS',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.421,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return TextInputwithButton(
              constraints,
              ovrType: 'Link to data',
              ovrPaste: 'Paste',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.516,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return MultChoice(
              constraints,
              ovrType: 'protocol selection',
              ovrTriangle: Image.asset(
                'assets/images/I0_515;0_12530.png',
                height: MediaQuery.of(context).size.height * 0.015,
                width: MediaQuery.of(context).size.width * 0.019,
              ),
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.611,
          height: MediaQuery.of(context).size.height * 0.137,
          child: LayoutBuilder(builder: (context, constraints) {
            return GeniusSlider(
              constraints,
              ovrType: 'amount to pay per gB',
              ovrTypeCopy3: '\$0.98',
              ovrTypeCopy: '\$0.01',
              ovrTypeCopy2: '\$5.00',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.355,
          width: MediaQuery.of(context).size.width * 0.055,
          top: MediaQuery.of(context).size.height * 0.267,
          height: MediaQuery.of(context).size.height * 0.045,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.055,
              child: AutoSizeText(
                'Details',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 32.29999923706055,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              )),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.382,
          width: MediaQuery.of(context).size.width * 0.242,
          top: MediaQuery.of(context).size.height * 0.143,
          height: MediaQuery.of(context).size.height * 0.045,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.242,
              child: AutoSizeText(
                'Job Information',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 32.29999923706055,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              )),
        ),
        Positioned(
          left: 1467.5,
          width: 550.301,
          top: 569.745,
          height: 528.71,
          child: Image.asset(
            'assets/images/0_519.png',
            height: 528.710,
            width: 550.301,
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
