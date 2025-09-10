import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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

  final _formKey = GlobalKey<FormState>();
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _tokenPriceController = TextEditingController(
      text: widget.tokenPrice > 0 ? widget.tokenPrice.toString() : "",
    );
    _tokenAmountController = TextEditingController(text: "1");
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
    if (widget.tokenPrice == 0) {
      return Card(
        color: Colors.grey[800],
        elevation: 0,
        margin: EdgeInsets.zero,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.lock_clock, color: Colors.white54, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Conversion feature is coming soon.\nStay tuned!",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Normal Convert Section ---
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
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Token Price Field
                SizedBox(
                  height: 48,
                  child: TextFormField(
                    controller: _tokenPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Token Price",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: GeniusWalletColors.deepBlueTertiary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white12),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: GeniusWalletColors.lightGreenPrimary),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      final v = double.tryParse(value ?? "");
                      if (v == null || v <= 0) return "Enter valid price";
                      return null;
                    },
                    onChanged: (_) => _calculateTotalValue(),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: TextFormField(
                    controller: _tokenAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Token Amount",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: GeniusWalletColors.deepBlueTertiary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white12),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: GeniusWalletColors.lightGreenPrimary),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      final v = double.tryParse(value ?? "");
                      if (v == null || v <= 0) return "Enter amount";
                      return null;
                    },
                    onChanged: (_) => _calculateTotalValue(),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: GeniusWalletColors.lightGreenPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Total: ${NumberFormat.currency(
                          locale: "en_US",
                          symbol: "\$",
                        ).format(_totalValue)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
