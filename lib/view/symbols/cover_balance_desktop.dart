import 'package:flutter/material.dart';
import './send.dart';
import './receive.dart';
import './buy.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CoverBalanceDesktop extends StatelessWidget {
  final constraints;

  CoverBalanceDesktop(
    this.constraints, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: constraints.maxWidth * 0.893,
        height: constraints.maxHeight * 0.950,
        child: Align(
          alignment: Alignment(0.00, 0.00),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 11,
                  child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                        right: MediaQuery.of(context).size.width * 0.10,
                      ),
                      child: Container(
                          width: constraints.maxWidth * 0.701,
                          height: constraints.maxHeight * 0.096,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Stack(children: [
                              Container(
                                width: constraints.maxWidth * 0.701,
                                height: constraints.maxHeight * 0.096,
                                decoration: BoxDecoration(
                                  color: Color(0xff4f93ec),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  border: Border.all(
                                    color: Color(0x00000000),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.003,
                                right: constraints.maxWidth * 0.507,
                                top: constraints.maxHeight * 0.004,
                                bottom: constraints.maxHeight * 0.004,
                                child: Container(
                                  width: constraints.maxWidth * 0.192,
                                  height: constraints.maxHeight * 0.089,
                                  decoration: BoxDecoration(
                                    color: Color(0xff0050c4),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6.0)),
                                    border: Border.all(
                                      color: Color(0x00000000),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: constraints.maxWidth * 0.011,
                                right: constraints.maxWidth * 0.019,
                                top: constraints.maxHeight * 0.014,
                                bottom: constraints.maxHeight * 0.014,
                                child: Container(
                                    width: constraints.maxWidth * 0.672,
                                    height: constraints.maxHeight * 0.068,
                                    child: Align(
                                      alignment: Alignment(0.00, 0.00),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 27,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.176,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.068,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Tokens',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            ),
                                            Spacer(
                                              flex: 5,
                                            ),
                                            Flexible(
                                              flex: 27,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.176,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.068,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Finance',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            ),
                                            Spacer(
                                              flex: 4,
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Image.asset(
                                                    'assets/images/0_12741.png',
                                                    width:
                                                        constraints.maxWidth *
                                                            0.005,
                                                    height:
                                                        constraints.maxHeight *
                                                            0.068,
                                                  )),
                                            ),
                                            Spacer(
                                              flex: 3,
                                            ),
                                            Flexible(
                                              flex: 37,
                                              child: Padding(
                                                  padding: EdgeInsets.only(),
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.245,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.068,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Collectibles',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ))),
                                            )
                                          ]),
                                    )),
                              ),
                            ]),
                          ))),
                ),
                Spacer(
                  flex: 13,
                ),
                Flexible(
                  flex: 78,
                  child: Padding(
                      padding: EdgeInsets.only(),
                      child: Container(
                          width: constraints.maxWidth * 0.893,
                          height: constraints.maxHeight * 0.736,
                          child: Align(
                            alignment: Alignment(0.00, 0.00),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 31,
                                    child: Padding(
                                        padding: EdgeInsets.only(),
                                        child: Container(
                                            width: constraints.maxWidth * 0.893,
                                            height:
                                                constraints.maxHeight * 0.221,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: Stack(children: [
                                                Positioned(
                                                  left: constraints.maxWidth *
                                                      0.000,
                                                  right: constraints.maxWidth *
                                                      0.000,
                                                  top: constraints.maxHeight *
                                                      0.000,
                                                  bottom:
                                                      constraints.maxHeight *
                                                          0.029,
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.893,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.193,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Amount',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 36.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      )),
                                                ),
                                                Positioned(
                                                  left: constraints.maxWidth *
                                                      0.000,
                                                  right: constraints.maxWidth *
                                                      0.000,
                                                  top: constraints.maxHeight *
                                                      0.146,
                                                  bottom:
                                                      constraints.maxHeight *
                                                          0.000,
                                                  child: Container(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.893,
                                                      height: constraints
                                                              .maxHeight *
                                                          0.075,
                                                      child: Align(
                                                        alignment: Alignment(
                                                            0.00, 0.00),
                                                        child: AutoSizeText(
                                                          'Text',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Prompt',
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            letterSpacing: 0.0,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      )),
                                                ),
                                              ]),
                                            ))),
                                  ),
                                  Spacer(
                                    flex: 29,
                                  ),
                                  Flexible(
                                    flex: 42,
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                        ),
                                        child: Container(
                                            width: constraints.maxWidth * 0.651,
                                            height:
                                                constraints.maxHeight * 0.307,
                                            child: Align(
                                              alignment: Alignment(0.00, 0.00),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      flex: 99,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.25,
                                                          ),
                                                          child: Container(
                                                              width: constraints
                                                                      .maxWidth *
                                                                  0.400,
                                                              height: constraints
                                                                      .maxHeight *
                                                                  0.303,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment(
                                                                        0.00,
                                                                        0.00),
                                                                child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Flexible(
                                                                        flex:
                                                                            38,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: LayoutBuilder(builder: (context, constraints) {
                                                                              return Send(
                                                                                constraints,
                                                                              );
                                                                            })),
                                                                      ),
                                                                      Spacer(
                                                                        flex:
                                                                            26,
                                                                      ),
                                                                      Flexible(
                                                                        flex:
                                                                            38,
                                                                        child: Padding(
                                                                            padding: EdgeInsets.only(),
                                                                            child: LayoutBuilder(builder: (context, constraints) {
                                                                              return Receive(
                                                                                constraints,
                                                                              );
                                                                            })),
                                                                      )
                                                                    ]),
                                                              ))),
                                                    ),
                                                    Flexible(
                                                      flex: 99,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.50,
                                                          ),
                                                          child: LayoutBuilder(
                                                              builder: (context,
                                                                  constraints) {
                                                            return Buy(
                                                              constraints,
                                                            );
                                                          })),
                                                    ),
                                                  ]),
                                            ))),
                                  ),
                                ]),
                          ))),
                ),
              ]),
        ));
  }
}
