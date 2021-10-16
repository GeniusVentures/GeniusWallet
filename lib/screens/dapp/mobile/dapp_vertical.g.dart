import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/egg/priceslider.dart';
import 'package:geniuswallet/egg/buttonactivecustom.dart';
import 'package:geniuswallet/egg/gnusamountselectorcustom.dart';
import 'package:geniuswallet/egg/linktodataselectorcustom.dart';
import 'package:geniuswallet/egg/protocolselectorcustom.dart';
import 'package:geniuswallet/widgets/symbols/text_inputwith_button.g.dart';
import 'package:geniuswallet/widgets/symbols/navigation_next.g.dart';
import 'package:geniuswallet/widgets/symbols/mult_choice.g.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';

class DappVertical extends StatefulWidget {
  const DappVertical() : super();
  @override
  _DappVertical createState() => _DappVertical();
}

class _DappVertical extends State<DappVertical> {
  _DappVertical();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff003698),
      body: Stack(children: [
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 1.0,
          top: 48.963,
          height: 37.0,
          child: LayoutBuilder(builder: (context, constraints) {
            return NavigationNext(
              constraints,
            );
          }),
        ),
        Positioned(
          left: 32.456,
          right: 33.0,
          top: 335.0,
          height: 84.0,
          child: Stack(children: [
            Positioned(
              left: 0,
              width: MediaQuery.of(context).size.width * 0.827,
              top: 0,
              height: 82.0,
              child: Container(
                height: 82.000,
                width: MediaQuery.of(context).size.width * 0.827,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 19.0,
              top: 0,
              height: 27.0,
              child: Container(
                  height: 27.000,
                  width: MediaQuery.of(context).size.width * 0.776,
                  child: AutoSizeText(
                    'amount to pay per GB',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
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
              top: 41.0,
              height: 43.0,
              child: PriceSlider(
                  child: Stack(children: [
                Positioned(
                  left: 0,
                  width: MediaQuery.of(context).size.width * 0.827,
                  top: 0,
                  height: 43.0,
                  child: Container(
                    height: 43.000,
                    width: MediaQuery.of(context).size.width * 0.827,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                ),
                Positioned(
                  left: 130.5,
                  right: 131.5,
                  top: 16.0,
                  height: 27.0,
                  child: Container(
                      height: 27.000,
                      width: MediaQuery.of(context).size.width * 0.128,
                      child: AutoSizeText(
                        '\$0.98',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
                Positioned(
                  left: 0,
                  width: 25.0,
                  top: 21.5,
                  height: 15.0,
                  child: Container(
                      height: 15.000,
                      width: 25.000,
                      child: AutoSizeText(
                        '\$0.01',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      )),
                ),
                Positioned(
                  right: 0,
                  width: 27.0,
                  top: 21.5,
                  height: 15.0,
                  child: Container(
                      height: 15.000,
                      width: 27.000,
                      child: AutoSizeText(
                        '\$5.00',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      )),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 3.0,
                  height: 6.0,
                  child: Image.asset(
                    'assets/images/26_1893.png',
                    height: 6.000,
                    width: MediaQuery.of(context).size.width * 0.827,
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.349,
                  width: MediaQuery.of(context).size.width * 0.032,
                  top: 0,
                  height: 12.0,
                  child: Image.asset(
                    'assets/images/26_1890.png',
                    height: 12.000,
                    width: MediaQuery.of(context).size.width * 0.032,
                  ),
                ),
                Positioned(
                  left: 2.0,
                  width: 2.0,
                  top: 12.0,
                  height: 5.5,
                  child: Image.asset(
                    'assets/images/26_1891.png',
                    height: 5.500,
                    width: 2.000,
                  ),
                ),
                Positioned(
                  right: 2.0,
                  width: 2.0,
                  top: 12.0,
                  height: 5.5,
                  child: Image.asset(
                    'assets/images/26_1892.png',
                    height: 5.500,
                    width: 2.000,
                  ),
                ),
              ])),
            ),
          ]),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.268,
          width: MediaQuery.of(context).size.width * 0.468,
          top: 454.0,
          height: 248.0,
          child: Center(
              child: Container(
                  width: 175.668701171875,
                  child: Stack(children: [
                    Positioned(
                      left: 0,
                      width: 175.669,
                      top: 0,
                      height: 248.0,
                      child: Container(
                        height: 248.000,
                        width: 175.669,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      width: 175.669,
                      top: 0,
                      height: 248.0,
                      child: Image.asset(
                        'assets/images/0_194.png',
                        height: 248.000,
                        width: 175.669,
                      ),
                    ),
                  ]))),
        ),
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
          left: 32.456,
          right: 33.0,
          top: 164.0,
          height: 45.0,
          child: GnusAmountSelectorCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return TextInputwithButton(
              constraints,
              ovrType: 'GNUS amount',
              ovrPaste: 'MAX GNUS',
            );
          })),
        ),
        Positioned(
          left: 32.456,
          right: 33.0,
          top: 221.0,
          height: 45.0,
          child: LinkToDataSelectorCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return TextInputwithButton(
              constraints,
              ovrType: 'link to data',
              ovrPaste: 'Paste',
            );
          })),
        ),
        Positioned(
          left: 32.456,
          right: 33.0,
          top: 278.0,
          height: 45.0,
          child: ProtocolSelectorCustom(
              child: LayoutBuilder(builder: (context, constraints) {
            return MultChoice(
              constraints,
              ovrType: 'protocol selection',
              ovrTriangle: 'assets/images/I0_190;0_12530.png',
            );
          })),
        ),
        Positioned(
          left: 32.756,
          width: 59.0,
          top: 128.9,
          height: 27.0,
          child: Container(
              height: 27.000,
              width: 59.000,
              child: AutoSizeText(
                'Details',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              )),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.164,
          width: MediaQuery.of(context).size.width * 0.688,
          top: 54.0,
          height: 27.0,
          child: Center(
              child: Container(
                  width: 258.0,
                  child: Container(
                      height: 27.000,
                      width: 258.000,
                      child: AutoSizeText(
                        'Job Information',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      )))),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
