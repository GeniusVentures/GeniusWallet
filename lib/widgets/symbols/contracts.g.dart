import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/contract_icon.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Contracts extends StatelessWidget {
  final constraints;
  final ovrSmartContractCall;
  final ovrETH;
  final ovrTo0x033526b9bF6;
  final ovrContractIcon2;
  Contracts(
    this.constraints, {
    Key key,
    this.ovrSmartContractCall,
    this.ovrETH,
    this.ovrTo0x033526b9bF6,
    this.ovrContractIcon2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: constraints.maxWidth * 310.000,
          height: constraints.maxHeight * 45.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: 48.0,
        right: 63.0,
        top: 2.0,
        bottom: 22.0,
        child: Container(
            width: constraints.maxWidth * 199.000,
            height: constraints.maxHeight * 21.000,
            child: AutoSizeText(
              ovrSmartContractCall ?? 'Smart Contract Call',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
      Positioned(
        left: 247.0,
        right: 7.0,
        top: 12.0,
        bottom: 12.0,
        child: Container(
            width: constraints.maxWidth * 56.000,
            height: constraints.maxHeight * 21.000,
            child: AutoSizeText(
              ovrETH ?? 'ETH',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            )),
      ),
      Positioned(
        left: 48.0,
        right: 24.0,
        top: 22.0,
        bottom: 5.0,
        child: Container(
            width: constraints.maxWidth * 238.000,
            height: constraints.maxHeight * 18.000,
            child: AutoSizeText(
              ovrTo0x033526b9bF6 ?? 'To: 0x03352...6b9bF6',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 12.0,
                fontWeight: FontWeight.w100,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            )),
      ),
      Positioned(
        left: 6.0,
        width: 35.0,
        top: constraints.maxHeight * 0.111,
        height: constraints.maxHeight * 0.778,
        child: LayoutBuilder(builder: (context, constraints) {
          return ContractIcon(
            constraints,
          );
        }),
      ),
    ]);
  }
}
