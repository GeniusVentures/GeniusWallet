import 'package:flutter/material.dart';
import './send.dart';
import './receive.dart';
import './copy.dart';
import './more.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverCryptoDesktop extends StatelessWidget {
  final constraints;

  CoverCryptoDesktop(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.896,
        height: constraints.maxHeight * 0.954,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 11,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.11,
                        right: MediaQuery.of(context).size.width * 0.11,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.670,
                          height: constraints.maxHeight * 0.096,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: AutoSizeText(
                              'Title',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ))),
                ),
                Spacer(
                  flex: 3,
                ),
                Flexible(
                  flex: 21,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.38,
                        right: MediaQuery.of(context).size.width * 0.38,
                      ),
                      child: Image.asset(
                        'assets/images/0_12664.png',
                        width: constraints.maxWidth * 0.140,
                        height: constraints.maxHeight * 0.193,
                      )),
                ),
                Flexible(
                  flex: 24,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 0.896,
                          height: constraints.maxHeight * 0.229,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Stack(children: [
                              Positioned(
                                left: constraints.maxWidth * 0.000,
                                right: constraints.maxWidth * 0.000,
                                top: constraints.maxHeight * 0.000,
                                bottom: constraints.maxHeight * 0.036,
                                child: Container(
                                    width: constraints.maxWidth * 0.896,
                                    height: constraints.maxHeight * 0.193,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: AutoSizeText(
                                        'Amount',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 36.0,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0.0,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.000,
                                right: constraints.maxWidth * 0.000,
                                top: constraints.maxHeight * 0.154,
                                bottom: constraints.maxHeight * 0.000,
                                child: Container(
                                    width: constraints.maxWidth * 0.896,
                                    height: constraints.maxHeight * 0.075,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: AutoSizeText(
                                        'Text',
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w100,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0.0,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                              ),
                            ]),
                          ))),
                ),
                Spacer(
                  flex: 2,
                ),
                Flexible(
                  flex: 5,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.32,
                        right: MediaQuery.of(context).size.width * 0.32,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.255,
                          height: constraints.maxHeight * 0.043,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 60,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: Container(
                                            width: constraints.maxWidth * 0.151,
                                            height:
                                                constraints.maxHeight * 0.043,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: AutoSizeText(
                                                '\$46,309.50',
                                                style: TextStyle(
                                                  fontFamily: 'Prompt',
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w300,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.0,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ))),
                                  ),
                                  Spacer(
                                    flex: 7,
                                  ),
                                  Flexible(
                                    flex: 35,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: Container(
                                            width: constraints.maxWidth * 0.088,
                                            height:
                                                constraints.maxHeight * 0.043,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: AutoSizeText(
                                                '+4.18%',
                                                style: TextStyle(
                                                  fontFamily: 'Prompt',
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.w300,
                                                  fontStyle: FontStyle.normal,
                                                  letterSpacing: 0.0,
                                                  color: Color(0xff00f1ac),
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ))),
                                  )
                                ]),
                          ))),
                ),
                Spacer(
                  flex: 6,
                ),
                Flexible(
                  flex: 32,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.07,
                        right: MediaQuery.of(context).size.width * 0.07,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.761,
                          height: constraints.maxHeight * 0.303,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 20,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return Send(
                                            constraints,
                                          );
                                        })),
                                  ),
                                  Spacer(
                                    flex: 8,
                                  ),
                                  Flexible(
                                    flex: 20,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return Receive(
                                            constraints,
                                          );
                                        })),
                                  ),
                                  Spacer(
                                    flex: 8,
                                  ),
                                  Flexible(
                                    flex: 20,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return Copy(
                                            constraints,
                                          );
                                        })),
                                  ),
                                  Spacer(
                                    flex: 8,
                                  ),
                                  Flexible(
                                    flex: 20,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: LayoutBuilder(
                                            builder: (context, constraints) {
                                          return More(
                                            constraints,
                                          );
                                        })),
                                  )
                                ]),
                          ))),
                ),
              ]),
        ));
  }
}
