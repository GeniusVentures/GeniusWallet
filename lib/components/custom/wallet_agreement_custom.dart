import 'package:auto_size_text/auto_size_text.dart';
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
    return CheckboxListTile(
      value: widget.value ?? false,
      onChanged: widget.onChanged,
      title: widget.child ??
          AutoSizeText(
            widget.text ??
                'I’ve read and accept the Terms of Service and Privacy Policy',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
      contentPadding: EdgeInsets.zero, // No extra padding
    );
  }
}
