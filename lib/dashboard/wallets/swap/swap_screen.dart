import 'package:flutter/material.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  SwapScreenState createState() => SwapScreenState();
}

class SwapScreenState extends State<SwapScreen> {
  // Sample token data
  final List<String> tokens = ['ETH', 'DAI', 'USDT', 'BTC', 'UNI'];
  String? fromToken = 'ETH';
  String? toToken = 'DAI';
  double fromAmount = 0.0;
  double toAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Swap Tokens'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // From Token Input
                _buildTokenInput(
                  label: 'From',
                  token: fromToken,
                  onTokenChanged: (value) {
                    setState(() {
                      fromToken = value;
                    });
                  },
                  onAmountChanged: (value) {
                    setState(() {
                      fromAmount = double.tryParse(value) ?? 0.0;
                      // Simulate a 1:1 ratio for simplicity
                      toAmount = fromAmount;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Swap Icon
                IconButton(
                  icon: Icon(Icons.swap_vert, size: 32),
                  onPressed: () {
                    setState(() {
                      final tempToken = fromToken;
                      fromToken = toToken;
                      toToken = tempToken;
                    });
                  },
                ),
                SizedBox(height: 16),

                // To Token Input
                _buildTokenInput(
                  label: 'To',
                  token: toToken,
                  onTokenChanged: (value) {
                    setState(() {
                      toToken = value;
                    });
                  },
                  onAmountChanged: null, // To amount is derived
                  amount: toAmount.toStringAsFixed(2),
                ),
                SizedBox(height: 24),

                // Swap Button
                TextButton(
                  onPressed: () {
                    // Simulate swap action
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Swap Confirmed'),
                        content: Text(
                            'Swapped $fromAmount $fromToken for $toAmount $toToken.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                  child: const Text('Swap'),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTokenInput({
    required String label,
    String? token,
    required Function(String?) onTokenChanged,
    Function(String)? onAmountChanged,
    String amount = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            // Token Dropdown
            DropdownButton<String>(
              value: token,
              items: tokens.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onTokenChanged,
            ),
            SizedBox(width: 16),

            // Amount Input
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: onAmountChanged,
                controller: onAmountChanged != null
                    ? TextEditingController(text: amount)
                    : null,
                readOnly: onAmountChanged == null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Amount',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
