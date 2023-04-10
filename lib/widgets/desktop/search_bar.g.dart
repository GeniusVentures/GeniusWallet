// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SearchBar extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSearch;
  final Widget? ovrMask;
  const SearchBar(
    this.constraints, {
    Key? key,
    this.ovrSearch,
    this.ovrMask,
  }) : super(key: key);
  @override
  _SearchBar createState() => _SearchBar();
}

class _SearchBar extends State<SearchBar> {
  _SearchBar();

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
                width: widget.constraints.maxWidth * 1.0,
                top: 0,
                height: widget.constraints.maxHeight * 1.0,
                child: Container(
                  height: widget.constraints.maxHeight * 1.0,
                  width: widget.constraints.maxWidth * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.89,
                width: widget.constraints.maxWidth * 0.071,
                top: widget.constraints.maxHeight * 0.229,
                height: widget.constraints.maxHeight * 0.5,
                child: SvgPicture.asset(
                  'assets/images/object.svg',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.49971400669642857,
                  width: widget.constraints.maxWidth * 0.07138871173469388,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.049,
                width: widget.constraints.maxWidth * 0.208,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.429,
                child: Container(
                    height: widget.constraints.maxHeight * 0.42857142857142855,
                    width: widget.constraints.maxWidth * 0.20816326530612245,
                    child: AutoSizeText(
                      widget.ovrSearch ?? 'Search…',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Color(0xff42434b),
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.89,
                width: widget.constraints.maxWidth * 0.071,
                top: widget.constraints.maxHeight * 0.229,
                height: widget.constraints.maxHeight * 0.5,
                child: widget.ovrMask ??
                    Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.49971400669642857,
                      width: widget.constraints.maxWidth * 0.07138871173469388,
                      fit: BoxFit.fill,
                    ),
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
