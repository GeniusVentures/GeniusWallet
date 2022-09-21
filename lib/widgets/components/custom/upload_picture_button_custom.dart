import 'package:flutter/material.dart';

class UploadPictureButtonCustom extends StatefulWidget {
  final Widget? child;
  UploadPictureButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _UploadPictureButtonCustomState createState() =>
      _UploadPictureButtonCustomState();
}

class _UploadPictureButtonCustomState extends State<UploadPictureButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
