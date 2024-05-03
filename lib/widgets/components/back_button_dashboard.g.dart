import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/back_button_dashboard_custom.dart';

class BackButtonDashboard extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrBack;
  final Widget? ovrWhiteArrowLeft;
  const BackButtonDashboard(
    this.constraints, {
    Key? key,
    this.ovrBack,
    this.ovrWhiteArrowLeft,
  }) : super(key: key);
  @override
  _BackButtonDashboard createState() => _BackButtonDashboard();
}

class _BackButtonDashboard extends State<BackButtonDashboard> {
  _BackButtonDashboard();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.arrow_back_outlined, size: 24);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
