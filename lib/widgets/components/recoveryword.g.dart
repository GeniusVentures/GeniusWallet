import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class Recoveryword extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWord;
  const Recoveryword(
    this.constraints, {
    Key? key,
    this.ovrWord,
  }) : super(key: key);
  @override
  _Recoveryword createState() => _Recoveryword();
}

class _Recoveryword extends State<Recoveryword> {
  _Recoveryword();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(),
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(48)),
              border: Border.all(
                color: GeniusWalletColors.lightGreenSecondary,
                width: 1.0,
              ),
            ),
            child: AutoSizeText(
              widget.ovrWord ?? '1 limb',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
