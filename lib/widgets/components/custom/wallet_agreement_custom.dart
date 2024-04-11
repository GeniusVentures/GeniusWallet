import 'package:flutter/material.dart';

class WalletAgreementCustom extends StatefulWidget {
  final Widget? child;
  final bool? value;
  final void Function(bool?)? onChanged;
  final String? text;
  const WalletAgreementCustom({
    Key? key,
    this.value,
    this.onChanged,
    this.child,
    this.text,
  }) : super(key: key);

  @override
  _WalletAgreementCustomState createState() => _WalletAgreementCustomState();
}

class _WalletAgreementCustomState extends State<WalletAgreementCustom> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.value ?? false,
          onChanged: widget.onChanged,
        ),
        Flexible(
          flex: 10,
          child: Text(
            widget.text ??
                'I’ve read and accept the Terms of Service and Privacy Policy',
          ),
        ),
      ],
    );
  }
}
