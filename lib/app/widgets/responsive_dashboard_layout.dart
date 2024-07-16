import 'package:flutter/material.dart';

class ResponsiveDashboardLayout extends StatelessWidget {
  final List<Widget> children;
  const ResponsiveDashboardLayout({Key? key, this.children = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(children: children);
  }
}
