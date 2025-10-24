import 'package:flutter/material.dart';
import 'package:genius_wallet/components/custom_drop_down.dart';
class BuyDropdownSection<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selected;
  final String Function(T) display;
  final void Function(T?)? onChanged;
  final bool compact;
  final TextStyle labelStyle;
  const BuyDropdownSection({
    required this.label,
    required this.items,
    required this.selected,
    required this.display,
    required this.onChanged,
    required this.labelStyle,
    required this.compact,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppDropdown<T>(
      label: label,
      items: items,
      selected: selected,
      display: display,
      onChanged: onChanged,
      labelStyle: labelStyle,
      compact: compact,
    );
  }
}
