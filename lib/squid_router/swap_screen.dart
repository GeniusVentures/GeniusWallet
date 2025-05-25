import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_route_response.dart';
import 'package:genius_wallet/squid_router/models/squid_swap_params.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/squid_token_service.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/squid_router/swap_fail_drawer.dart';
import 'package:genius_wallet/squid_router/swap_field.dart';
import 'package:genius_wallet/squid_router/swap_settings_drawer.dart';
import 'package:genius_wallet/squid_router/swap_success_drawer.dart';
import 'package:genius_wallet/squid_router/token_flip_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  List<SquidTokenInfo> tokens = [];
  SquidTokenInfo? fromToken;
  SquidTokenInfo? toToken;
  bool isLoading = true;
  String fromAmount = '';
  String toAmount = '';
  Timer? _debounce;
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();
  SquidRouteResponse? fetchedRoute;
  double slippage = 0.5; // Default slippage

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadTokens() async {
    try {
      final walletState = context.read<WalletDetailsCubit>().state;
      final walletAddress = walletState.selectedWallet?.address;
      final chainId = walletState.selectedNetwork?.chainId;

      final result = await SquidTokenService.fetchTokens();
      final balances = await SquidTokenService.fetchBalances(
          chainIds: ["$chainId"], walletAddress: walletAddress!);

      // Merge balances into tokens
      for (final token in result) {
        final matchingBalance = balances.cast<SquidBalance?>().firstWhere(
              (b) =>
                  b!.symbol.toLowerCase() == token.symbol.toLowerCase() &&
                  b.chainId.toLowerCase() ==
                      token.chainId.toString().toLowerCase() &&
                  b.address.toLowerCase() == token.address.toLowerCase(),
              orElse: () => null,
            );
        token.balance = matchingBalance;
      }

      setState(() {
        tokens = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Token or balance fetch failed: $e');
    }
  }

  void _flipTokens() {
    setState(() {
      // Flip tokens
      final tempToken = fromToken;
      fromToken = toToken;
      toToken = tempToken;

      // Flip amounts
      final tempAmount = fromAmount;
      fromAmount = toAmount;
      toAmount = tempAmount;

      // Update controllers
      fromAmountController.text = fromAmount;
      toAmountController.text = toAmount;
    });

    _debouncedFetchRoute(); // Re-fetch route after flipping
  }

  bool get canSwap =>
      fromToken != null &&
      toToken != null &&
      fromAmount.isNotEmpty &&
      double.tryParse(fromAmount) != null;

  SquidSwapParams? get swapParams {
    if (!canSwap) return null;

    final walletState = context.read<WalletDetailsCubit>().state;
    final fromAddress = walletState.selectedWallet?.address;
    final toAddress = walletState.selectedWallet?.address;

    if (fromAddress == null || toAddress == null) return null;

    return SquidSwapParams(
        fromChain: fromToken!.chainId,
        fromToken: fromToken!.address,
        fromAmount: fromAmount,
        toChain: toToken!.chainId,
        toToken: toToken!.address,
        fromAddress: fromAddress,
        toAddress: toAddress,
        slippage: slippage);
  }

  Future<void> _fetchRoute() async {
    if (!canSwap) return;

    final params = swapParams;
    if (params == null) return;

    try {
      final route = await SquidTokenService.getRoute(params);
      final formatted =
          formatTokenAmount(BigInt.parse(route.toAmount), toToken!.decimals);
      setState(() {
        toAmount = formatted;
        toAmountController.text = formatted;
        fetchedRoute = route;
      });
    } catch (e) {
      debugPrint("Route fetch failed: $e");
    }
  }

  void _debouncedFetchRoute() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<WalletDetailsCubit, WalletDetailsState>(
        // If wallet or network changes
        listenWhen: (previous, current) =>
            previous.selectedWallet?.address !=
                current.selectedWallet?.address ||
            previous.selectedNetwork?.chainId !=
                current.selectedNetwork?.chainId,
        listener: (context, state) {
          // reset UI
          setState(() {
            fromToken = null;
            toToken = null;
            fromAmount = '';
            toAmount = '';
            fromAmountController.clear();
            toAmountController.clear();
            fetchedRoute = null;
            isLoading = true;
          });

          // Refetch tokens and balances
          _loadTokens();
        },
        child: _buildSwapContent(context),
      ),
    );
  }

  Widget _buildSwapContent(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Invisible widget to balance the settings icon on the right
                        const SizedBox(width: 24), // Same width as the Icon
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Swap",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            SwapSettingsDrawer.show(
                              context,
                              initialSlippage: slippage,
                              onSlippageChanged: (value) {
                                setState(() {
                                  slippage = value;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwapField(
                    label: "You Pay",
                    controller: fromAmountController,
                    onChanged: (val) {
                      setState(() => fromAmount = val);
                      _debouncedFetchRoute();
                    },
                    selectedToken: fromToken,
                    isSelectingFrom: true,
                    // filter out the selected toToken, and the token that is already selected
                    tokens: tokens
                        .where((t) =>
                            (toToken == null ||
                                t.address.toLowerCase() !=
                                    toToken!.address.toLowerCase() ||
                                t.chainId != toToken!.chainId) &&
                            (fromToken == null ||
                                t.address.toLowerCase() !=
                                    fromToken!.address.toLowerCase() ||
                                t.chainId != fromToken!.chainId))
                        .toList(),
                    onTokenSelected: (token) {
                      setState(() => fromToken = token);
                      _debouncedFetchRoute();
                    },
                  ),
                  SwapField(
                    label: "You Receive",
                    controller: toAmountController,
                    onChanged: (val) => setState(() => toAmount = val),
                    selectedToken: toToken,
                    isSelectingFrom: false,
                    // filter out the selected fromToken, and the token that is already selected
                    tokens: tokens
                        .where((t) =>
                            (fromToken == null ||
                                t.address.toLowerCase() !=
                                    fromToken!.address.toLowerCase() ||
                                t.chainId != fromToken!.chainId) &&
                            (toToken == null ||
                                t.address.toLowerCase() !=
                                    toToken!.address.toLowerCase() ||
                                t.chainId != toToken!.chainId))
                        .toList(),
                    onTokenSelected: (token) {
                      setState(() => toToken = token);
                      _debouncedFetchRoute();
                    },
                  ),
                  // Flip Button
                  Transform.translate(
                    offset: const Offset(0, -170),
                    child: TokenFlipButton(
                      onFlip: _flipTokens,
                    ),
                  ),
                  if (fetchedRoute != null)
                    if (fetchedRoute != null)
                      RouteDetailsCard(
                        route: fetchedRoute!,
                        fromAmount: fromAmountController.text,
                        toAmount: toAmountController.text,
                        fromToken: fromToken,
                        toToken: toToken,
                        slippage: slippage.toString(),
                      ),
                  if (canSwap)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: swapParams == null
                                  ? null
                                  : () async {
                                      final params = swapParams!;

                                      debugPrint(
                                          'Swapping with params: ${params.toJson()}');
                                      // TODO: invoke Squid API

                                      final walletState = context
                                          .read<WalletDetailsCubit>()
                                          .state;
                                      final walletAddress =
                                          walletState.selectedWallet?.address;
                                      final walletNetwork =
                                          walletState.selectedNetwork?.symbol;
                                      final transactionsCubit =
                                          context.read<TransactionsCubit>();

                                      // TODO: record transaction...
                                      // IF SUCCESSS ...
                                      final transaction = Transaction(
                                          hash: "",
                                          fromAddress: walletAddress!,
                                          recipients: [
                                            TransferRecipients(
                                              toAddr: walletAddress,
                                              amount: toAmount,
                                            )
                                          ],
                                          timeStamp: DateTime.now(),
                                          transactionDirection:
                                              TransactionDirection.received,
                                          fees: fromAmount,
                                          coinSymbol: walletNetwork!,
                                          transactionStatus:
                                              TransactionStatus.completed,
                                          type: TransactionType.swap,
                                          toAmount: toAmount,
                                          toIconUrl: toToken?.logoURI,
                                          fromSymbol: fromToken?.symbol,
                                          toSymbol: toToken?.symbol,
                                          fromAmount: fromAmount,
                                          fromIconUrl: fromToken?.logoURI);

                                      SwapSuccessDrawer.show(context,
                                          fromAmount: fromAmount,
                                          toAmount: toAmount,
                                          fromIconUrl: fromToken?.logoURI ?? '',
                                          toIconUrl: toToken?.logoURI ?? '',
                                          fromSymbol: fromToken?.symbol ?? '',
                                          toSymbol: toToken?.symbol ?? '',
                                          chain: walletNetwork, onClose: () {
                                        Navigator.of(context).pop();
                                      });
                                      // if fail
                                      // SwapFailDrawer.show(
                                      //   context,
                                      //   fromAmount: fromAmount,
                                      //   toAmount: toAmount,
                                      //   fromIconUrl: fromToken?.logoURI ?? '',
                                      //   toIconUrl: toToken?.logoURI ?? '',
                                      //   fromSymbol: fromToken?.symbol ?? '',
                                      //   toSymbol: toToken?.symbol ?? '',
                                      //   chain: walletNetwork,
                                      //   onClose: () {
                                      //Navigator.of(context).pop();
                                      // );

                                      //  final transaction = Transaction(
                                      //     hash: "",
                                      //     fromAddress: walletAddress!,
                                      //     recipients: [
                                      //       TransferRecipients(
                                      //         toAddr: walletAddress,
                                      //         amount: toAmount,
                                      //       )
                                      //     ],
                                      //     timeStamp: DateTime.now(),
                                      //     transactionDirection:
                                      //         TransactionDirection.received,
                                      //     fees: fromAmount,
                                      //     coinSymbol: walletNetwork!,
                                      //     transactionStatus:
                                      //         TransactionStatus.failed,
                                      //     type: TransactionType.swap,
                                      //     toAmount: toAmount,
                                      //     toIconUrl: toToken?.logoURI,
                                      //     fromSymbol: fromToken?.symbol,
                                      //     toSymbol: toToken?.symbol,
                                      //     fromAmount: fromAmount,
                                      //     fromIconUrl: fromToken?.logoURI);

                                      transactionsCubit
                                          .addTransaction(transaction);

                                      // save to hive
                                      await TransactionStorageService()
                                          .addTransaction(
                                              walletAddress, transaction);
                                    },
                              child: const Text("Swap",
                                  style: TextStyle(
                                      color:
                                          GeniusWalletColors.deepBlueTertiary,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              )),
        ),
      ),
    );
  }
}
