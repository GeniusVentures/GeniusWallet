import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_tabbar.dart';

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const GeniusTabbar(),
    );
  }
}
