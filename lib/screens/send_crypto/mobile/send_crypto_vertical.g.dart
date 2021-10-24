import 'package:flutter/material.dart';
import 'package:geniuswallet/controller/tag/button_active_custom.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_next.g.dart';
import 'package:geniuswallet/widgets/symbols/cover_send_crypto.g.dart';

class SendCryptoVertical extends StatefulWidget {
  const SendCryptoVertical() : super();
  @override
  _SendCryptoVertical createState() => _SendCryptoVertical();
}

class _SendCryptoVertical extends State<SendCryptoVertical> {
  _SendCryptoVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 32.456,
          right: 33.0,
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
          left: MediaQuery.of(context).size.width * 0.156,
          width: MediaQuery.of(context).size.width * 0.688,
          top: 331.0,
          height: 298.31,
          child: Center(
              child: Container(
                  width: 258.0489501953125,
                  child: Image.asset(
                    'assets/images/166_1945.png',
                    height: 298.310,
                    width: 258.049,
                  ))),
        ),
        Positioned(
          left: 0.456,
          right: 0,
          top: 37.0,
          height: 233.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return CoverSendCrypto(
              constraints,
              ovrSendeth: 'Send eth',
            );
          }),
        ),
        Positioned(
          left: 0,
          right: 0.456,
          top: 48.963,
          height: 37.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationNext(
              constraints,
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
