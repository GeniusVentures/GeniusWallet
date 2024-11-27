import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/coins/view/coins_screen.dart';
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

  String? selectedInput; // Track which input triggered the drawer

  @override
  Widget build(BuildContext context) {
    final walletDetailsCubit = context.read<WalletDetailsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Swap   -   ${walletDetailsCubit.state.selectedNetwork?.name}"),
      ),
      endDrawer: _buildDrawer(context), // Add a drawer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard),
            ),
          ),
          padding: const EdgeInsetsDirectional.symmetric(
              vertical: 128, horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
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
                        toAmount = fromAmount; // Simulate a 1:1 ratio
                      });
                    },
                    onButtonPressed: () {
                      setState(() {
                        selectedInput = 'from'; // Track which button is pressed
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
                    onButtonPressed: () {
                      setState(() {
                        selectedInput = 'to'; // Track which button is pressed
                      });
                    },
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
                      backgroundColor: GeniusWalletColors.deepBlueCardColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 64, vertical: 20),
                    ),
                    child: const Text('Swap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInput({
    required String label,
    String? token,
    required Function(String?) onTokenChanged,
    Function(String)? onAmountChanged,
    required VoidCallback onButtonPressed,
    String amount = '',
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 36, left: 32, right: 32),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, letterSpacing: .5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Builder(
                builder: (context) {
                  return TextButton.icon(
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.transparent)),
                    onPressed: () {
                      onButtonPressed();
                      Scaffold.of(context).openEndDrawer();
                    },
                    label: Text(
                      token ?? '',
                      style: const TextStyle(fontSize: 20, letterSpacing: 1.3),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(
                      color: GeniusWalletColors.gray500,
                      Icons.arrow_forward_ios,
                      size: 14,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 20),
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
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double maxDrawerWidth = 500;
    final double drawerWidth = min(screenWidth * 0.8, maxDrawerWidth);

    return Drawer(
        width: drawerWidth,
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 80, // Set a custom height
              color: GeniusWalletColors.deepBlueCardColor,
              alignment: Alignment.center,
              child: const Text(
                'Select a Token',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            const CoinsScreen()
            // ...tokens.map((token) {
            //   return ListTile(
            //     title: Text(token),
            //     onTap: () {
            //       setState(() {
            //         // Update the appropriate token based on selectedInput
            //         if (selectedInput == 'from') {
            //           fromToken = token;
            //         } else if (selectedInput == 'to') {
            //           toToken = token;
            //         }
            //       });
            //       Navigator.pop(context); // Close the drawer
            //     },
            //   );
            // }).toList(),
          ],
        ));
  }
}
