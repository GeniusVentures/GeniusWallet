import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/assets/read_asset.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_cta_state.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/formatters.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class BridgeScreen extends StatefulWidget {
  final Coin? fromToken;
  const BridgeScreen({super.key, this.fromToken});

  @override
  BridgeScreenState createState() => BridgeScreenState();
}

class BridgeScreenState extends State<BridgeScreen> {
  Coin? fromToken;
  Network? toNetwork;
  TextEditingController fromAmountController = TextEditingController();
  TextEditingController toAmountController = TextEditingController();
  List<Network>? availableBridgeNetworks;
  String? transactionCost;
  Timer? _debounce;
  bool _isApiCallInProgress = false; // Track ongoing API calls
  bool isError = false;
  // Task 3: added state for the CTA ladder only -- true while the debounce
  // body's getBrigeOutGasCost call is in flight / while bridgeOut's submit
  // closure is awaiting. Neither call nor its arguments are touched by
  // either flag.
  bool isEstimating = false;
  bool isSubmitting = false;

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

  // Task 2 · sketch 120 B1: the Phase 7 back-arrow AppBar convention, reused
  // verbatim from token_info_screen.dart:96-124 -- one back-arrow pattern for
  // the whole app, not a second invented one.
  PreferredSizeWidget _buildAppBar(BuildContext context, GWColors gw) {
    return AppBar(
      toolbarHeight: 48,
      backgroundColor: gw.surfaceSunken,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium
              ? GeniusWalletConsts.space10
              : GeniusWalletConsts.space8,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: SketchIcon(
                    SketchIcons.back,
                    size: 18,
                    color: gw.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Text(
              'Bridge',
              style: GeniusWalletTypography.titleMd.copyWith(
                color: gw.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Task 2 · a pill chip for the network route bar. Non-tappable when
  // [onTap] is null (the source chip -- the source is the connected
  // network, not a choice).
  Widget _networkChip({
    required GWColors gw,
    required String? name,
    required String? iconPath,
    VoidCallback? onTap,
  }) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space3,
      ),
      decoration: BoxDecoration(
        color: gw.surfaceMenu,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        border: Border.all(color: gw.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath ?? "",
            height: 20,
            width: 20,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(height: 20, width: 20);
            },
          ),
          const SizedBox(width: GeniusWalletConsts.space3),
          Flexible(
            child: Text(
              name ?? 'Select',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: GeniusWalletConsts.space2),
            Icon(
              Icons.keyboard_arrow_down,
              color: gw.textSecondary,
              size: 14,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      child: chip,
    );
  }

  // Task 2 (d): the destination network picker -- a re-skinned selector, not
  // a new data path. Same `availableBridgeNetworks` list, same
  // `setState(() => toNetwork = newNetwork)` the old dropdown's
  // `onItemChanged` performed, now presented as a ResponsiveDrawer list.
  Future<void> _showDestinationNetworkPicker(BuildContext context) {
    final networks = availableBridgeNetworks ?? const <Network>[];
    return ResponsiveDrawer.show<void>(
      context: context,
      // Owns a scrolling viewport: the inset lives on the list so it scrolls
      // with the content and rows still reach the panel edge (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      title: 'Select destination network',
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final network in networks)
            _NetworkPickerRow(
              network: network,
              isSelected: network.chainId == toNetwork?.chainId,
              onTap: () {
                setState(() => toNetwork = network);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  // Task 2 (c): source-chain chip · arrow · centred "Bridge" pill ·
  // destination-chain chip. Only the destination chip is tappable.
  Widget _buildNetworkRouteBar(
    BuildContext context,
    GWColors gw,
    Network? sourceNetwork,
  ) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _networkChip(
              gw: gw,
              name: sourceNetwork?.name,
              iconPath: sourceNetwork?.iconPath,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward, color: gw.textSecondary, size: 16),
              const SizedBox(height: GeniusWalletConsts.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: gw.surfaceMenu,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                ),
                child: Text(
                  'Bridge',
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _networkChip(
              gw: gw,
              name: toNetwork?.name,
              iconPath: toNetwork?.iconPath,
              onTap: () => _showDestinationNetworkPicker(context),
            ),
          ),
        ),
      ],
    );
  }

  // Task 3 (c): the ready rung's submit action -- byte-identical to
  // develop's inline closure (api.bridgeOut(...) with all seven arguments
  // including shouldMintTokens: true, the mounted guard, the ToastManager
  // call and the existing result AlertDialog -- 08-06 replaces that dialog,
  // not this plan), only now wrapped with the `isSubmitting` flag around the
  // real await so the CTA can show its "Bridging…" rung for exactly as long
  // as this genuinely takes.
  Future<void> _submitBridge(
    BuildContext context,
    WalletDetailsState state,
  ) async {
    final cs = Theme.of(context).colorScheme;
    setState(() => isSubmitting = true);
    try {
      final api = context.read<GeniusApi>();
      final bridgeTokensResponse = await api.bridgeOut(
        sourceChainId: state.selectedNetwork?.chainId ?? 0,
        contractAddress: fromToken?.address ?? "",
        rpcUrl: state.selectedNetwork?.rpcUrl ?? "",
        address: state.selectedWallet?.address ?? "",
        amountToBurn: fromAmountController.text,
        destinationChainId: toNetwork?.chainId ?? 0,
        shouldMintTokens: true,
      );

      if (!context.mounted) return;

      ToastManager.instance.showToast(
        context: context,
        title: bridgeTokensResponse.isSuccess ? 'Success' : 'Error',
        message: bridgeTokensResponse.isSuccess
            ? 'Bridge transaction completed.'
            : 'Bridge transaction failed.',
        type: bridgeTokensResponse.isSuccess
            ? ToastType.success
            : ToastType.error,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // Rounded corners
          title: Center(
            child: Text(
              bridgeTokensResponse.isSuccess
                  ? 'Bridge Success!'
                  : 'Bridge Failed!',
              style: TextStyle(
                color: bridgeTokensResponse.isSuccess
                    ? cs.primary
                    : cs.error,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: GeniusBreakpoints.useDesktopLayout(context)
                  ? 500
                  : MediaQuery.of(context).size.width * .85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: bridgeTokensResponse.isSuccess
                  ? [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Ensures wrapped text aligns properly
                              children: [
                                // From Token Section (Icon + Amount + Network Symbol)
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _cryptoIcon(fromToken?.iconPath),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        // Allows text to wrap properly
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${fromAmountController.text} ${fromToken?.symbol?.toUpperCase()}',
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              softWrap:
                                                  true, // Allows wrapping if needed
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              fromToken?.networkSymbol ??
                                                  "",
                                              maxLines:
                                                  2, // Allows wrapping on small screens
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: cs.onSurfaceVariant,
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
                                    Icons.arrow_forward,
                                    color: Colors.white70,
                                    size: 30,
                                  ),
                                ), // Arrow Icon
                                // To Token Section (Icon + Amount + Network Name)
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _cryptoIcon(toNetwork?.iconPath),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        // Allows text to wrap properly
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${toAmountController.text} ${toNetwork?.symbol?.toUpperCase()}',
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              softWrap:
                                                  true, // Allows wrapping
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              toNetwork?.name ?? "",
                                              maxLines:
                                                  2, // Allows wrapping on small screens
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: cs.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),

                      /// **Transaction Hash**
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Transaction Hash:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                bridgeTokensResponse.data ??
                                    "No Hash Available",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: bridgeTokensResponse.data ?? "",
                                  ),
                                );
                                showAppSnackBar(
                                  context,
                                  "Transaction Hash Copied!",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      const SizedBox(height: 12),
                      Text(
                        bridgeTokensResponse.errorMessage ??
                            "Failed to bridge tokens",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // for now return to the coins screen
                GoRouter.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  // Task 3 (a): the "You Pay" card -- swap_field.dart's vocabulary
  // (surfaceElevated, radiusLg, borderSubtle hairline, labelMd label, 38px
  // numericDisplay hero, surfaceMenu pill) built inline (SwapField is
  // SquidTokenInfo-typed; bridge's pay side is a fixed Coin, not tappable --
  // bridge is GNUS-only, D-12). The TextField's onChanged is develop's
  // 300ms-debounced body VERBATIM: same balance precheck returning before
  // any API call, same _isApiCallInProgress guard, same six
  // getBrigeOutGasCost arguments, same success/failure branches -- only
  // `isEstimating` is added around the call (added state, not changed
  // mechanics, per Task 3 (a)).
  Widget _buildPayCard(BuildContext context, GWColors gw, WalletDetailsState state) {
    final heroStyle = GeniusWalletTypography.numericDisplay.copyWith(
      fontSize: 38,
      height: 1.0,
    );
    return GWCard(
      background: gw.surfaceElevated,
      radius: GeniusWalletConsts.radiusLg,
      border: Border.all(color: gw.borderSubtle, width: 1),
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You Pay',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextField(
                  controller: fromAmountController,
                  style: heroStyle.copyWith(color: gw.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [DecimalTextInputFormatter()],
                  decoration: InputDecoration(
                    hintText: "0.0",
                    hintStyle: heroStyle.copyWith(color: gw.textPrimary38),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) async {
                    // Cancel any existing debounce timer
                    if (_debounce?.isActive ?? false) {
                      _debounce!.cancel();
                    }

                    // Start a new debounce timer
                    _debounce = Timer(const Duration(milliseconds: 300), () async {
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
                      setState(() => isEstimating = true);

                      // Make the API call
                      final api = context.read<GeniusApi>();
                      final gasCostResponse = await api.getBrigeOutGasCost(
                        sourceChainId: state.selectedNetwork?.chainId ?? 0,
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
                          isEstimating = false;
                        });
                      } else {
                        setState(() {
                          transactionCost = null;
                          toAmountController.text = '';
                          isError = true;
                          isEstimating = false;
                        });
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Container(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 8,
                  top: 2,
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                  color: gw.surfaceMenu,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                  border: Border.all(color: gw.borderSubtle, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      fromToken?.iconPath ?? "",
                      height: 32,
                      width: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(height: 32, width: 32);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fromToken?.symbol ?? 'GNUS',
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          Text(
            fromToken != null
                ? "${fromToken!.balance == 0 ? 0 : fromToken!.balance.toString()} ${fromToken!.symbol}"
                : "",
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Task 3 (a): "You Receive on {toNetwork.name}" -- read-only, driven only
  // by `toAmountController` (bridge is 1:1: the receive value is literally
  // the echo the debounce body writes). No rate row. The "on {network}"
  // qualifier stays in the label so this never reads as a token conversion.
  Widget _buildReceiveCard(GWColors gw) {
    final heroStyle = GeniusWalletTypography.numericDisplay.copyWith(
      fontSize: 38,
      height: 1.0,
    );
    return GWCard(
      background: gw.surfaceElevated,
      radius: GeniusWalletConsts.radiusLg,
      border: Border.all(color: gw.borderSubtle, width: 1),
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You Receive on ${toNetwork?.name ?? ""}',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextField(
                  controller: toAmountController,
                  readOnly: true,
                  style: heroStyle.copyWith(color: gw.textPrimary),
                  decoration: InputDecoration(
                    hintText: "0.0",
                    hintStyle: heroStyle.copyWith(color: gw.textPrimary38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Container(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 8,
                  top: 2,
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                  color: gw.surfaceMenu,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                  border: Border.all(color: gw.borderSubtle, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      toNetwork?.iconPath ?? "",
                      height: 32,
                      width: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(height: 32, width: 32);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      toNetwork?.name ?? 'Select',
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Task 3 (b): exactly TWO data-backed rows, gas only -- no rate, no
  // slippage row (D-11, bridge is 1:1). An unknown estimate renders an em
  // dash, never develop's literal `0` (which reads as a free bridge).
  Widget _gasRow(GWColors gw, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        Text(
          value,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGasCard(GWColors gw) {
    final receiveAmount = toAmountController.text.isEmpty
        ? '0'
        : toAmountController.text;
    return GWCard(
      background: gw.surfaceElevated,
      radius: GeniusWalletConsts.radiusMd,
      border: Border.all(color: gw.borderSubtle, width: 1),
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space6,
      ),
      child: Column(
        children: [
          _gasRow(
            gw,
            'You receive',
            '$receiveAmount ${fromToken?.symbol ?? "GNUS"}',
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          _gasRow(gw, 'Estimated gas cost', transactionCost ?? '—'),
        ],
      ),
    );
  }

  // Task 3 (c): the CTA ladder (bridge_cta_state.dart) is the single source
  // of truth -- this method only maps a resolved state to paint, matching
  // the swap CTA's mapping exactly (D-15): the `ready` rung renders through
  // the real `GWButton(variant: GWButtonVariant.gradient)`; every disabled
  // rung reuses the shipped textPrimary38-on-surfaceMenu treatment, except
  // insufficientBalance/gasError which swap in the statusError pair.
  Widget _buildCta(BuildContext context, GWColors gw, WalletDetailsState state) {
    final ctaState = resolveBridgeCtaState(
      amount: fromAmountController.text,
      balance: fromToken?.balance,
      isEstimating: isEstimating,
      hasEstimate: transactionCost != null,
      isError: isError,
      isSubmitting: isSubmitting,
    );
    final label = bridgeCtaLabel(ctaState, symbol: fromToken?.symbol);

    if (ctaState == BridgeCtaState.ready) {
      return GWButton(
        variant: GWButtonVariant.gradient,
        size: GWButtonSize.lg,
        expand: true,
        label: label,
        onPressed: () => _submitBridge(context, state),
      );
    }

    final isErrorTone = ctaState == BridgeCtaState.insufficientBalance ||
        ctaState == BridgeCtaState.gasError;
    final background = isErrorTone
        ? gw.statusError.withValues(alpha: 0.12)
        : gw.surfaceMenu;
    final foreground = isErrorTone ? gw.statusError : gw.textPrimary38;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ctaState == BridgeCtaState.submitting) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                ),
                const SizedBox(width: GeniusWalletConsts.space4),
              ],
              Text(
                label,
                style: GeniusWalletTypography.titleLg.copyWith(
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Scaffold(
      backgroundColor: gw.surfaceBase,
      appBar: _buildAppBar(context, gw),
      body: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space10,
                    vertical: GeniusWalletConsts.space10,
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNetworkRouteBar(context, gw, state.selectedNetwork),
                    const SizedBox(height: GeniusWalletConsts.space10),
                    _buildPayCard(context, gw, state),
                    const SizedBox(height: GeniusWalletConsts.space8),
                    _buildReceiveCard(gw),
                    const SizedBox(height: GeniusWalletConsts.space10),
                    _buildGasCard(gw),
                    const SizedBox(height: GeniusWalletConsts.space10),
                    _buildCta(context, gw, state),
                  ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cryptoIcon(String? iconPath) {
    return iconPath != null && iconPath.isNotEmpty
        ? Image.asset(
            iconPath,
            width: 28,
            height: 28,
            errorBuilder: (_, _, _) {
              return const Icon(
                Icons.currency_bitcoin,
                color: Colors.white70,
                size: 28,
              );
            },
          )
        : const Icon(Icons.currency_bitcoin, color: Colors.white70, size: 28);
  }

}

/// Task 2 (d): one tappable row per `availableBridgeNetworks` entry inside
/// the destination-network `ResponsiveDrawer`. Mirrors
/// `token_selector_drawer.dart`'s row treatment (`gw.surfaceMenu` fill,
/// `gw.textPrimary`/`gw.textSecondary` text) without importing that
/// `SquidTokenInfo`-typed widget -- this row is `Network`-typed.
class _NetworkPickerRow extends StatelessWidget {
  final Network network;
  final bool isSelected;
  final VoidCallback onTap;

  const _NetworkPickerRow({
    required this.network,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      margin: const EdgeInsets.only(bottom: GeniusWalletConsts.space4),
      decoration: BoxDecoration(
        color: gw.surfaceMenu,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: isSelected
            ? Border.all(color: gw.borderStrong, width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Image.asset(
          network.iconPath ?? "",
          height: 36,
          width: 36,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(height: 36, width: 36);
          },
        ),
        title: Text(
          network.name ?? '',
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textPrimary,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: gw.textPrimary, size: 18)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// `DecimalTextInputFormatter` moved to `lib/utils/formatters.dart` — Swap's
// amount field needed the same guard, and a shared control does not belong
// inside a screen. This call site is unchanged: the shared version defaults to
// unlimited decimals, and additionally maps a typed comma to a dot.
