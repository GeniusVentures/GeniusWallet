// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/add_button_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddButton extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMask;
  const AddButton(
    this.constraints, {
    Key? key,
    this.ovrMask,
  }) : super(key: key);
  @override
  _AddButton createState() => _AddButton();
}

class _AddButton extends State<AddButton> {
  _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: AddButtonCustom(
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
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    border: Border.all(
                      color: Color(0xff3f4048),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.314,
                width: widget.constraints.maxWidth * 0.4,
                top: widget.constraints.maxHeight * 0.314,
                height: widget.constraints.maxHeight * 0.4,
                child: SvgPicture.asset(
                  'assets/images/object.svg',
                  package: 'genius_wallet',
                  height: widget.constraints.maxHeight * 0.4,
                  width: widget.constraints.maxWidth * 0.4,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.314,
                width: widget.constraints.maxWidth * 0.4,
                top: widget.constraints.maxHeight * 0.314,
                height: widget.constraints.maxHeight * 0.4,
                child: widget.ovrMask ??
                    SvgPicture.asset(
                      'assets/images/mask.svg',
                      package: 'genius_wallet',
                      height: widget.constraints.maxHeight * 0.4,
                      width: widget.constraints.maxWidth * 0.4,
                      fit: BoxFit.fill,
                    ),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
