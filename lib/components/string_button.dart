import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

/// Button that holds a string as value and appends value to provided controller
class StringButton extends StatelessWidget {
  final String value;
  final void Function(String) onPressed;
  final Color? color;
  final double? minWidth;
  const StringButton({
    Key? key,
    required this.onPressed,
    required this.value,
    this.color,
    this.minWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return MaterialButton(
      color: color,
      minWidth: minWidth,
      onPressed: () {
        onPressed(value);
      },
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.radiusLg))),
      height: 60,
      child: Text(
        value,
        style: GeniusWalletTypography.headlineLg.copyWith(
          fontSize:
              GeniusWalletTypography.headlineLg.fontSize! * scale,
        ),
      ),
    );
  }
}
