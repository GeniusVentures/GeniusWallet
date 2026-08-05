import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class Recoveryword extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWord;
  final bool isEnabled;
  const Recoveryword(
    this.constraints, {
    super.key,
    this.ovrWord,
    this.isEnabled = true,
  });
  @override
  State<Recoveryword> createState() => _Recoveryword();
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
          border: widget.isEnabled
              ? Border.all(color: context.gw.lightGreenSecondary, width: 1.0)
              : Border.all(color: context.gw.borderGrey, width: 1.0),
        ),
        child: AutoSizeText(
          widget.ovrWord ?? '1 limb',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.0,
            color: widget.isEnabled ? Colors.white : context.gw.btnTextDisabled,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
