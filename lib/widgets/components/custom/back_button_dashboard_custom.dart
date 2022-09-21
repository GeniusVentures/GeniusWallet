import 'package:genius_wallet/widgets/components/back_button_dashboard.g.dart';

import 'package:flutter/material.dart';

class BackButtonDashboardCustom extends StatefulWidget {
  final Widget? child;
  BackButtonDashboardCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BackButtonDashboardCustomState createState() =>
      _BackButtonDashboardCustomState();
}

class _BackButtonDashboardCustomState extends State<BackButtonDashboardCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        BackButtonDashboard(BoxConstraints(
          maxWidth: 79.0,
          maxHeight: 35.0,
        ));
  }
}
