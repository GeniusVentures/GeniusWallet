import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class DesktopBodyContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  const DesktopBodyContainer({
    Key? key,
    this.child = const SizedBox(),
    this.padding = defaultPadding,
    this.width = 600,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.containerGray,
      padding: padding,
      width: width,
      height: height,
      child: child,
    );
  }

  static const defaultPadding =
      EdgeInsets.symmetric(horizontal: 100, vertical: 80);
}
