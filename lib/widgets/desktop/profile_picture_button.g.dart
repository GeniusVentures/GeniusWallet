// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/desktop/custom/profile_picture_button_custom.dart';

class ProfilePictureButton extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrMask;
  final Widget? ovrMask2;
  const ProfilePictureButton(
    this.constraints, {
    Key? key,
    this.ovrMask,
    this.ovrMask2,
  }) : super(key: key);
  @override
  _ProfilePictureButton createState() => _ProfilePictureButton();
}

class _ProfilePictureButton extends State<ProfilePictureButton> {
  _ProfilePictureButton();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: ProfilePictureButtonCustom(
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
                left: widget.constraints.maxWidth * 0.286,
                width: widget.constraints.maxWidth * 0.457,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.457,
                child: widget.ovrMask ??
                    Image.asset(
                      'assets/images/mask.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.45714285714285713,
                      width: widget.constraints.maxWidth * 0.45714285714285713,
                      fit: BoxFit.fill,
                    ),
              ),
              Positioned(
                left: widget.constraints.maxWidth * 0.286,
                width: widget.constraints.maxWidth * 0.457,
                top: widget.constraints.maxHeight * 0.286,
                height: widget.constraints.maxHeight * 0.457,
                child: widget.ovrMask2 ??
                    Image.asset(
                      'assets/images/mask2.png',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.45714285714285713,
                      width: widget.constraints.maxWidth * 0.45714285714285713,
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
