import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/crypto_item.g.dart';
import 'package:geniuswallet/widgets/symbols/settings_card6_o_ptions.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_balance_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/settings_card.g.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';

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
          width: MediaQuery.of(context).size.width * 1.0,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.062,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavbarDesktop(
              constraints,
              ovrWallet: 'Wallet',
              ovrShield: 'assets/images/I0_324;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_324;0_12570.png',
              ovrDex2: 'Dex',
              ovrTriangle: 'assets/images/I0_324;0_12551.png',
              ovrAvatar: 'assets/images/I0_324;0_12550.png',
            );
          }),
        ),
        Positioned(
          left: 558.5,
          width: 33.0,
          top: 50.5,
          height: 33.0,
          child: Image.asset(
            'assets/images/0_339.png',
            height: 33.000,
            width: 33.000,
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.264,
          top: MediaQuery.of(context).size.height * 0.631,
          height: MediaQuery.of(context).size.height * 0.123,
          child: LayoutBuilder(builder: (context, constraints) {
            return CryptoItem(
              constraints,
              ovrLine: 'assets/images/I0_327;0_12431.png',
              ovrEllipse: 'assets/images/I0_327;0_12432.png',
              ovr2099: '\$20.99',
              ovr0BTC: '0.0065 ETH',
              ovr418: '+5.25%',
              ovr4630950: '\$3,218.64',
              ovrCrypto: 'Ethereum',
            );
          }),
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
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.264,
          top: MediaQuery.of(context).size.height * 0.754,
          height: MediaQuery.of(context).size.height * 0.123,
          child: LayoutBuilder(builder: (context, constraints) {
            return CryptoItem(
              constraints,
              ovrLine: 'assets/images/I0_328;0_12431.png',
              ovrEllipse: 'assets/images/I0_328;0_12432.png',
              ovr2099: ' ',
              ovr0BTC: '0 BTC',
              ovr418: '+4.18%',
              ovr4630950: '\$46,309.50',
              ovrCrypto: 'Bitcoin',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.264,
          top: MediaQuery.of(context).size.height * 0.877,
          height: MediaQuery.of(context).size.height * 0.123,
          child: LayoutBuilder(builder: (context, constraints) {
            return CryptoItem(
              constraints,
              ovrLine: 'assets/images/I0_329;0_12431.png',
              ovrEllipse: 'assets/images/I0_329;0_12432.png',
              ovr2099: ' ',
              ovr0BTC: '606.147 GNUS',
              ovr418: ' ',
              ovr4630950: ' ',
              ovrCrypto: 'Genius Token',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.324,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.114,
          height: MediaQuery.of(context).size.height * 0.467,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverBalanceDesktop(
              constraints,
              ovrText: 'Main Wallet1',
              ovrAmount: '\$20.99',
              ovrCollectibles: 'Collectibles',
              ovrFinance: 'Finance',
              ovrLine: 'assets/images/I0_330;0_12741.png',
              ovrTokens: 'Tokens',
            );
          }),
        ),
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 0.34,
          top: 0,
          height: MediaQuery.of(context).size.height * 1.0,
          child: Container(
            height: MediaQuery.of(context).size.height * 1.000,
            width: MediaQuery.of(context).size.width * 0.340,
            decoration: BoxDecoration(
              color: Color(0xff003698),
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
          ),
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
        Positioned(
          left: MediaQuery.of(context).size.width * 0.017,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.113,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard(
              constraints,
              ovrTypesomething: 'Price Alerts',
              ovrRectangle2: 'assets/images/I0_333;0_12272.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.017,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.256,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard(
              constraints,
              ovrTypesomething: 'WalletConnect',
              ovrRectangle2: 'assets/images/I0_334;0_12272.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.017,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.456,
          height: MediaQuery.of(context).size.height * 0.45,
          child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard6OPtions(
              constraints,
              ovrLineCopy2: 'assets/images/I0_335;0_12348.png',
              ovrLineCopy3: 'assets/images/I0_335;0_12349.png',
              ovrLineCopy4: 'assets/images/I0_335;0_12350.png',
              ovrLineCopy5: 'assets/images/I0_335;0_12351.png',
              ovrLineCopy6: 'assets/images/I0_335;0_12352.png',
              ovrTypesomething: 'Help Center',
              ovrRectangle2: 'assets/images/I0_335;0_12316.png',
              ovrTypesomething2: 'Twitter',
              ovrRectangle22: 'assets/images/I0_335;0_12322.png',
              ovrTypesomething3: 'Telegram',
              ovrRectangle23: 'assets/images/I0_335;0_12328.png',
              ovrTypesomething4: 'Facebook',
              ovrRectangle24: 'assets/images/I0_335;0_12334.png',
              ovrTypesomething5: 'Reddit',
              ovrRectangle25: 'assets/images/I0_335;0_12340.png',
              ovrTypesomething6: 'Youtube',
              ovrRectangle26: 'assets/images/I0_335;0_12346.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.018,
          width: MediaQuery.of(context).size.width * 0.291,
          top: MediaQuery.of(context).size.height * 0.973,
          height: MediaQuery.of(context).size.height * 0.075,
          child: LayoutBuilder(builder: (context, constraints) {
            return SettingsCard(
              constraints,
              ovrTypesomething: 'About',
              ovrRectangle2: 'assets/images/I0_336;0_12272.png',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.024,
          width: MediaQuery.of(context).size.width * 0.146,
          top: MediaQuery.of(context).size.height * 0.397,
          height: MediaQuery.of(context).size.height * 0.045,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.146,
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
          left: MediaQuery.of(context).size.width * 0.023,
          width: MediaQuery.of(context).size.width * 0.146,
          top: MediaQuery.of(context).size.height * 0.04,
          height: MediaQuery.of(context).size.height * 0.045,
          child: Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.146,
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
