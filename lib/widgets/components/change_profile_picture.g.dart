// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/profile_picture_custom.dart';
import 'package:genius_wallet/widgets/components/custom/upload_picture_button_custom.dart';

class ChangeProfilePicture extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrHeader;
  final String? ovrMaxfilewarning;
  final Widget? ovrProfileIcon;
  final Widget? ovrMask;
  final String? ovrUpload;
  const ChangeProfilePicture(
    this.constraints, {
    Key? key,
    this.ovrHeader,
    this.ovrMaxfilewarning,
    this.ovrProfileIcon,
    this.ovrMask,
    this.ovrUpload,
  }) : super(key: key);
  @override
  _ChangeProfilePicture createState() => _ChangeProfilePicture();
}

class _ChangeProfilePicture extends State<ChangeProfilePicture> {
  _ChangeProfilePicture();

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
                right: 0,
                width: 117.0,
                top: 0,
                height: 19.0,
                child: Container(
                    height: 19.0,
                    width: 117.0,
                    child: AutoSizeText(
                      widget.ovrHeader ?? 'Change Picture ',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                right: 0,
                width: 117.0,
                top: 26.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 117.0,
                    child: AutoSizeText(
                      widget.ovrMaxfilewarning ?? 'Max file is 10Mb',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30000001192092896,
                        color: Color(0xff85858a),
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 0,
                width: 85.0,
                top: 2.0,
                height: 85.0,
                child: ProfilePictureCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 85.0,
                            top: 0,
                            height: 85.0,
                            child: Container(
                              height: 85.0,
                              width: 85.0,
                              decoration: BoxDecoration(
                                color: Color(0xff2a2b31),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 26.0,
                            width: 33.0,
                            top: 26.0,
                            height: 33.0,
                            child: widget.ovrProfileIcon ??
                                Image.asset(
                                  'assets/images/profileicon.png',
                                  package: 'genius_wallet',
                                  height: 33.0,
                                  width: 33.0,
                                  fit: BoxFit.none,
                                ),
                          ),
                        ]))),
              ),
              Positioned(
                right: 8.0,
                width: 109.0,
                bottom: 1.0,
                height: 35.0,
                child: UploadPictureButtonCustom(
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Stack(children: [
                          Positioned(
                            left: 0,
                            width: 109.0,
                            top: 0,
                            height: 35.0,
                            child: Container(
                              height: 35.0,
                              width: 109.0,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.0)),
                                border: Border.all(
                                  color: Color(0xff43444b),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 45.0,
                            width: 50.0,
                            top: 10.0,
                            height: 14.0,
                            child: Container(
                                height: 14.0,
                                width: 50.0,
                                child: AutoSizeText(
                                  widget.ovrUpload ?? 'Upload',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30000001192092896,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                          ),
                          Positioned(
                            left: 15.0,
                            width: 14.0,
                            top: 8.0,
                            height: 17.0,
                            child: widget.ovrMask ??
                                Image.asset(
                                  'assets/images/mask.png',
                                  package: 'genius_wallet',
                                  height: 17.0,
                                  width: 14.0,
                                  fit: BoxFit.none,
                                ),
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
