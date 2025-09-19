import 'package:flutter/material.dart';
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selected;
  final void Function(T?)? onChanged;
  final String Function(T) display;
  final TextStyle? labelStyle;
  final bool compact;
  final String? errorText;
  final Widget? prefixIcon;
  final EdgeInsets? padding;

  const AppDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.display,
    this.labelStyle,
    this.compact = false,
    this.errorText,
    this.prefixIcon,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: selected,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle,
          border: const OutlineInputBorder(),
          isDense: compact,
          errorText: errorText,
          prefixIcon: prefixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 10 : 14,
          ),
        ),
        items: items.map((item) {
          final text = display(item);
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
