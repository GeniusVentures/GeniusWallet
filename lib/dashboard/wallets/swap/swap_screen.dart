import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/coins/view/coins_screen.dart';
import 'package:genius_wallet/app/widgets/networks/network_dropdown.dart';
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
  Coin? fromToken;
  Coin? toToken;
  TextEditingController fromAmountController = TextEditingController();
  TextEditingController toAmountController = TextEditingController();
  int? previousNetwork; // To track the previously selected network
  String? selectedInput; // Track which input triggered the drawer

  @override
  void initState() {
    super.initState();
    fromAmountController.text = '';
    toAmountController.text = '';
  }

  @override
  void dispose() {
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailsCubit, WalletDetailsState>(
      listener: (context, state) {
        // Reset fields when the network changes
        if (state.selectedNetwork?.chainId != previousNetwork) {
          setState(() {
            previousNetwork = state.selectedNetwork?.chainId;
            fromAmountController.text = '';
            toAmountController.text = '';
            fromToken = null;
            toToken = null;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Swap"),
          actions: [
            BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
              builder: (context, state) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    NetworkDropdown(
                      wallet: state.selectedWallet!,
                      network: state.selectedNetwork,
                      networkList: state.networks,
                    ),
                    const SizedBox(width: 24),
                  ],
                );
              },
            )
          ],
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
              vertical: 128,
              horizontal: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  children: [
                    // From Token Input
                    _buildTokenInput(
                      label: 'You Pay',
                      token: fromToken,
                      onTokenChanged: (value) {
                        setState(() {
                          fromToken = value;
                        });
                      },
                      onAmountChanged: (value) {
                        setState(() {
                          fromAmountController.text = value;
                        });
                      },
                      controller: fromAmountController,
                      onButtonPressed: () {
                        setState(() {
                          selectedInput = 'from';
                        });
                      },
                    ),
                    // Swap Icon
                    IconButton(
                      icon: const Icon(Icons.swap_vert, size: 40),
                      onPressed: () {
                        setState(() {
                          // Swap tokens
                          final tempToken = fromToken;
                          fromToken = toToken;
                          toToken = tempToken;

                          // Swap amounts
                          final tempAmount = fromAmountController.text;
                          fromAmountController.text = toAmountController.text;
                          toAmountController.text = tempAmount;
                        });
                      },
                    ),
                    // To Token Input
                    _buildTokenInput(
                      label: 'You Receive',
                      token: toToken,
                      onTokenChanged: (value) {
                        setState(() {
                          toToken = value;
                        });
                      },
                      onAmountChanged: null, // Disable manual input for "To"
                      controller: toAmountController,
                      onButtonPressed: () {
                        setState(() {
                          selectedInput = 'to';
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
                                'Swapped ${fromAmountController.text} ${fromToken?.symbol} for ${toAmountController.text} ${toToken?.symbol}.'),
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
                          horizontal: 64,
                          vertical: 20,
                        ),
                      ),
                      child: const Text('Swap'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInput({
    required String label,
    Coin? token,
    required Function(Coin?) onTokenChanged,
    required VoidCallback onButtonPressed,
    required TextEditingController controller,
    Function(String)? onAmountChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: .5,
                    color: GeniusWalletColors.gray500),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Builder(
                builder: (context) {
                  return TextButton.icon(
                    style: const ButtonStyle(
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 16, horizontal: 8)),
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                    onPressed: () {
                      onButtonPressed();
                      Scaffold.of(context).openEndDrawer();
                    },
                    label: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          token?.iconPath ?? "",
                          height: 36,
                          width: 36,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(height: 36, width: 36);
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          token?.symbol ?? "Select",
                        ),
                      ],
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: GeniusWalletColors.gray500,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller, // Persistent controller
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                  readOnly: onAmountChanged ==
                      null, // don't allow editing of the to input
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
          const SizedBox(height: 8),
          if (token != null)
            Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                    "${token.balance == 0 ? 0 : token.balance?.toStringAsFixed(5) ?? 0} ${token.symbol}",
                    style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: .5,
                        color: GeniusWalletColors.gray500)))
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
            CoinsScreen(
                // make sure we don't allow swapping to an already select token
                filterCoins: [fromToken, toToken],
                onCoinSelected: (coin) {
                  Navigator.pop(context);
                  setState(() {
                    if (selectedInput == 'from') {
                      fromToken = coin;
                    } else if (selectedInput == 'to') {
                      toToken = coin;
                    }
                  });
                })
          ],
        ));
  }
}
