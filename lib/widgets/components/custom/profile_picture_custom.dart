import 'package:flutter/material.dart';

class ProfilePictureCustom extends StatefulWidget {
  final Widget? child;
  ProfilePictureCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ProfilePictureCustomState createState() => _ProfilePictureCustomState();
}

class _ProfilePictureCustomState extends State<ProfilePictureCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}
