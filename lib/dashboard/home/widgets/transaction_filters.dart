import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';

class TransactionFilters extends StatefulWidget {
  final Function(String) onFilterSelected;
  const TransactionFilters({Key? key, required this.onFilterSelected})
      : super(key: key);

  @override
  TransactionFiltersState createState() => TransactionFiltersState();
}

class TransactionFiltersState extends State<TransactionFilters> {
  int? _selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Wrap(
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
            const Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Transactions',
                style: TextStyle(
                    fontSize: GeniusWalletFontSize.sectionHeader,
                    fontWeight: FontWeight.w500),
              )
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _buildButtonOption(1, 'All'),
              const SizedBox(width: 8),
              _buildButtonOption(2, 'Sent'),
              const SizedBox(width: 8),
              _buildButtonOption(3, 'Received'),
              const SizedBox(width: 8),
              _buildButtonOption(4, 'Mint'),
            ]),
          ])),
    ]);
  }

  Widget _buildButtonOption(int value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = value;
          widget.onFilterSelected(label);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _selectedOption == value
              ? GeniusWalletColors.btnFilterSelectedBlue
              : GeniusWalletColors.btnFilterBlue,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: _selectedOption == value
                ? GeniusWalletColors.btnFilterSelectedBlue
                : GeniusWalletColors.btnFilterBlue,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                _selectedOption == value ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
