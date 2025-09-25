import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  final String? text;
  const Loading({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          LoadingAnimationWidget.flickr(
            leftDotColor: GeniusWalletColors.lightGreenPrimary,
            rightDotColor: GeniusWalletColors.blue500,
            size: 50,
          ),
          AutoSizeText(
            text ?? "",
            style: const TextStyle(fontSize: 24),
          )
        ]);
  }
}
