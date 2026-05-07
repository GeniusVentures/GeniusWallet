import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';

class CurrencyDropdown extends StatelessWidget {
  final List<Currency> currencies;
  final void Function(Currency) onChanged;
  final Currency? value;
  const CurrencyDropdown({
    super.key,
    required this.currencies,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GWSelect<Currency>(
      value: value,
      hint: 'Select a Currency',
      items: currencies
          .map((c) => GWSelectItem<Currency>(value: c, label: c.name))
          .toList(),
      onChanged: (currency) {
        if (currency != null) onChanged(currency);
      },
    );
  }
}
