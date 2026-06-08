import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:intl/intl.dart';

class ConvertSection extends StatefulWidget {
  final double tokenPrice;

  const ConvertSection({
    Key? key,
    required this.tokenPrice,
  }) : super(key: key);

  @override
  State<ConvertSection> createState() => _ConvertSectionState();
}

class _ConvertSectionState extends State<ConvertSection> {
  late TextEditingController _tokenAmountController;
  late TextEditingController _tokenPriceController;

  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _tokenPriceController = TextEditingController(
      text: widget.tokenPrice.toString(),
    );
    _tokenAmountController = TextEditingController(
      text: "1",
    );
    _calculateTotalValue();
  }

  void _calculateTotalValue() {
    final double tokenAmount =
        double.tryParse(_tokenAmountController.text) ?? 0;
    final double tokenPrice = double.tryParse(_tokenPriceController.text) ?? 0;

    setState(() {
      _totalValue = tokenAmount * tokenPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Padding(
        padding: EdgeInsets.only(bottom: GeniusWalletConsts.space4),
        child: Text(
          "Convert",
          style: TextStyle(color: GeniusWalletColors.gray500),
        ),
      ),
      subtitle: Card(
        margin: EdgeInsets.zero,
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
              color: GeniusWalletColors.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: GeniusWalletConsts.space12,
              horizontal: GeniusWalletConsts.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _tokenPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Token Price",
                  labelStyle:
                      TextStyle(color: GeniusWalletColors.textPrimary70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: GeniusWalletColors
                            .textPrimary12), // Bottom border color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: GeniusWalletColors
                            .lightGreenPrimary), // Highlighted border
                  ),
                ),
                style: const TextStyle(color: GeniusWalletColors.textPrimary),
                onChanged: (_) => _calculateTotalValue(),
              ),
              const SizedBox(height: GeniusWalletConsts.space10),
              TextField(
                controller: _tokenAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Token Amount",
                  labelStyle:
                      TextStyle(color: GeniusWalletColors.textPrimary70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: GeniusWalletColors
                            .textPrimary12), // Bottom border color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: GeniusWalletColors
                            .lightGreenPrimary), // Highlighted border
                  ),
                ),
                style: const TextStyle(color: GeniusWalletColors.textPrimary),
                onChanged: (_) => _calculateTotalValue(),
              ),
              const SizedBox(height: GeniusWalletConsts.space8),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Total: ${NumberFormat.currency(
                      locale: "en_US",
                      symbol: "\$",
                    ).format(_totalValue)}",
                    style: const TextStyle(
                      color: GeniusWalletColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
