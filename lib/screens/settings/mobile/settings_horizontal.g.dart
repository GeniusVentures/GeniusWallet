import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/exit_button_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/settings_card6_o_ptions.g.dart';
import 'package:geniuswallet/widgets/symbols/settings_card.g.dart';

class SettingsHorizontal extends StatefulWidget {
  const SettingsHorizontal() : super();
  @override
  _SettingsHorizontal createState() => _SettingsHorizontal();
}

class _SettingsHorizontal extends State<SettingsHorizontal> {
  _SettingsHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0,
          width: 652.0,
          top: 0,
          height: 1132.0,
          child: Stack(children: [
            Positioned(
              left: 0,
              width: 652.0,
              top: 0,
              height: 1132.0,
              child: Container(
                height: 1132.000,
                width: 652.000,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              width: 652.0,
              top: 0,
              height: 1080.0,
              child: Container(
                height: 1080.000,
                width: 652.000,
                decoration: BoxDecoration(
                  color: Color(0xff003698),
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: 558.5,
              width: 33.0,
              top: 50.5,
              height: 33.0,
              child: ExitButtonCustom(
                  child: Image.asset(
                'assets/images/187_3050.png',
                height: 33.000,
                width: 33.000,
              )),
            ),
            Positioned(
              left: 33.0,
              width: 558.0,
              top: 122.0,
              height: 81.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return SettingsCard(
                  constraints,
                  ovrTypesomething: 'Price Alerts',
                  ovrRectangle2: Image.asset(
                    'assets/images/I0_333;0_12272.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                );
              }),
            ),
            Positioned(
              left: 33.0,
              width: 558.0,
              top: 276.0,
              height: 81.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return SettingsCard(
                  constraints,
                  ovrTypesomething: 'WalletConnect',
                  ovrRectangle2: Image.asset(
                    'assets/images/I0_334;0_12272.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                );
              }),
            ),
            Positioned(
              left: 33.0,
              width: 558.0,
              top: 493.0,
              height: 486.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return SettingsCard6OPtions(
                  constraints,
                  ovrLineCopy2: Image.asset(
                    'assets/images/I0_335;0_12348.png',
                    height: MediaQuery.of(context).size.height * 0.003,
                    width: MediaQuery.of(context).size.width * 0.261,
                  ),
                  ovrLineCopy3: Image.asset(
                    'assets/images/I0_335;0_12349.png',
                    height: MediaQuery.of(context).size.height * 0.003,
                    width: MediaQuery.of(context).size.width * 0.261,
                  ),
                  ovrLineCopy4: Image.asset(
                    'assets/images/I0_335;0_12350.png',
                    height: MediaQuery.of(context).size.height * 0.003,
                    width: MediaQuery.of(context).size.width * 0.261,
                  ),
                  ovrLineCopy5: Image.asset(
                    'assets/images/I0_335;0_12351.png',
                    height: MediaQuery.of(context).size.height * 0.003,
                    width: MediaQuery.of(context).size.width * 0.261,
                  ),
                  ovrLineCopy6: Image.asset(
                    'assets/images/I0_335;0_12352.png',
                    height: MediaQuery.of(context).size.height * 0.003,
                    width: MediaQuery.of(context).size.width * 0.261,
                  ),
                  ovrTypesomething: 'Help Center',
                  ovrRectangle2: Image.asset(
                    'assets/images/I0_335;0_12316.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                  ovrTypesomething2: 'Twitter',
                  ovrRectangle22: Image.asset(
                    'assets/images/I0_335;0_12322.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                  ovrTypesomething3: 'Telegram',
                  ovrRectangle23: Image.asset(
                    'assets/images/I0_335;0_12328.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                  ovrTypesomething4: 'Facebook',
                  ovrRectangle24: Image.asset(
                    'assets/images/I0_335;0_12334.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                  ovrTypesomething5: 'Reddit',
                  ovrRectangle25: Image.asset(
                    'assets/images/I0_335;0_12340.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                  ovrTypesomething6: 'Youtube',
                  ovrRectangle26: Image.asset(
                    'assets/images/I0_335;0_12346.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                );
              }),
            ),
            Positioned(
              left: 34.0,
              width: 558.0,
              top: 1051.0,
              height: 81.0,
              child: LayoutBuilder(builder: (context, constraints) {
                return SettingsCard(
                  constraints,
                  ovrTypesomething: 'About',
                  ovrRectangle2: Image.asset(
                    'assets/images/I0_336;0_12272.png',
                    height: 35.000,
                    width: 35.000,
                  ),
                );
              }),
            ),
            Positioned(
              left: 46.0,
              width: 281.0,
              top: 429.0,
              height: 49.0,
              child: Container(
                  height: 49.000,
                  width: 281.000,
                  child: AutoSizeText(
                    'Join Community',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 32.29999923706055,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
            Positioned(
              left: 45.0,
              width: 281.0,
              top: 43.0,
              height: 49.0,
              child: Container(
                  height: 49.000,
                  width: 281.000,
                  child: AutoSizeText(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 32.29999923706055,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  )),
            ),
          ]),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.34,
          width: MediaQuery.of(context).size.width * 0.66,
          top: 0,
          height: MediaQuery.of(context).size.height * 1.0,
          child: Container(
            height: MediaQuery.of(context).size.height * 1.000,
            width: MediaQuery.of(context).size.width * 0.660,
            decoration: BoxDecoration(
              color: Color(0xff003698),
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
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
