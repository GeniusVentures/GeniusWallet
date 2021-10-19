import 'package:flutter/material.dart';
import 'package:geniuswallet/widgets/symbols/button_active.g.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:geniuswallet/widgets/symbols/transactions.g.dart';

class TransactionHistory extends StatelessWidget {
  final constraints;
  final ovrTransactions2Copy3;
  final ovrTransactions2Copy2;
  final ovrTransactions2Copy;
  final ovrTransactions2;
  final ovrRECENT;
  final ovrSEND;
  final ovrALL;
  final ovrButtonActiveCopy;
  final ovrTransactions;
  TransactionHistory(
    this.constraints, {
    Key key,
    this.ovrTransactions2Copy3,
    this.ovrTransactions2Copy2,
    this.ovrTransactions2Copy,
    this.ovrTransactions2,
    this.ovrRECENT,
    this.ovrSEND,
    this.ovrALL,
    this.ovrButtonActiveCopy,
    this.ovrTransactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 795.000,
          height: constraints.maxHeight * 505.000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      Positioned(
        left: 0,
        width: constraints.maxWidth * 1.0,
        top: 0,
        height: constraints.maxHeight * 1.0,
        child: Container(
          width: constraints.maxWidth * 795.000,
          height: constraints.maxHeight * 505.000,
          decoration: BoxDecoration(
            color: Color(0xff003698),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
      ),
      Positioned(
        left: constraints.maxWidth * 0.059,
        width: constraints.maxWidth * 0.323,
        top: constraints.maxHeight * 0.063,
        height: constraints.maxHeight * 0.059,
        child: Center(
            child: Container(
                height: 30.0,
                child: Container(
                    width: constraints.maxWidth * 256.534,
                    height: constraints.maxHeight * 30.000,
                    child: AutoSizeText(
                      ovrTransactions ?? 'Transactions',
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )))),
      ),
      Positioned(
        right: 48.3,
        width: 150.0,
        top: 36.899,
        height: 17.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            width: 150.0,
            top: 0,
            height: 17.0,
            child: Container(
              width: constraints.maxWidth * 150.000,
              height: constraints.maxHeight * 17.000,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 22.0,
            top: 0,
            height: 17.0,
            child: Container(
                width: constraints.maxWidth * 22.000,
                height: constraints.maxHeight * 17.000,
                child: AutoSizeText(
                  ovrALL ?? 'ALL',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.4124999940395355,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
          Positioned(
            left: 49.0,
            width: 30.0,
            top: 0,
            height: 17.0,
            child: Container(
                width: constraints.maxWidth * 30.000,
                height: constraints.maxHeight * 17.000,
                child: AutoSizeText(
                  ovrSEND ?? 'SEND',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.4124999940395355,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
          Positioned(
            left: 106.0,
            width: 44.0,
            top: 0,
            height: 17.0,
            child: Container(
                width: constraints.maxWidth * 44.000,
                height: constraints.maxHeight * 17.000,
                child: AutoSizeText(
                  ovrRECENT ?? 'RECENT',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.4124999940395355,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
        ]),
      ),
      Positioned(
        left: constraints.maxWidth * 0.668,
        width: constraints.maxWidth * 0.272,
        top: constraints.maxHeight * 0.831,
        height: constraints.maxHeight * 0.119,
        child: LayoutBuilder(builder: (context, constraints) {
          return ButtonActive(
            constraints,
            ovrTypesomething: 'View More',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.058,
        width: constraints.maxWidth * 0.882,
        top: constraints.maxHeight * 0.172,
        height: constraints.maxHeight * 0.142,
        child: LayoutBuilder(builder: (context, constraints) {
          return Transactions(
            constraints,
            ovrVector: 'assets/images/I0_12603;222_3827.png',
            ovr1PRj85hu9RXPZTzxtko9: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
            ovr0009ETH: '0.009 ETH',
            ovr162312dec2018: '16:23, 12 dec 2018',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.057,
        width: constraints.maxWidth * 0.882,
        top: constraints.maxHeight * 0.327,
        height: constraints.maxHeight * 0.142,
        child: LayoutBuilder(builder: (context, constraints) {
          return Transactions(
            constraints,
            ovrVector: 'assets/images/I0_12604;222_3827.png',
            ovr1PRj85hu9RXPZTzxtko9: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
            ovr0009ETH: '0.009 ETH',
            ovr162312dec2018: '16:23, 12 dec 2018',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.057,
        width: constraints.maxWidth * 0.882,
        top: constraints.maxHeight * 0.483,
        height: constraints.maxHeight * 0.142,
        child: LayoutBuilder(builder: (context, constraints) {
          return Transactions(
            constraints,
            ovrVector: 'assets/images/I0_12605;222_3827.png',
            ovr1PRj85hu9RXPZTzxtko9: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
            ovr0009ETH: '0.009 ETH',
            ovr162312dec2018: '16:23, 12 dec 2018',
          );
        }),
      ),
      Positioned(
        left: constraints.maxWidth * 0.057,
        width: constraints.maxWidth * 0.882,
        top: constraints.maxHeight * 0.64,
        height: constraints.maxHeight * 0.142,
        child: LayoutBuilder(builder: (context, constraints) {
          return Transactions(
            constraints,
            ovrVector: 'assets/images/I0_12606;222_3827.png',
            ovr1PRj85hu9RXPZTzxtko9: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
            ovr0009ETH: '0.009 ETH',
            ovr162312dec2018: '16:23, 12 dec 2018',
          );
        }),
      ),
    ]);
  }
}
