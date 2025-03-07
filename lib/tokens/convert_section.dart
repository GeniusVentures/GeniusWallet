import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

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
      text: widget.tokenPrice.toStringAsFixed(2),
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
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          "Convert",
          style: TextStyle(color: GeniusWalletColors.gray500),
        ),
      ),
      subtitle: Card(
        margin: EdgeInsets.zero,
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _tokenPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Token Price",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: GeniusWalletColors.deepBlue,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => _calculateTotalValue(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Token Amount",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: GeniusWalletColors.deepBlue,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => _calculateTotalValue(),
              ),
              const SizedBox(height: 16),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Total: \$${_totalValue.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
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
