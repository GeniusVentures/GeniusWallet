import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/controller/tag/price_alerts_custom.dart';
import 'package:geniuswallet/controller/tag/wallet_connect_custom.dart';
import 'package:geniuswallet/controller/tag/about_button_custom.dart';
import 'package:geniuswallet/widgets/symbols/settings_card6_o_ptions.g.dart';
import 'package:geniuswallet/widgets/symbols/background_mobile.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar.g.dart';
import 'package:geniuswallet/widgets/symbols/settings_card.g.dart';

class SettingsVertical extends StatefulWidget {
  const SettingsVertical() : super();
  @override
  _SettingsVertical createState() => _SettingsVertical();
}

class _SettingsVertical extends State<SettingsVertical> {
  _SettingsVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0,
          right: 0,
          top: 16.0,
          height: 718.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundMobile(
              constraints,
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.403,
          width: MediaQuery.of(context).size.width * 0.192,
          top: 48.0,
          height: 27.0,
          child: Center(
              child: Container(
                  width: 72.0,
                  child: Container(
                      height: 27.000,
                      width: 72.000,
                      child: AutoSizeText(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      )))),
        ),
        Positioned(
          left: 32.0,
          right: 33.0,
          top: 121.0,
          height: 45.0,
          child: PriceAlertsCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard(
              constraints,
              ovrTypesomething: 'Price Alerts',
              ovrRectangle2: Image.asset(
                'assets/images/I0_41;0_12272.png',
                height: 35.000,
                width: 35.000,
              ),
            );
          })),
        ),
        Positioned(
          left: 32.0,
          right: 33.0,
          top: 206.0,
          height: 45.0,
          child: WalletConnectCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard(
              constraints,
              ovrTypesomething: 'WalletConnect',
              ovrRectangle2: Image.asset(
                'assets/images/I0_42;0_12272.png',
                height: 35.000,
                width: 35.000,
              ),
            );
          })),
        ),
        Positioned(
          left: 32.0,
          right: 33.0,
          top: 326.8,
          height: 270.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard6OPtions(
              constraints,
              ovrLineCopy2: Image.asset(
                'assets/images/I0_43;0_12348.png',
                height: MediaQuery.of(context).size.height * 0.002,
                width: MediaQuery.of(context).size.width * 0.677,
              ),
              ovrLineCopy3: Image.asset(
                'assets/images/I0_43;0_12349.png',
                height: MediaQuery.of(context).size.height * 0.002,
                width: MediaQuery.of(context).size.width * 0.677,
              ),
              ovrLineCopy4: Image.asset(
                'assets/images/I0_43;0_12350.png',
                height: MediaQuery.of(context).size.height * 0.002,
                width: MediaQuery.of(context).size.width * 0.677,
              ),
              ovrLineCopy5: Image.asset(
                'assets/images/I0_43;0_12351.png',
                height: MediaQuery.of(context).size.height * 0.002,
                width: MediaQuery.of(context).size.width * 0.677,
              ),
              ovrLineCopy6: Image.asset(
                'assets/images/I0_43;0_12352.png',
                height: MediaQuery.of(context).size.height * 0.002,
                width: MediaQuery.of(context).size.width * 0.677,
              ),
              ovrTypesomething: 'Help Center',
              ovrRectangle2: Image.asset(
                'assets/images/I0_43;0_12316.png',
                height: 35.000,
                width: 35.000,
              ),
              ovrTypesomething2: 'Twitter',
              ovrRectangle22: Image.asset(
                'assets/images/I0_43;0_12322.png',
                height: 35.000,
                width: 35.000,
              ),
              ovrTypesomething3: 'Telegram',
              ovrRectangle23: Image.asset(
                'assets/images/I0_43;0_12328.png',
                height: 35.000,
                width: 35.000,
              ),
              ovrTypesomething4: 'Facebook',
              ovrRectangle24: Image.asset(
                'assets/images/I0_43;0_12334.png',
                height: 35.000,
                width: 35.000,
              ),
              ovrTypesomething5: 'Reddit',
              ovrRectangle25: Image.asset(
                'assets/images/I0_43;0_12340.png',
                height: 35.000,
                width: 35.000,
              ),
              ovrTypesomething6: 'Youtube',
              ovrRectangle26: Image.asset(
                'assets/images/I0_43;0_12346.png',
                height: 35.000,
                width: 35.000,
              ),
            );
          }),
        ),
        Positioned(
          left: 32.113,
          right: 32.887,
          top: 636.795,
          height: 45.0,
          child: AboutButtonCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard(
              constraints,
              ovrTypesomething: 'About',
              ovrRectangle2: Image.asset(
                'assets/images/I0_44;0_12272.png',
                height: 35.000,
                width: 35.000,
              ),
            );
          })),
        ),
        Positioned(
          left: 39.0,
          width: 156.0,
          top: 291.0,
          height: 27.0,
          child: Container(
              height: 27.000,
              width: 156.000,
              child: AutoSizeText(
                'Join Community',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              )),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 77.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return Navbar(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: Image.asset(
                'assets/images/I0_46;0_12369.png',
                height: 28.500,
                width: 22.871,
              ),
              ovrDex: 'Dex',
              ovrsettings: 'settings',
              ovrEllipseXor: Image.asset(
                'assets/images/I0_46;0_12375.png',
                height: MediaQuery.of(context).size.height * 0.028,
                width: MediaQuery.of(context).size.width * 0.060,
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
