import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';

class CurrencyDropdown extends StatelessWidget {
  final List<Currency> currencies;
  final void Function(Currency) onChanged;
  final Currency? value;
  const CurrencyDropdown({
    Key? key,
    required this.currencies,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = currencies.map((currency) {
      return DropdownMenuItem<Currency>(
        value: currency,
        child: Text(
          currency.name,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      );
    }).toList();

    return DropdownButton<Currency>(
      underline: const SizedBox(),
      icon: Image.asset(
        'assets/images/maskcurrencyselector.png',
        package: 'genius_wallet',
      ),
      items: items,
      onChanged: (currency) => onChanged(currency!),
      value: value,
      hint: const Text(
        'Select a Currency',
        style: TextStyle(
          fontSize: 30,
        ),
      ),
    );
  }
}
