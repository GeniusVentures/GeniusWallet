import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/action_button.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

/// 07-07 gap-closure: the More -> Bridge Tokens row's tap handler, extracted
/// to a top-level function so `.push('/bridge', extra: walletDetailsCubit)`
/// stays on one line at the drawer body's nesting depth (unchanged
/// behavior: pop the drawer, push /bridge with the cubit payload, refresh
/// coins -- same three calls the inline closure made before this plan).
Future<void> _pushBridgeScreen(
  BuildContext context,
  WalletDetailsCubit walletDetailsCubit,
) async {
  Navigator.of(context).pop();
  await GoRouter.of(context).push('/bridge', extra: walletDetailsCubit);
  walletDetailsCubit.getCoins();
}

class TokenInfoScreen extends StatelessWidget {
  final bool? isGnusWalletConnected;
  final CoinGeckoMarketData? marketData;
  final WalletDetailsCubit walletDetailsCubit;

  const TokenInfoScreen({
    super.key,
    required this.walletDetailsCubit,
    this.marketData,
    this.isGnusWalletConnected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: walletDetailsCubit,
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          return _buildScreenWithCubit(context, state);
        },
      ),
    );
  }

  /// **Screen when WalletDetailsCubit is available**
  Widget _buildScreenWithCubit(BuildContext context, WalletDetailsState state) {
    final selectedCoin = state.selectedCoin;
    final selectedWallet = state.selectedWallet;
    final selectedNetwork = state.selectedNetwork;
    final walletDetailsCubit = context.read<WalletDetailsCubit>();

    final isGnusBridgeEnabled =
        (isGnusWalletConnected ?? false) &&
        selectedCoin?.symbol?.toLowerCase() == 'gnus';

    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // sketch 152 (locked 2026-07-24): the two-panel layout switches at
          // GeniusBreakpoints.medium (768), matching the code's own
          // ResponsiveDrawer/useDesktopLayout threshold — NOT the .large (1024)
          // breakpoint this used to read.
          bool isDesktop = constraints.maxWidth > GeniusBreakpoints.medium;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(GeniusWalletConsts.space10),
            primary: true,
            child: isDesktop
                ? Row(
                    spacing: GeniusWalletConsts.space10,
                    children: [
                      if (marketData != null)
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: constraints.maxHeight - 40,
                            child: _buildGraphSection(
                              marketData!,
                              _buildStaticActions(
                                selectedCoin,
                                context,
                                selectedWallet,
                                selectedNetwork,
                                isGnusBridgeEnabled,
                                walletDetailsCubit,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 1,
                        child: _buildActionSection(
                          marketData,
                          selectedCoin,
                          selectedNetwork,
                          walletDetailsCubit,
                          context,
                          selectedWallet,
                          isGnusBridgeEnabled,
                        ),
                      ),
                    ],
                  )
                // sketch 152 D (unified stack, <768): actions -> chart (carries
                // the hero price/% pill) -> Convert -> Info. Convert and Info
                // render as separate siblings (not via _buildActionSection) so
                // Convert can sit directly under the chart, above Info.
                : Column(
                    spacing: GeniusWalletConsts.space10,
                    children: [
                      _buildStaticActions(
                        selectedCoin,
                        context,
                        selectedWallet,
                        selectedNetwork,
                        isGnusBridgeEnabled,
                        walletDetailsCubit,
                      ),
                      if (marketData != null)
                        _buildGraphSection(marketData!, null),
                      _buildConvertSection(marketData),
                      _buildInfoSection(marketData, selectedCoin, selectedNetwork),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildGraphSection(CoinGeckoMarketData marketData, Widget? child) {
    return CryptoLiveChart(
      coinGeckoCoinId: marketData.id,
      tokenSymbol: marketData.symbol,
      child: child,
    );
  }

  Widget _buildStaticActions(
    selectedCoin,
    context,
    selectedWallet,
    selectedNetwork,
    bool isGnusBridgeEnabled,
    walletDetailsCubit,
  ) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return SizedBox(
      width: 400,
      child: Row(
        spacing: GeniusWalletConsts.space4,
        children: [
          ActionButton(
            text: "Receive",
            icon: Icons.qr_code,
            onPressed: () {
              ResponsiveDrawer.show<void>(
                context: context,
                title: "Receive ${selectedCoin?.name}",
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                    child: SizedBox(
                      width: GeniusBreakpoints.small * 0.5,
                      child: CryptoAddressQR(
                        iconPath: selectedCoin?.iconPath,
                        address: selectedWallet?.address ?? "",
                        network: selectedNetwork?.name ?? "",
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const ActionButton(text: "Send", icon: Icons.send),
          const ActionButton(text: "Swap", icon: Icons.swap_horiz),
          ActionButton(
            text: "More",
            icon: Icons.more_horiz,
            onPressed: isGnusBridgeEnabled
                ? () {
                    // 07-07 gap-closure (gap 5, drawer-shell/quiet-band
                    // pattern from 030-B1 + drawers-final "032 List"): the
                    // More drawer used to render a single bare
                    // SlidingDrawerButton floating on empty space. It now
                    // composes a short description above a proper Bridge
                    // Tokens list row (icon + label + trailing chevron)
                    // inside the 030-B1 shell delivered by 07-06 -- the
                    // isGnusBridgeEnabled outer gate (finding 37) and the
                    // inner onPressed (balance gate + /bridge push +
                    // getCoins refresh) are unchanged.
                    ResponsiveDrawer.show<void>(
                      context: context,
                      title: "More Options",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              GeniusWalletConsts.space12,
                              GeniusWalletConsts.space8,
                              GeniusWalletConsts.space12,
                              GeniusWalletConsts.space4,
                            ),
                            child: Text(
                              "Move your GNUS across chains with the bridge.",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: gw.textSecondary),
                            ),
                          ),
                          SlidingDrawerButton(
                            onPressed: selectedCoin?.balance == 0
                                ? null
                                : () => _pushBridgeScreen(
                                    context,
                                    walletDetailsCubit,
                                  ),
                            label: "Bridge Tokens",
                            icon: Icons.alt_route,
                            // Disabled (zero-balance) row dims to a 38%-alpha
                            // tint of the same token (Material's standard
                            // disabled-content opacity) so the row stays
                            // visibly distinct from the enabled state in
                            // both dark and light -- not a new color, just a
                            // conditional pick of an existing GWColors step.
                            color: selectedCoin?.balance == 0
                                ? gw.textPrimary38
                                : gw.textPrimary,
                            showTrailingChevron: true,
                          ),
                        ],
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  /// Desktop (>=768, sketch 152 A) right column: Info above Convert, together.
  Widget _buildActionSection(
    CoinGeckoMarketData? marketData,
    Coin? selectedCoin,
    Network? selectedNetwork,
    WalletDetailsCubit? walletDetailsCubit,
    context,
    Wallet? selectedWallet,
    bool? isGnusBridgeEnabled,
  ) {
    return Column(
      spacing: GeniusWalletConsts.space8,
      children: [
        _buildInfoSection(marketData, selectedCoin, selectedNetwork),
        _buildConvertSection(marketData),
      ],
    );
  }

  /// The Info card alone — reused standalone on mobile (sketch 152 D) so it
  /// can be interleaved with the graph and Convert card.
  Widget _buildInfoSection(
    CoinGeckoMarketData? marketData,
    Coin? selectedCoin,
    Network? selectedNetwork,
  ) {
    return _MarketDataInfo(
      topSlot: CoinCardRow(
        iconPath: marketData?.imageUrl ?? "",
        balance: selectedCoin?.balance,
        name: marketData?.name ?? "unknown",
        symbol: marketData?.symbol ?? "unknown",
        marketData: marketData,
      ),
      marketData: marketData,
      address: selectedCoin?.address,
      network: selectedNetwork?.name,
    );
  }

  /// The Convert card alone — reused standalone on mobile (sketch 152 D) so it
  /// can render directly below the chart, above the Info card.
  Widget _buildConvertSection(CoinGeckoMarketData? marketData) {
    return _ConvertSection(tokenPrice: marketData?.currentPrice ?? 0.0);
  }
}

class _ConvertSection extends StatefulWidget {
  final double tokenPrice;

  const _ConvertSection({required this.tokenPrice});

  @override
  State<_ConvertSection> createState() => _ConvertSectionState();
}

class _ConvertSectionState extends State<_ConvertSection> {
  late TextEditingController _tokenAmountController;
  late TextEditingController _tokenPriceController;

  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _tokenPriceController = TextEditingController(
      text: widget.tokenPrice.toString(),
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: GeniusWalletConsts.space4,
      children: [
        Text("Convert", style: Theme.of(context).textTheme.titleMedium),
        GWCard(
          padding: const EdgeInsets.all(GeniusWalletConsts.space8),
          child: Column(
            spacing: GeniusWalletConsts.space8,
            children: [
              // Read-only display of marketData.currentPrice (sketch 152: only
              // Token Amount is editable) — mirrors bridge_screen.dart:664's
              // readOnly pattern. Sunken fill + a "READ-ONLY" chip visibly mark
              // it as a display row, while the value keeps full-contrast
              // textPrimary so it stays WCAG-legible in dark and light.
              TextField(
                controller: _tokenPriceController,
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: gw.textPrimary),
                decoration: InputDecoration(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: GeniusWalletConsts.space4,
                    children: [
                      const Text("Token Price"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GeniusWalletConsts.space2,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: gw.borderSubtle),
                          borderRadius: BorderRadius.circular(
                            GeniusWalletConsts.radiusXs,
                          ),
                        ),
                        child: Text(
                          "READ-ONLY",
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: gw.textPrimary54),
                        ),
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: gw.surfaceSunken,
                ),
              ),
              TextField(
                controller: _tokenAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: "Token Amount"),
                onChanged: (_) => _calculateTotalValue(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Total: ${NumberFormat.currency(locale: "en_US", symbol: "\$").format(_totalValue)}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketDataInfo extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;
  final Widget? topSlot;

  const _MarketDataInfo({
    this.marketData,
    this.network,
    this.address,
    this.topSlot,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // Single restrained accent for every info-tile leading glyph + copy/link
    // affordance (replaces the rainbow amber/lightBlue/orange/red set and the
    // cs.primary reads) — appearance-aware, honours the 10% accent discipline.
    final Color accent = GeniusWalletColors.brandPrimaryOnSurface;
    final infoTiles = <Widget>[
      if (network != null)
        ListTile(
          dense: true,
          leading: Icon(Icons.bubble_chart, color: accent),
          title: const Text("Network"),
          trailing: Text(
            network!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      if (address != null)
        ListTile(
          dense: true,
          leading: Icon(Icons.link, color: accent),
          title: const Text("Address"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address!));
                  showAppSnackBar(context, 'Address copied to clipboard');
                },
                tooltip: "Copy address",
                icon: Icon(Icons.copy, size: 18, color: accent),
              ),
              Text(
                address!.length > 12
                    ? "${address!.substring(0, 6)}...${address!.substring(address!.length - 6)}"
                    : address!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ListTile(
        dense: true,
        leading: Icon(Icons.pie_chart, color: accent),
        title: const Text("Market Cap"),
        trailing: Text(
          _formatCompactCurrency(marketData?.marketCap),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.sync, color: accent),
        title: const Text("Circulating Supply"),
        trailing: Text(
          _formatCompactDecimal(marketData?.circulatingSupply),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.storage, color: accent),
        title: const Text("Total Supply"),
        trailing: Text(
          _formatCompactDecimal(marketData?.totalSupply),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.bar_chart, color: accent),
        title: const Text("Volume"),
        trailing: Text(
          _formatCompactCurrency(marketData?.totalVolume),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: GeniusWalletConsts.space4,
      children: [
        Text("Info", style: Theme.of(context).textTheme.titleMedium),
        GWCard(
          padding: const EdgeInsets.all(GeniusWalletConsts.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(
                  bottom: GeniusWalletConsts.space4,
                  left: GeniusWalletConsts.space4,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  // §4.4 always-light chip: the token logo needs a fixed light
                  // backing regardless of appearance (NOT an appearance token).
                  backgroundColor: Colors.white,
                  backgroundImage: marketData?.imageUrl != null
                      ? NetworkImage(marketData!.imageUrl)
                      : null,
                  child: marketData?.imageUrl == null
                      ? Icon(
                          Icons.token,
                          color: cs.onSurfaceVariant,
                          size: 32,
                        )
                      : null,
                ),
                title: Text(marketData?.name ?? "Unknown Token", maxLines: 2),
                subtitle: Text(
                  (marketData?.symbol ?? "").toUpperCase(),
                  style: TextStyle(color: gw.textSecondary),
                ),
              ),
              Column(
                children: [
                  for (int i = 0; i < infoTiles.length; i++) ...[
                    Divider(height: 1),
                    infoTiles[i],
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCompactCurrency(double? number) {
    if (number == 0 || number == null) return "N/A";
    return NumberFormat.compactSimpleCurrency().format(number);
  }

  String _formatCompactDecimal(double? number) {
    if (number == 0 || number == null) return "N/A";
    return NumberFormat.compact().format(number);
  }
}
