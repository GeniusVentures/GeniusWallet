import 'package:flutter/material.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

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
    final walletDetailsCubit = context.read<WalletDetailsCubit>();
    return Scaffold(
        appBar: AppBar(
          title: Text(
              "Swap   -   ${walletDetailsCubit.state.selectedNetwork?.name}"),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(36.0),
            child: Container(
                decoration: const BoxDecoration(
                    color: GeniusWalletColors.deepBlueCardColor,
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusCard))),
                padding: const EdgeInsetsDirectional.symmetric(
                    vertical: 128, horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
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
                        // Swap Icon
                        IconButton(
                          icon: const Icon(Icons.swap_vert, size: 32),
                          onPressed: () {
                            setState(() {
                              final tempToken = fromToken;
                              fromToken = toToken;
                              toToken = tempToken;
                            });
                          },
                        ),
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
                        const SizedBox(height: 24),
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
                            fixedSize: const Size(600, 60),
                            backgroundColor: GeniusWalletColors.deepBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 64, vertical: 20),
                          ),
                          child: const Text('Swap'),
                        ),
                      ],
                    ),
                  ),
                ))));
  }

  Widget _buildTokenInput({
    required String label,
    String? token,
    required Function(String?) onTokenChanged,
    Function(String)? onAmountChanged,
    String amount = '',
  }) {
    return Container(
        padding:
            const EdgeInsets.only(top: 12, bottom: 36, left: 32, right: 32),
        decoration: const BoxDecoration(
            color: GeniusWalletColors.deepBlue,
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Token Dropdown
                DropdownButton<String>(
                  style: const TextStyle(fontSize: 24),
                  icon: const Icon(
                    Icons.arrow_forward_ios_sharp,
                    size: 12,
                  ),
                  value: token,
                  items: tokens.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onTokenChanged,
                ),
                const SizedBox(width: 16),
                // Amount Input
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    onChanged: onAmountChanged,
                    controller: onAmountChanged != null
                        ? TextEditingController(text: amount)
                        : null,
                    readOnly: onAmountChanged == null,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: GeniusWalletColors.gray500),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '0',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
