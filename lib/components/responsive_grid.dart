import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  const ResponsiveGrid({Key? key, this.children = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int axisCount = screenWidth < 750 || GeniusBreakpoints.isNativeApp(context)
        ? 1
        : screenWidth < 1000
            ? 2
            : screenWidth < 1400
                ? 3
                : 4;
    return GridView.count(
        shrinkWrap: true,
        crossAxisCount: axisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: children);
  }
}
