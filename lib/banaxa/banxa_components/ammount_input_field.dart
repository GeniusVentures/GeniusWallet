import 'package:flutter/material.dart';
class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextStyle labelStyle;
  final bool compact;
  final Function(String) onChanged;

  const AmountInputField({
    required this.controller,
    required this.labelText,
    required this.labelStyle,
    required this.compact,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(fontSize: compact ? 14 : 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        border: const OutlineInputBorder(),
        isDense: compact,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 14,
        ),
      ),
    );
  }
}

class WalletAddressField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextStyle labelStyle;
  final bool compact;
  final Function(String) onChanged;

  const WalletAddressField({
    required this.controller,
    required this.labelText,
    required this.labelStyle,
    required this.compact,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: compact ? 14 : 16),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        border: const OutlineInputBorder(),
        isDense: compact,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 14,
        ),
      ),
    );
  }
}
