import 'package:genius_wallet/widgets/desktop/profile_picture_button.g.dart';

import 'package:flutter/material.dart';

class ProfilePictureButtonCustom extends StatefulWidget {
  final Widget? child;
  const ProfilePictureButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ProfilePictureButtonCustomState createState() =>
      _ProfilePictureButtonCustomState();
}

class _ProfilePictureButtonCustomState
    extends State<ProfilePictureButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        const ProfilePictureButton(BoxConstraints(
          maxWidth: 35.0,
          maxHeight: 35.0,
        ));
  }
}
