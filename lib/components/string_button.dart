import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

/// Button that holds a string as value and appends value to provided controller
class StringButton extends StatelessWidget {
  final String value;
  final void Function(String) onPressed;
  final Color? color;
  final double? minWidth;
  const StringButton({
    super.key,
    required this.onPressed,
    required this.value,
    this.color,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: color,
      minWidth: minWidth,
      onPressed: () {
        onPressed(value);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
      ),
      height: 60,
      child: Text(
        value,
        style: TextStyle(fontSize: MediaQuery.of(context).textScaler.scale(30)),
      ),
    );
  }
}
