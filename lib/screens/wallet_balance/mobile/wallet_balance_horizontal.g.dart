import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/navbar_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/background_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/crypto_item_desktop.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_balance_desktop.g.dart';

class WalletBalanceHorizontal extends StatefulWidget {
  const WalletBalanceHorizontal() : super();
  @override
  _WalletBalanceHorizontal createState() => _WalletBalanceHorizontal();
}

class _WalletBalanceHorizontal extends State<WalletBalanceHorizontal> {
  _WalletBalanceHorizontal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 2.0,
          right: 0,
          top: 0,
          bottom: 198.271,
          child: LayoutBuilder(builder: (context, constraints) {
            return BackgroundDesktop(
              constraints,
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.261,
          top: MediaQuery.of(context).size.height * 0.756,
          height: MediaQuery.of(context).size.height * 0.114,
          child: Center(
              child: Container(
                  width: 501.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return CryptoItemDesktop(
                      constraints,
                      ovrLine: 'assets/images/I200_3415;200_3395.png',
                      ovrEllipse: 'assets/images/I200_3415;200_3396.png',
                      ovr2099: '\$20.99',
                      ovr0BTC: '0 BTC',
                      ovr418: '+4.18%',
                      ovr4630950: '\$46,309.50',
                      ovrCrypto: 'Bitcoin',
                    );
                  }))),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.263,
          top: MediaQuery.of(context).size.height * 0.879,
          height: MediaQuery.of(context).size.height * 0.119,
          child: Center(
              child: Container(
                  width: 505.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return CryptoItemDesktop(
                      constraints,
                      ovrLine: 'assets/images/I200_3425;200_3395.png',
                      ovrEllipse: 'assets/images/I200_3425;200_3396.png',
                      ovr2099: '\$20.99',
                      ovr0BTC: '0 BTC',
                      ovr418: '+4.18%',
                      ovr4630950: '\$46,309.50',
                      ovrCrypto: 'Genius Token',
                    );
                  }))),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.324,
          width: MediaQuery.of(context).size.width * 0.352,
          top: MediaQuery.of(context).size.height * 0.114,
          height: MediaQuery.of(context).size.height * 0.465,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverBalanceDesktop(
              constraints,
              ovrText: 'Main Wallet1',
              ovrAmount: '\$20.99',
              ovrCollectibles: 'Collectibles',
              ovrFinance: 'Finance',
              ovrLine: 'assets/images/I0_294;0_12741.png',
              ovrTokens: 'Tokens',
            );
          }),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.368,
          width: MediaQuery.of(context).size.width * 0.261,
          top: MediaQuery.of(context).size.height * 0.628,
          height: MediaQuery.of(context).size.height * 0.118,
          child: Center(
              child: Container(
                  width: 501.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return CryptoItemDesktop(
                      constraints,
                      ovrLine: 'assets/images/I200_3435;200_3395.png',
                      ovrEllipse: 'assets/images/I200_3435;200_3396.png',
                      ovr2099: '\$20.99',
                      ovr0BTC: '0.0065 ETH',
                      ovr418: '+5.25%',
                      ovr4630950: '\$3,218.64',
                      ovrCrypto: 'Ethereum',
                    );
                  }))),
        ),
        Positioned(
          left: 1321.8,
          width: 598.2,
          top: 540.9,
          height: 737.371,
          child: Image.asset(
            'assets/images/0_295.png',
            height: 737.371,
            width: 598.200,
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
              ovrShield: 'assets/images/I0_288;0_12560.png',
              ovrsettings: 'settings',
              ovrEllipseXor: 'assets/images/I0_288;0_12570.png',
              ovrDex2: 'Dex',
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
