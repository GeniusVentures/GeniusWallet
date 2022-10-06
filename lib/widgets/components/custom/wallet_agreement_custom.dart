import 'package:flutter/material.dart';

class WalletAgreementCustom extends StatefulWidget {
  final Widget? child;
  final bool? value;
  final void Function(bool?)? onChanged;
  WalletAgreementCustom({
    Key? key,
    this.value,
    this.onChanged,
    this.child,
  }) : super(key: key);

  @override
  _WalletAgreementCustomState createState() => _WalletAgreementCustomState();
}

class _WalletAgreementCustomState extends State<WalletAgreementCustom> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.value ?? false,
          onChanged: widget.onChanged,
        ),
        const Text(
          'I’ve read and accept the Terms of Service and Privacy Policy',
        ),
      ],
    );
  }
}
