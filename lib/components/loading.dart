import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  final String? text;
  const Loading({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(spacing: 16, mainAxisSize: MainAxisSize.min, children: [
      LoadingAnimationWidget.flickr(
        leftDotColor: GeniusWalletColors.lightGreenPrimary,
        rightDotColor: GeniusWalletColors.blue500,
        size: 50,
      ),
      if (text != null)
        Text(
          text!,
        )
    ]);
  }
}
