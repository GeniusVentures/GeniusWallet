import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/contract_icon.g.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ContractsDesktop extends StatelessWidget {
  final constraints;
  final ovrSmartContractCall;
  final ovrETH;
  final ovrTo0x033526b9bF6;
  final ovrContractIcon2;
  ContractsDesktop(
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
          width: constraints.maxWidth * 385.000,
          height: constraints.maxHeight * 71.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      Positioned(
        left: 85.0,
        right: 72.0,
        top: constraints.maxHeight * 0.028,
        height: constraints.maxHeight * 0.366,
        child: Center(
            child: Container(
                height: 26.0,
                child: Container(
                    width: constraints.maxWidth * 228.000,
                    height: constraints.maxHeight * 26.000,
                    child: AutoSizeText(
                      ovrSmartContractCall ?? 'Smart Contract Call',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        left: 297.0,
        right: 9.0,
        top: constraints.maxHeight * 0.366,
        height: constraints.maxHeight * 0.268,
        child: Center(
            child: Container(
                height: 19.0,
                child: Container(
                    width: constraints.maxWidth * 79.000,
                    height: constraints.maxHeight * 19.000,
                    child: AutoSizeText(
                      ovrETH ?? 'ETH',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    )))),
      ),
      Positioned(
        left: 85.0,
        right: 62.0,
        top: constraints.maxHeight * 0.535,
        height: constraints.maxHeight * 0.296,
        child: Center(
            child: Container(
                height: 21.0,
                child: Container(
                    width: constraints.maxWidth * 238.000,
                    height: constraints.maxHeight * 21.000,
                    child: AutoSizeText(
                      ovrTo0x033526b9bF6 ?? 'To: 0x03352...6b9bF6',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w100,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        left: 6.0,
        width: 60.0,
        top: constraints.maxHeight * 0.085,
        height: constraints.maxHeight * 0.845,
        child: Center(
            child: Container(
                height: 60.0,
                child: LayoutBuilder(builder: (context, constraints) {
                  return ContractIcon(
                    constraints,
                  );
                }))),
      ),
    ]);
  }
}
