import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_api/assets/read_asset.dart';

class BridgeScreen extends StatefulWidget {
  final Coin? fromToken;
  const BridgeScreen({Key? key, this.fromToken}) : super(key: key);

  @override
  BridgeScreenState createState() => BridgeScreenState();
}

class BridgeScreenState extends State<BridgeScreen> {
  Coin? fromToken;
  Network? toNetwork;
  TextEditingController fromAmountController = TextEditingController();
  TextEditingController toAmountController = TextEditingController();
  int? previousNetwork; // To track the previously selected network
  List<Network>? availableBridgeNetworks;

  @override
  void initState() {
    super.initState();
    fromToken = widget.fromToken;
    fromAmountController.text = '';
    toAmountController.text = '';
    _fetchBridgeNetworks();
  }

  @override
  void dispose() {
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  _fetchBridgeNetworks() async {
    final networks = await readNetworkBridgeAssets();
    setState(() {
      availableBridgeNetworks = networks;
      toNetwork = networks.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bridge"),
      ),
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
                  _buildDropdown<Coin>(
                      availableItems: fromToken != null
                          ? List.from([fromToken!])
                          : List.empty(),
                      onItemChanged: (Coin newCoin) {
                        setState(() {
                          fromToken = newCoin; // Update the selected coin
                        });
                      },
                      displayText: (Coin coin) => coin.symbol ?? '',
                      displayIcon: (Coin coin) => Image.asset(
                            coin.iconPath ?? "",
                            height: 36,
                            width: 36,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(height: 36, width: 36);
                            },
                          ),
                      label: 'You Pay',
                      selectedItem: fromToken,
                      onAmountChanged: (value) {
                        setState(() {
                          fromAmountController.text = value;
                          toAmountController.text = value;
                        });
                      },
                      controller: fromAmountController),
                  const SizedBox(height: 30),
                  // To Token Input
                  _buildDropdown<Network>(
                    availableItems: availableBridgeNetworks ?? List.empty(),
                    onItemChanged: (Network newNetwork) {
                      setState(() {
                        toNetwork = newNetwork; // Update the selected coin
                      });
                    },
                    displayText: (Network network) => network.name ?? '',
                    displayIcon: (Network network) => Image.asset(
                      network.iconPath ?? "",
                      height: 36,
                      width: 36,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(height: 36, width: 36);
                      },
                    ),
                    label: 'You Receive',
                    selectedItem: toNetwork,
                    onAmountChanged: null, // Disable manual input for "To"
                    controller: toAmountController,
                  ),
                  const SizedBox(height: 24),
                  // Swap Button
                  BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
                      builder: (context, state) {
                    return TextButton(
                      onPressed: fromAmountController.text.isEmpty
                          ? null
                          : () async {
                              final api = context.read<GeniusApi>();
                              final hashOrError = await api.bridgeOut(
                                  sourceChainId:
                                      state.selectedNetwork?.chainId ?? 0,
                                  contractAddress: fromToken?.address ?? "",
                                  rpcUrl: state.selectedNetwork?.rpcUrl ?? "",
                                  address: state.selectedWallet?.address ?? "",
                                  amountToBurn: fromAmountController.text,
                                  destinationChainId: toNetwork?.chainId ?? 0);

                              if (!context.mounted) return;

                              final isError = hashOrError.contains('Error');

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  contentPadding: const EdgeInsets.all(20),
                                  actionsAlignment: MainAxisAlignment.center,
                                  title: Center(
                                      child: isError
                                          ? const Text(
                                              'Bridge Failed!',
                                              style: TextStyle(
                                                  color:
                                                      GeniusWalletColors.red),
                                            )
                                          : const Text('Bridge Success!',
                                              style: TextStyle(
                                                  color: GeniusWalletColors
                                                      .lightGreenPrimary))),
                                  content: Container(
                                      child: isError
                                          ? Text('Error $hashOrError')
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  Text(
                                                      'Bridged ${fromAmountController.text} ${fromToken?.symbol} for ${toAmountController.text} ${toNetwork?.name} - ${toNetwork?.symbol}.',
                                                      style: const TextStyle(
                                                          fontSize: 16)),
                                                  const SizedBox(height: 12),
                                                  const Text('Hash:',
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  SelectableText(
                                                      ' $hashOrError',
                                                      style: const TextStyle(
                                                          fontSize: 16))
                                                ])),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor:
                            GeniusWalletColors.deepBlueCardColor,
                        fixedSize: const Size(600, 60),
                        backgroundColor: GeniusWalletColors.deepBlueCardColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 64,
                          vertical: 20,
                        ),
                      ),
                      child: const Text('Bridge'),
                    );
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    T? selectedItem, // Selected token or network
    required TextEditingController controller,
    required List<T> availableItems, // List of tokens or networks
    required String Function(T) displayText, // Function to extract display text
    required Widget Function(T) displayIcon, // Function to extract the icon
    required Function(T) onItemChanged, // Callback when an item is selected
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
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Dropdown for item selection (tokens or networks)
              DropdownButton<T>(
                underline: const SizedBox(), // Remove underline
                value: selectedItem, // Currently selected item
                hint: const Text(
                  'Select',
                  style: TextStyle(color: Colors.white),
                ),
                dropdownColor: GeniusWalletColors.deepBlueCardColor,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: availableItems.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        displayIcon(item), // Icon for the item
                        const SizedBox(width: 12),
                        Text(
                          displayText(item),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (T? newItem) {
                  if (newItem != null) {
                    onItemChanged(newItem); // Notify parent widget
                  }
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
                  readOnly: onAmountChanged == null, // Disable for read-only
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
          if (selectedItem != null && selectedItem is Coin)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "${selectedItem.balance == 0 ? 0 : selectedItem.balance?.toStringAsFixed(5) ?? 0} ${selectedItem.symbol}",
                style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: .5,
                    color: GeniusWalletColors.gray500),
              ),
            ),
        ],
      ),
    );
  }
}
