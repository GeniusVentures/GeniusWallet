import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/assets/read_asset.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';

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
  String? transactionCost;
  Timer? _debounce;
  bool _isApiCallInProgress = false; // Track ongoing API calls
  bool isError = false;

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
    _debounce?.cancel(); // Cancel debounce timer when widget is disposed
    super.dispose();
  }

  Future<void> _fetchBridgeNetworks() async {
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
        body: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
            builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(GeniusWalletConsts.space12),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(GeniusWalletConsts.borderRadiusCard),
                ),
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: GeniusWalletConsts.space16,
                horizontal: GeniusWalletConsts.space12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                semanticLabel: coin.symbol,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(height: 36, width: 36);
                                },
                              ),
                          label: 'You Pay',
                          selectedItem: fromToken,
                          onAmountChanged: (value) async {
                            // Cancel any existing debounce timer
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }

                            // Start a new debounce timer
                            _debounce = Timer(const Duration(milliseconds: 300),
                                () async {
                              // If an API call is already in progress, do nothing
                              if (_isApiCallInProgress) return;

                              // Validate input immediately
                              try {
                                if ((double.parse(value)) >
                                        (fromToken?.balance ?? 0) ||
                                    fromToken?.balance == null) {
                                  // Not enough balance or invalid balance
                                  setState(() {
                                    transactionCost = null;
                                    toAmountController.text = '';
                                    isError = true;
                                  });
                                  return;
                                }
                              } catch (e) {
                                // Input wasn't a proper double
                                setState(() {
                                  transactionCost = null;
                                  toAmountController.text = '';
                                  isError = true;
                                });
                                return;
                              }

                              // Set API call in progress
                              _isApiCallInProgress = true;

                              // Make the API call
                              final api = context.read<GeniusApi>();
                              final gasCostResponse =
                                  await api.getBrigeOutGasCost(
                                sourceChainId:
                                    state.selectedNetwork?.chainId ?? 0,
                                contractAddress: fromToken?.address ?? "",
                                rpcUrl: state.selectedNetwork?.rpcUrl ?? "",
                                address: state.selectedWallet?.address ?? "",
                                amountToBurn: value,
                                destinationChainId: toNetwork?.chainId ?? 0,
                              );

                              // Reset API call progress
                              _isApiCallInProgress = false;

                              // Handle API response
                              if (gasCostResponse.isSuccess) {
                                setState(() {
                                  toAmountController.text = value;
                                  transactionCost = gasCostResponse.data;
                                  isError = false;
                                });
                              } else {
                                setState(() {
                                  transactionCost = null;
                                  toAmountController.text = '';
                                  isError = true;
                                });
                              }
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
                          semanticLabel: network.name,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(height: 36, width: 36);
                          },
                        ),
                        label: 'You Receive',
                        selectedItem: toNetwork,
                        onAmountChanged: null, // Disable manual input for "To"
                        controller: toAmountController,
                      ),
                      const SizedBox(height: GeniusWalletConsts.space12),
                      // Swap Button

                      TextButton(
                        onPressed: fromAmountController.text.isEmpty || isError
                            ? null
                            : () async {
                                final api = context.read<GeniusApi>();
                                final bridgeTokensResponse =
                                    await api.bridgeOut(
                                        sourceChainId:
                                            state.selectedNetwork?.chainId ?? 0,
                                        contractAddress:
                                            fromToken?.address ?? "",
                                        rpcUrl:
                                            state.selectedNetwork?.rpcUrl ?? "",
                                        address:
                                            state.selectedWallet?.address ?? "",
                                        amountToBurn: fromAmountController.text,
                                        destinationChainId:
                                            toNetwork?.chainId ?? 0,
                                        shouldMintTokens: true);

                                if (!context.mounted) return;

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor:
                                        GeniusWalletColors.deepBlueCardColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: GeniusWalletConsts.space10),
                                    actionsAlignment: MainAxisAlignment.center,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12)), // Rounded corners
                                    title: Center(
                                      child: Text(
                                        bridgeTokensResponse.isSuccess
                                            ? 'Bridge Success!'
                                            : 'Bridge Failed!',
                                        style: TextStyle(
                                          color: bridgeTokensResponse.isSuccess
                                              ? GeniusWalletColors
                                                  .lightGreenPrimary
                                              : GeniusWalletColors.statusError,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    content: SizedBox(
                                        width:
                                            GeniusBreakpoints.useDesktopLayout(
                                                    context)
                                                ? 500
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .85,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: bridgeTokensResponse
                                                  .isSuccess
                                              ? [
                                                  const SizedBox(height: GeniusWalletConsts.space8),
                                                  Row(children: [
                                                    Expanded(
                                                        child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start, // Ensures wrapped text aligns properly
                                                      children: [
                                                        // From Token Section (Icon + Amount + Network Symbol)
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _cryptoIcon(
                                                                  fromToken
                                                                      ?.iconPath),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Expanded(
                                                                // Allows text to wrap properly
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${fromAmountController.text} ${fromToken?.symbol?.toUpperCase()}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          true, // Allows wrapping if needed
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      fromToken
                                                                              ?.networkSymbol ??
                                                                          "",
                                                                      maxLines:
                                                                          2, // Allows wrapping on small screens
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          true,
                                                                      style: GeniusWalletTypography
                                                                          .bodyMd
                                                                          .copyWith(
                                                                        color: GeniusWalletColors
                                                                            .gray500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        const Expanded(
                                                            child: Icon(
                                                                Icons
                                                                    .arrow_forward,
                                                                color: GeniusWalletColors
                                                                    .textPrimary70,
                                                                size:
                                                                    30)), // Arrow Icon

                                                        // To Token Section (Icon + Amount + Network Name)
                                                        Expanded(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _cryptoIcon(
                                                                  toNetwork
                                                                      ?.iconPath),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Expanded(
                                                                // Allows text to wrap properly
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${toAmountController.text} ${toNetwork?.symbol?.toUpperCase()}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          true, // Allows wrapping
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      toNetwork
                                                                              ?.name ??
                                                                          "",
                                                                      maxLines:
                                                                          2, // Allows wrapping on small screens
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          true,
                                                                      style: GeniusWalletTypography
                                                                          .bodyMd
                                                                          .copyWith(
                                                                        color: GeniusWalletColors
                                                                            .gray500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ))
                                                  ]),
                                                  const SizedBox(height: GeniusWalletConsts.space32),

                                                  /// **Transaction Hash**
                                                  const Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Transaction Hash:',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(height: GeniusWalletConsts.space4),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            GeniusWalletConsts.space6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: SelectableText(
                                                            bridgeTokensResponse
                                                                    .data ??
                                                                "No Hash Available",
                                                            style: GeniusWalletTypography
                                                                .titleMd,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          tooltip: 'Copy',
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color: GeniusWalletColors
                                                                  .textPrimary70),
                                                          onPressed: () {
                                                            Clipboard.setData(
                                                              ClipboardData(
                                                                  text: bridgeTokensResponse
                                                                          .data ??
                                                                      ""),
                                                            );
                                                            showAppSnackBar(
                                                                context,
                                                                "Transaction Hash Copied!");
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]
                                              : [
                                                  const SizedBox(height: GeniusWalletConsts.space6),
                                                  Text(
                                                    bridgeTokensResponse
                                                            .errorMessage ??
                                                        "Failed to bridge tokens",
                                                    style: GeniusWalletTypography
                                                        .bodyLg,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: GeniusWalletConsts.space8),
                                                ],
                                        )),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // for now return to the coins screen
                                          GoRouter.of(context).pop();
                                        },
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
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
                            horizontal: GeniusWalletConsts.space32,
                            vertical: GeniusWalletConsts.space10,
                          ),
                        ),
                        child: const Text('Bridge'),
                      ),
                      const SizedBox(height: GeniusWalletConsts.space8),
                      Row(children: [
                        const Text("Estimated Gas Cost:   ",
                            style:
                                TextStyle(color: GeniusWalletColors.gray500)),
                        Text(
                            "${transactionCost == null ? 0 : transactionCost.toString()}")
                      ])
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
  }

  Widget _cryptoIcon(String? iconPath) {
    return iconPath != null && iconPath.isNotEmpty
        ? Image.asset(iconPath, width: 28, height: 28,
            errorBuilder: (_, __, ___) {
            return const Icon(Icons.currency_bitcoin,
                color: GeniusWalletColors.textPrimary70, size: 28);
          })
        : const Icon(Icons.currency_bitcoin, color: GeniusWalletColors.textPrimary70, size: 28);
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
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.surfaceElevated,
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.radius2xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GeniusWalletTypography.labelMd.copyWith(
              color: GeniusWalletColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: GWSelect<T>(
                    value: selectedItem,
                    hint: 'Select',
                    items: availableItems
                        .map((item) => GWSelectItem<T>(
                              value: item,
                              label: displayText(item),
                              leading: displayIcon(item),
                            ))
                        .toList(),
                    onChanged: (newItem) {
                      if (newItem != null) onItemChanged(newItem);
                    },
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space8),
              Flexible(
                flex: 2,
                child: SizedBox(
                  height: GeniusWalletConsts.space24,
                  child: TextField(
                    controller: controller,
                    style: GeniusWalletTypography.bodyLg,
                    cursorColor: GeniusWalletColors.brandPrimary,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [DecimalTextInputFormatter()],
                    onChanged: onAmountChanged,
                    readOnly: onAmountChanged == null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: GeniusWalletConsts.space4,
                      ),
                      hintStyle: GeniusWalletTypography.bodyLg.copyWith(
                        color: GeniusWalletColors.textSecondary,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GeniusWalletColors.brandPrimary,
                        ),
                      ),
                      hintText: '0',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          if (selectedItem != null && selectedItem is Coin)
            Padding(
              padding: const EdgeInsets.only(left: GeniusWalletConsts.space6),
              child: Text(
                "${selectedItem.balance == 0 ? 0 : selectedItem.balance.toString()} ${selectedItem.symbol}",
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: GeniusWalletColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow empty input
    if (text.isEmpty) {
      return newValue;
    }

    // Regex to validate input with a single decimal point and limited decimals
    final regExp = RegExp(r'^\d*\.?\d*$');

    if (regExp.hasMatch(text)) {
      // Return valid input
      return newValue;
    } else {
      // Ignore invalid input and keep the old value
      return oldValue;
    }
  }
}
