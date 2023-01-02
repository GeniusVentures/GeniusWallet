// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/price_graph_custom.dart';
import 'package:genius_wallet/widgets/components/custom/date_range_custom.dart';

class PriceChart extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrPriceChart;
  final String? ovr1700;
  final String? ovr1600;
  final String? ovr1400;
  final String? ovr1200;
  final String? ovrAll;
  final String? ovr1y;
  final String? ovr6m;
  final String? ovr3m;
  final String? ovr1m;
  const PriceChart(
    this.constraints, {
    Key? key,
    this.ovrPriceChart,
    this.ovr1700,
    this.ovr1600,
    this.ovr1400,
    this.ovr1200,
    this.ovrAll,
    this.ovr1y,
    this.ovr6m,
    this.ovr3m,
    this.ovr1m,
  }) : super(key: key);
  @override
  _PriceChart createState() => _PriceChart();
}

class _PriceChart extends State<PriceChart> {
  _PriceChart();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 150.0,
                top: 0,
                height: 35.0,
                child: Container(
                    height: 35.0,
                    width: 150.0,
                    child: AutoSizeText(
                      widget.ovrPriceChart ?? 'Price Chart',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 30.0,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.375,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 51.0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight * 0.862533692722372,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff1d2024),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 23.0,
                right: 20.0,
                top: 152.0,
                bottom: 23.0,
                child: PriceGraphCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            right: 0.808,
                            top: 0,
                            bottom: 0,
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 0,
                                    width: 271.0,
                                    top: 0,
                                    height: 110.0,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 271.0,
                                            top: 0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 271.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xff323235),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            width: 271.0,
                                            top: 27.0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 271.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xff323235),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            width: 271.0,
                                            top: 55.0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 271.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xff323235),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            width: 271.0,
                                            top: 82.0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 271.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xff323235),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            width: 271.0,
                                            top: 109.0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 271.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xff323235),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 0,
                                    width: 32.0,
                                    top: 174.0,
                                    height: 11.0,
                                    child: Container(
                                        height: 11.0,
                                        width: 32.0,
                                        child: AutoSizeText(
                                          widget.ovr1200 ?? '12:00',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.22499999403953552,
                                            color: Color(0xff6d6e76),
                                          ),
                                          textAlign: TextAlign.right,
                                        )),
                                  ),
                                  Positioned(
                                    left: 74.0,
                                    width: 32.0,
                                    top: 174.0,
                                    height: 11.0,
                                    child: Container(
                                        height: 11.0,
                                        width: 32.0,
                                        child: AutoSizeText(
                                          widget.ovr1400 ?? '14:00',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.22499999403953552,
                                            color: Color(0xff6d6e76),
                                          ),
                                          textAlign: TextAlign.right,
                                        )),
                                  ),
                                  Positioned(
                                    left: 160.0,
                                    width: 31.0,
                                    top: 174.0,
                                    height: 11.0,
                                    child: Container(
                                        height: 11.0,
                                        width: 31.0,
                                        child: AutoSizeText(
                                          widget.ovr1600 ?? '16:00',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.22499999403953552,
                                            color: Color(0xff6d6e76),
                                          ),
                                          textAlign: TextAlign.right,
                                        )),
                                  ),
                                  Positioned(
                                    left: 1.0,
                                    width: 2.0,
                                    top: 151.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 6.0,
                                    width: 2.0,
                                    top: 154.0,
                                    height: 3.0,
                                    child: Container(
                                      height: 3.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 11.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 17.0,
                                    width: 2.0,
                                    top: 149.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 22.0,
                                    width: 2.0,
                                    top: 149.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 27.0,
                                    width: 2.0,
                                    top: 155.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 32.0,
                                    width: 2.0,
                                    top: 155.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 37.0,
                                    width: 2.0,
                                    top: 154.0,
                                    height: 3.0,
                                    child: Container(
                                      height: 3.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 43.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 48.0,
                                    width: 2.0,
                                    top: 155.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 53.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 58.0,
                                    width: 2.0,
                                    top: 149.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 63.0,
                                    width: 2.0,
                                    top: 54.0,
                                    height: 103.0,
                                    child: Container(
                                      height: 103.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 69.0,
                                    width: 2.0,
                                    top: 147.0,
                                    height: 10.0,
                                    child: Container(
                                      height: 10.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 239.0,
                                    width: 32.0,
                                    top: 174.0,
                                    height: 11.0,
                                    child: Container(
                                        height: 11.0,
                                        width: 32.0,
                                        child: AutoSizeText(
                                          widget.ovr1700 ?? '17:00',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.22499999403953552,
                                            color: Color(0xff6d6e76),
                                          ),
                                          textAlign: TextAlign.right,
                                        )),
                                  ),
                                  Positioned(
                                    left: 74.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 79.0,
                                    width: 2.0,
                                    top: 152.0,
                                    height: 5.0,
                                    child: Container(
                                      height: 5.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 84.0,
                                    width: 2.0,
                                    top: 152.0,
                                    height: 5.0,
                                    child: Container(
                                      height: 5.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 91.0,
                                    width: 2.0,
                                    top: 152.0,
                                    height: 5.0,
                                    child: Container(
                                      height: 5.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 96.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 101.0,
                                    width: 2.0,
                                    top: 155.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 106.0,
                                    width: 2.0,
                                    top: 151.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 111.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 116.0,
                                    width: 2.0,
                                    top: 155.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 122.0,
                                    width: 2.0,
                                    top: 151.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 127.0,
                                    width: 2.0,
                                    top: 151.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 132.0,
                                    width: 2.0,
                                    top: 154.0,
                                    height: 3.0,
                                    child: Container(
                                      height: 3.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 138.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 143.0,
                                    width: 2.0,
                                    top: 151.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 148.0,
                                    width: 2.0,
                                    top: 152.0,
                                    height: 5.0,
                                    child: Container(
                                      height: 5.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 153.0,
                                    width: 2.0,
                                    top: 147.0,
                                    height: 10.0,
                                    child: Container(
                                      height: 10.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 158.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 163.0,
                                    width: 2.0,
                                    top: 154.0,
                                    height: 3.0,
                                    child: Container(
                                      height: 3.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 169.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 174.0,
                                    width: 2.0,
                                    top: 155.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 179.0,
                                    width: 2.0,
                                    top: 148.0,
                                    height: 9.0,
                                    child: Container(
                                      height: 9.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 185.0,
                                    width: 2.0,
                                    top: 151.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 190.0,
                                    width: 2.0,
                                    top: 149.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 195.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 200.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 205.0,
                                    width: 2.0,
                                    top: 154.0,
                                    height: 3.0,
                                    child: Container(
                                      height: 3.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 210.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 216.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 221.0,
                                    width: 2.0,
                                    top: 153.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 226.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 232.0,
                                    width: 2.0,
                                    top: 149.0,
                                    height: 8.0,
                                    child: Container(
                                      height: 8.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 237.0,
                                    width: 2.0,
                                    top: 152.0,
                                    height: 5.0,
                                    child: Container(
                                      height: 5.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 242.0,
                                    width: 2.0,
                                    top: 152.0,
                                    height: 5.0,
                                    child: Container(
                                      height: 5.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 247.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 252.0,
                                    width: 2.0,
                                    top: 154.0,
                                    height: 3.0,
                                    child: Container(
                                      height: 3.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 257.0,
                                    width: 2.0,
                                    top: 147.0,
                                    height: 10.0,
                                    child: Container(
                                      height: 10.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 263.0,
                                    width: 2.0,
                                    top: 150.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 2.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xff323235),
                                      ),
                                    ),
                                  ),
                                ])),
                          ),
                          Positioned(
                            left: 2.0,
                            right: 0,
                            top: 1.0,
                            bottom: 63.0,
                            child: Container(
                                decoration: BoxDecoration(),
                                child: Stack(children: [
                                  Positioned(
                                    left: 10.0,
                                    width: 3.0,
                                    top: 7.0,
                                    height: 76.0,
                                    child: Container(
                                      height: 76.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 33.0,
                                    width: 3.0,
                                    top: 79.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 24.0,
                                    width: 3.0,
                                    top: 79.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 28.0,
                                    width: 3.0,
                                    top: 78.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 15.0,
                                    width: 3.0,
                                    top: 65.0,
                                    height: 17.0,
                                    child: Container(
                                      height: 17.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 5.0,
                                    width: 3.0,
                                    top: 76.0,
                                    height: 14.0,
                                    child: Container(
                                      height: 14.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    width: 3.0,
                                    top: 84.0,
                                    height: 2.0,
                                    child: Container(
                                      height: 2.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 6.0,
                                    width: 1.0,
                                    top: 61.0,
                                    height: 15.0,
                                    child: Container(
                                      height: 15.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffd8d8d8),
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 1.100000023841858,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16.0,
                                    width: 1.0,
                                    top: 0,
                                    height: 65.0,
                                    child: Container(
                                      height: 65.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 19.0,
                                    width: 3.0,
                                    top: 71.0,
                                    height: 13.0,
                                    child: Container(
                                      height: 13.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 37.0,
                                    width: 3.0,
                                    top: 81.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 39.0,
                                    width: 1.0,
                                    top: 30.0,
                                    height: 51.0,
                                    child: Container(
                                      height: 51.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 42.0,
                                    width: 3.0,
                                    top: 82.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44.0,
                                    width: 1.0,
                                    top: 31.0,
                                    height: 51.0,
                                    child: Container(
                                      height: 51.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 34.0,
                                    width: 1.0,
                                    top: 76.0,
                                    height: 4.0,
                                    child: Container(
                                      height: 4.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                        border: Border.all(
                                          color: Color(0xffda0a0a),
                                          width: 1.100000023841858,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 47.0,
                                    width: 3.0,
                                    top: 75.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 48.0,
                                    width: 1.0,
                                    top: 55.0,
                                    height: 20.0,
                                    child: Container(
                                      height: 20.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffc11e0f),
                                        border: Border.all(
                                          color: Color(0xffda0a0a),
                                          width: 1.100000023841858,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 51.0,
                                    width: 2.808,
                                    top: 75.438,
                                    height: 9.466,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0.892,
                                            height: 8.574,
                                            child: Container(
                                              height: 8.5738525390625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffc11e0f),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 1.143,
                                            child: Container(
                                              height: 1.1431884765625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffc11e0f),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 55.0,
                                    width: 3.0,
                                    top: 66.0,
                                    height: 12.0,
                                    child: Container(
                                      height: 12.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 57.0,
                                    width: 1.0,
                                    top: 78.0,
                                    height: 7.0,
                                    child: Container(
                                      height: 7.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 60.0,
                                    width: 2.808,
                                    top: 91.304,
                                    height: 23.269,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 18.361,
                                            child: Container(
                                              height: 18.360595703125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 17.39,
                                            height: 5.879,
                                            child: Container(
                                              height: 5.87921142578125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 65.0,
                                    width: 3.0,
                                    top: 104.0,
                                    height: 9.0,
                                    child: Container(
                                      height: 9.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffda0a0a),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 79.0,
                                    width: 1.0,
                                    top: 121.0,
                                    height: 11.0,
                                    child: Container(
                                      height: 11.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffda0a0a),
                                        border: Border.all(
                                          color: Color(0xffda0a0a),
                                          width: 1.100000023841858,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 83.0,
                                    width: 3.0,
                                    top: 130.0,
                                    height: 1.0,
                                    child: Container(
                                      height: 1.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffda0a0a),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 84.0,
                                    width: 1.0,
                                    top: 120.0,
                                    height: 11.0,
                                    child: Container(
                                      height: 11.0,
                                      width: 1.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xffda0a0a),
                                        border: Border.all(
                                          color: Color(0xffda0a0a),
                                          width: 1.100000023841858,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 74.0,
                                    width: 2.808,
                                    top: 108.117,
                                    height: 19.748,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 12.499,
                                            child: Container(
                                              height: 12.49859619140625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 12.499,
                                            height: 7.249,
                                            child: Container(
                                              height: 7.24945068359375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 79.0,
                                    width: 2.808,
                                    top: 107.069,
                                    height: 13.811,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 1.0,
                                            height: 12.811,
                                            child: Container(
                                              height: 12.81109619140625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffd8d8d8),
                                                border: Border.all(
                                                  color: Color(0xff979797),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 83.0,
                                    width: 2.808,
                                    top: 85.959,
                                    height: 17.04,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 1.0,
                                            height: 16.04,
                                            child: Container(
                                              height: 16.03973388671875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 88.0,
                                    width: 2.808,
                                    top: 0.422,
                                    height: 105.124,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 91.743,
                                            height: 13.382,
                                            child: Container(
                                              height: 13.38177490234375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 93.912,
                                            child: Container(
                                              height: 93.91204833984375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 92.0,
                                    width: 2.808,
                                    top: 86.001,
                                    height: 15.656,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 9.559,
                                            child: Container(
                                              height: 9.5592041015625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 9.559,
                                            height: 6.097,
                                            child: Container(
                                              height: 6.096923828125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 97.0,
                                    width: 2.808,
                                    top: 85.001,
                                    height: 14.788,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 6.976,
                                            child: Container(
                                              height: 6.97589111328125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.256,
                                            width: 1.0,
                                            top: 6.786,
                                            height: 8.002,
                                            child: Container(
                                              height: 8.00225830078125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 102.0,
                                    width: 2.808,
                                    top: 0.107,
                                    height: 100.892,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 82.534,
                                            height: 18.358,
                                            child: Container(
                                              height: 18.3580322265625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 82.534,
                                            child: Container(
                                              height: 82.534423828125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 106.0,
                                    width: 2.808,
                                    top: 24.298,
                                    height: 61.294,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 24.028,
                                            child: Container(
                                              height: 24.0277099609375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 17.064,
                                            height: 44.229,
                                            child: Container(
                                              height: 44.2294921875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 111.0,
                                    width: 2.808,
                                    top: 40.132,
                                    height: 67.537,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 41.253,
                                            height: 24.11,
                                            child: Container(
                                              height: 24.11016845703125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 67.537,
                                            child: Container(
                                              height: 67.53668212890625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 116.0,
                                    width: 2.808,
                                    top: 38.202,
                                    height: 71.464,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 38.277,
                                            height: 24.321,
                                            child: Container(
                                              height: 24.32098388671875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 71.464,
                                            child: Container(
                                              height: 71.46405029296875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 120.0,
                                    width: 2.808,
                                    top: 86.011,
                                    height: 10.874,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 6.842,
                                            height: 4.031,
                                            child: Container(
                                              height: 4.03131103515625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 10.115,
                                            child: Container(
                                              height: 10.1146240234375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 125.0,
                                    width: 2.808,
                                    top: 88.083,
                                    height: 10.574,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 7.153,
                                            height: 2.334,
                                            child: Container(
                                              height: 2.33441162109375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 10.574,
                                            child: Container(
                                              height: 10.57440185546875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 129.0,
                                    width: 2.808,
                                    top: 68.348,
                                    height: 25.402,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 16.806,
                                            height: 2.724,
                                            child: Container(
                                              height: 2.7239990234375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.256,
                                            width: 1.0,
                                            top: 19.348,
                                            height: 6.055,
                                            child: Container(
                                              height: 6.05462646484375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.256,
                                            width: 1.0,
                                            top: 0,
                                            height: 17.063,
                                            child: Container(
                                              height: 17.06298828125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 134.0,
                                    width: 2.808,
                                    top: 89.019,
                                    height: 8.635,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 8.635,
                                            child: Container(
                                              height: 8.63543701171875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 2.234,
                                            height: 4.603,
                                            child: Container(
                                              height: 4.602783203125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 138.0,
                                    width: 2.808,
                                    top: 86.283,
                                    height: 12.716,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 2.858,
                                            height: 9.858,
                                            child: Container(
                                              height: 9.85791015625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 2.858,
                                            child: Container(
                                              height: 2.85797119140625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 143.0,
                                    width: 2.808,
                                    top: 88.415,
                                    height: 7.263,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 1.891,
                                            height: 2.197,
                                            child: Container(
                                              height: 2.19708251953125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 7.263,
                                            child: Container(
                                              height: 7.26251220703125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 147.0,
                                    width: 2.808,
                                    top: 14.348,
                                    height: 77.004,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 50.908,
                                            height: 25.096,
                                            child: Container(
                                              height: 25.09637451171875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.256,
                                            width: 1.0,
                                            top: 76.004,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.256,
                                            width: 1.0,
                                            top: 0,
                                            height: 51.164,
                                            child: Container(
                                              height: 51.16436767578125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 152.0,
                                    width: 7.76,
                                    top: 65.22,
                                    height: 18.724,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 18.724,
                                            child: Container(
                                              height: 18.7239990234375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 4.952,
                                            width: 2.808,
                                            top: 4.548,
                                            height: 14.176,
                                            child: Container(
                                              height: 14.17572021484375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 2.24,
                                            height: 4.616,
                                            child: Container(
                                              height: 4.6156005859375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 166.0,
                                    width: 3.0,
                                    top: 71.0,
                                    height: 12.0,
                                    child: Container(
                                      height: 12.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 161.0,
                                    width: 2.808,
                                    top: 73.097,
                                    height: 11.936,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 11.074,
                                            child: Container(
                                              height: 11.07354736328125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 10.936,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 171.0,
                                    width: 2.808,
                                    top: 62.434,
                                    height: 17.47,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 9.438,
                                            height: 8.033,
                                            child: Container(
                                              height: 8.0325927734375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 9.668,
                                            child: Container(
                                              height: 9.66796875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 175.0,
                                    width: 2.808,
                                    top: 64.442,
                                    height: 12.51,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 9.642,
                                            height: 2.022,
                                            child: Container(
                                              height: 2.022216796875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 9.886,
                                            child: Container(
                                              height: 9.8856201171875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 11.51,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 180.0,
                                    width: 3.0,
                                    top: 62.0,
                                    height: 9.0,
                                    child: Container(
                                      height: 9.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 184.0,
                                    width: 3.0,
                                    top: 66.0,
                                    height: 6.0,
                                    child: Container(
                                      height: 6.0,
                                      width: 3.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xff7ac231),
                                          width: 0.550000011920929,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 189.0,
                                    width: 2.808,
                                    top: 64.068,
                                    height: 12.611,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 4.415,
                                            child: Container(
                                              height: 4.4150390625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 4.414,
                                            height: 8.197,
                                            child: Container(
                                              height: 8.196533203125,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 194.0,
                                    width: 2.808,
                                    top: 62.422,
                                    height: 11.467,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 6.867,
                                            height: 4.6,
                                            child: Container(
                                              height: 4.59967041015625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 10.151,
                                            child: Container(
                                              height: 10.15142822265625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 198.0,
                                    width: 2.808,
                                    top: 63.192,
                                    height: 15.797,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0.136,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 15.797,
                                            child: Container(
                                              height: 15.796630859375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 203.0,
                                    width: 2.808,
                                    top: 66.177,
                                    height: 5.54,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 1.821,
                                            height: 3.375,
                                            child: Container(
                                              height: 3.375244140625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 5.54,
                                            child: Container(
                                              height: 5.5400390625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 207.0,
                                    width: 2.808,
                                    top: 68.005,
                                    height: 10.772,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 3.194,
                                            height: 7.577,
                                            child: Container(
                                              height: 7.57745361328125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 3.195,
                                            child: Container(
                                              height: 3.1951904296875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 216.0,
                                    width: 2.808,
                                    top: 75.156,
                                    height: 3.839,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 1.0,
                                            child: Container(
                                              height: 1.0,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0.999,
                                            height: 2.84,
                                            child: Container(
                                              height: 2.8402099609375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 226.0,
                                    width: 2.808,
                                    top: 68.472,
                                    height: 16.229,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 15.035,
                                            height: 1.194,
                                            child: Container(
                                              height: 1.19415283203125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 15.255,
                                            child: Container(
                                              height: 15.2547607421875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 212.0,
                                    width: 2.808,
                                    top: 59.005,
                                    height: 21.594,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 3.123,
                                            height: 18.471,
                                            child: Container(
                                              height: 18.4705810546875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 3.124,
                                            child: Container(
                                              height: 3.12420654296875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 221.0,
                                    width: 2.808,
                                    top: 60.074,
                                    height: 19.877,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 18.58,
                                            child: Container(
                                              height: 18.57952880859375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 18.579,
                                            height: 1.299,
                                            child: Container(
                                              height: 1.298583984375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 244.0,
                                    width: 2.808,
                                    top: 60.366,
                                    height: 14.478,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 13.303,
                                            child: Container(
                                              height: 13.30267333984375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 13.114,
                                            height: 1.363,
                                            child: Container(
                                              height: 1.36346435546875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 253.0,
                                    width: 2.808,
                                    top: 74.422,
                                    height: 5.389,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 1.363,
                                            height: 4.026,
                                            child: Container(
                                              height: 4.02587890625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 1.363,
                                            child: Container(
                                              height: 1.36346435546875,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 258.0,
                                    width: 2.808,
                                    top: 54.475,
                                    height: 25.343,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 7.438,
                                            child: Container(
                                              height: 7.43768310546875,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 7.438,
                                            height: 17.905,
                                            child: Container(
                                              height: 17.9052734375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 249.0,
                                    width: 2.808,
                                    top: 61.441,
                                    height: 15.161,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 1.14,
                                            child: Container(
                                              height: 1.1397705078125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 1.14,
                                            height: 14.021,
                                            child: Container(
                                              height: 14.0211181640625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xff7ac231),
                                                  width: 0.550000011920929,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 230.0,
                                    width: 2.808,
                                    top: 68.045,
                                    height: 15.622,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 13.489,
                                            height: 2.133,
                                            child: Container(
                                              height: 2.13330078125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0,
                                            height: 15.383,
                                            child: Container(
                                              height: 15.38287353515625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 234.0,
                                    width: 2.808,
                                    top: 71.214,
                                    height: 16.362,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 12.527,
                                            child: Container(
                                              height: 12.52691650390625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 0.485,
                                            height: 15.877,
                                            child: Container(
                                              height: 15.8773193359375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 239.0,
                                    width: 2.808,
                                    top: 71.008,
                                    height: 10.556,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 9.33,
                                            child: Container(
                                              height: 9.33001708984375,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 4.555,
                                            height: 6.002,
                                            child: Container(
                                              height: 6.001708984375,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 262.0,
                                    width: 2.808,
                                    top: 65.078,
                                    height: 13.877,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 7.009,
                                            child: Container(
                                              height: 7.0093994140625,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 1.264,
                                            width: 1.0,
                                            top: 4.555,
                                            height: 9.322,
                                            child: Container(
                                              height: 9.322265625,
                                              width: 1.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                                border: Border.all(
                                                  color: Color(0xffda0a0a),
                                                  width: 1.100000023841858,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                  Positioned(
                                    left: 267.0,
                                    width: 2.808,
                                    top: 71.408,
                                    height: 6.542,
                                    child: Container(
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Positioned(
                                            left: 0,
                                            width: 2.808,
                                            top: 0,
                                            height: 6.542,
                                            child: Container(
                                              height: 6.5421142578125,
                                              width: 2.8076171875,
                                              decoration: BoxDecoration(
                                                color: Color(0xffda0a0a),
                                              ),
                                            ),
                                          ),
                                        ])),
                                  ),
                                ])),
                          ),
                        ]))),
              ),
              Positioned(
                left: 22.0,
                width: 156.0,
                top: 82.0,
                height: 23.0,
                child: DateRangeCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 26.0,
                            width: 37.0,
                            top: 0,
                            height: 23.0,
                            child: Container(
                              height: 23.0,
                              width: 37.0,
                              decoration: BoxDecoration(
                                color: Color(0xff4c4d55),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            width: 18.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 18.0,
                                child: AutoSizeText(
                                  widget.ovr1m ?? '1m',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.30000001192092896,
                                    color: Color(0xff606166),
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Positioned(
                            left: 32.0,
                            width: 27.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 27.0,
                                child: AutoSizeText(
                                  widget.ovr3m ?? '3m',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.30000001192092896,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Positioned(
                            left: 72.0,
                            width: 26.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 26.0,
                                child: AutoSizeText(
                                  widget.ovr6m ?? '6m',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.30000001192092896,
                                    color: Color(0xff606166),
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Positioned(
                            left: 103.0,
                            width: 25.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 25.0,
                                child: AutoSizeText(
                                  widget.ovr1y ?? '1y',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.30000001192092896,
                                    color: Color(0xff606166),
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                          Positioned(
                            left: 134.0,
                            width: 22.0,
                            top: 4.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 22.0,
                                child: AutoSizeText(
                                  widget.ovrAll ?? 'All',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.30000001192092896,
                                    color: Color(0xff606166),
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ]))),
              ),
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
