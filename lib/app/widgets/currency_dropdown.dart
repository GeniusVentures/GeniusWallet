import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

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
        child: Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Text(currency.name,
              style: const TextStyle(
                fontSize: 24,
              )),
        ),
      );
    }).toList();

    return DropdownButton<Currency>(
      dropdownColor: GeniusWalletColors.containerGray,
      borderRadius: BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      items: items,
      onChanged: (currency) => onChanged(currency!),
      value: value,
      hint: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Select a Currency',
            style: TextStyle(
              fontSize: 20,
            ),
          )),
    );
  }
}
