import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/tokens/widgets/token_action_bar.dart';
import 'package:genius_wallet/tokens/widgets/token_detail_hero.dart';
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

/// sketch 152 `.sectitle`: a small uppercase section label (13px / w600 /
/// letterSpacing .4 / `gw.textSecondary`) that now lives INSIDE each
/// token-detail card (Info, Convert) rather than floating above it.
Widget _buildSectionTitle(BuildContext context, String text) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return Text(
    text.toUpperCase(),
    style: (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
        .copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: gw.textSecondary,
    ),
  );
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final isGnusBridgeEnabled =
        (isGnusWalletConnected ?? false) &&
        selectedCoin?.symbol?.toLowerCase() == 'gnus';

    return Scaffold(
      // sketch 152 `.appbar`: a compact 48px bar on the sunken surface with a
      // 1px hairline (gw.borderSubtle) bottom border and no Material elevation.
      // The default back button is kept (it works).
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: gw.surfaceSunken,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        // sketch 152 `.appbar`: back chevron + "Markets / <name>" breadcrumb,
        // LEFT-aligned and sharing the page's centered 1200 max-width + padding
        // so the back button lines up with the page content's left edge.
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width >
                        GeniusBreakpoints.medium
                    ? GeniusWalletConsts.space10
                    : GeniusWalletConsts.space8,
              ),
              child: Row(
                children: [
                  // sketch `.back`: compact 30x30 chevron button.
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius:
                        BorderRadius.circular(GeniusWalletConsts.radiusSm),
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
                  // sketch `.crumb`: "Markets / <name>".
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        style: (Theme.of(context).textTheme.bodyMedium ??
                                const TextStyle())
                            .copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: gw.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Markets  /  '),
                          TextSpan(
                            text: marketData?.name ?? 'Token',
                            style: TextStyle(
                              color: gw.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: gw.borderSubtle),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // sketch 152 (locked 2026-07-24): the two-panel layout switches at
          // GeniusBreakpoints.medium (768), matching the code's own
          // ResponsiveDrawer/useDesktopLayout threshold — NOT the .large (1024)
          // breakpoint this used to read.
          bool isDesktop = constraints.maxWidth > GeniusBreakpoints.medium;
          return SingleChildScrollView(
            // Desktop keeps the roomier space10 stage; mobile tightens to
            // space8 (sketch 152 `@container app (max-width:767px) .stage`).
            padding: EdgeInsets.all(
              isDesktop
                  ? GeniusWalletConsts.space10
                  : GeniusWalletConsts.space8,
            ),
            primary: true,
            // Cap content width so cards don't stretch edge-to-edge on very
            // wide screens (sketch `.wrap` max-width), centered.
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                ? Row(
                    spacing: GeniusWalletConsts.space8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (marketData != null)
                        Expanded(
                          flex: 2,
                          // sketch 152 A `.leftcard`: a fixed max height caps
                          // the main card so it can't tower over the right
                          // column; the chart flexes (Expanded) to fill the
                          // space under the hero + action bar. Price is in the
                          // hero, so the chart runs series-only.
                          child: SizedBox(
                            height: 480,
                            child: GWCard(
                            radius: GeniusWalletConsts.radiusMd,
                            padding: const EdgeInsets.all(
                              GeniusWalletConsts.space8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TokenDetailHero(
                                  marketData: marketData,
                                  selectedNetwork: selectedNetwork,
                                ),
                                const SizedBox(
                                  height: GeniusWalletConsts.space8,
                                ),
                                _buildActionBar(
                                  context,
                                  selectedCoin,
                                  selectedWallet,
                                  selectedNetwork,
                                  isGnusBridgeEnabled,
                                  walletDetailsCubit,
                                ),
                                const SizedBox(
                                  height: GeniusWalletConsts.space8,
                                ),
                                Expanded(
                                  child: _buildGraphSection(marketData!),
                                ),
                              ],
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
                        ),
                      ),
                    ],
                  )
                // sketch 152 D (unified stack, <768): identity -> actions ->
                // chart -> Convert -> Info. Identity + chart are wrapped in a
                // radiusMd GWCard; Convert and Info render as separate siblings
                // so Convert sits directly under the chart, above Info.
                : Column(
                    spacing: GeniusWalletConsts.space8,
                    children: [
                      GWCard(
                        radius: GeniusWalletConsts.radiusMd,
                        child: TokenDetailHero(
                          marketData: marketData,
                          selectedNetwork: selectedNetwork,
                        ),
                      ),
                      _buildActionBar(
                        context,
                        selectedCoin,
                        selectedWallet,
                        selectedNetwork,
                        isGnusBridgeEnabled,
                        walletDetailsCubit,
                      ),
                      if (marketData != null)
                        // Fixed height in the scrollable stack (sketch 152 D
                        // `min-height`): bare CryptoLiveChart has an internal
                        // Expanded that overflows without a bounded height.
                        GWCard(
                          radius: GeniusWalletConsts.radiusMd,
                          child: SizedBox(
                            height: 260,
                            child: _buildGraphSection(marketData!),
                          ),
                        ),
                      _buildConvertSection(marketData),
                      _buildInfoSection(marketData, selectedCoin, selectedNetwork),
                    ],
                  ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGraphSection(CoinGeckoMarketData marketData) {
    // sketch 152: the hero card owns the big price + % pill, so the chart
    // renders series-only (no built-in price header).
    return CryptoLiveChart(
      coinGeckoCoinId: marketData.id,
      tokenSymbol: marketData.symbol,
      showPriceHeader: false,
    );
  }

  /// sketch 152 `.actions`: the compact Receive / Send / Swap / More boxes,
  /// wired to the existing drawer behaviour. Receive opens the 034-A2 QR
  /// receive drawer; More opens the 07-07 Bridge Tokens drawer but ONLY when
  /// [isGnusBridgeEnabled] (else `onMore: null` renders More disabled —
  /// finding-37). Send/Swap stay disabled (D-01/D-02).
  Widget _buildActionBar(
    BuildContext context,
    Coin? selectedCoin,
    Wallet? selectedWallet,
    Network? selectedNetwork,
    bool isGnusBridgeEnabled,
    WalletDetailsCubit walletDetailsCubit,
  ) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return TokenActionBar(
      onReceive: () {
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
      onMore: isGnusBridgeEnabled
          ? () {
              // 07-07 gap-closure (gap 5, drawer-shell/quiet-band pattern from
              // 030-B1 + drawers-final "032 List"): the More drawer composes a
              // short description above a proper Bridge Tokens list row (icon +
              // label + trailing chevron) inside the 030-B1 shell delivered by
              // 07-06 -- the isGnusBridgeEnabled outer gate (finding 37) and the
              // inner onPressed (balance gate + /bridge push + getCoins refresh)
              // are unchanged.
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
                      // Disabled (zero-balance) row dims to a 38%-alpha tint of
                      // the same token (Material's standard disabled-content
                      // opacity) so the row stays visibly distinct from the
                      // enabled state in both dark and light -- not a new color,
                      // just a conditional pick of an existing GWColors step.
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
    );
  }

  /// Desktop (>=768, sketch 152 A) right column: Info above Convert, together.
  Widget _buildActionSection(
    CoinGeckoMarketData? marketData,
    Coin? selectedCoin,
    Network? selectedNetwork,
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
    // sketch 152 `.surf` Convert card: title INSIDE the card (sectitle style),
    // then the read-only price + editable amount + total (inner field gap
    // space6).
    return GWCard(
      radius: GeniusWalletConsts.radiusMd,
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Convert"),
          const SizedBox(height: GeniusWalletConsts.space4),
          Column(
            spacing: GeniusWalletConsts.space6,
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
        ],
      ),
    );
  }
}

class _MarketDataInfo extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;

  const _MarketDataInfo({
    this.marketData,
    this.network,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Single restrained accent for every info-tile leading glyph + copy/link
    // affordance (replaces the rainbow amber/lightBlue/orange/red set and the
    // cs.primary reads) — appearance-aware, honours the 10% accent discipline.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final textTheme = Theme.of(context).textTheme;
    // sketch 152 `.statrow`: grayish key + primary tabular value, both compact.
    final TextStyle keyStyle =
        (textTheme.bodySmall ?? const TextStyle()).copyWith(
      color: gw.textSecondary,
      fontSize: 14,
    );
    final TextStyle valStyle =
        (textTheme.bodySmall ?? const TextStyle()).copyWith(
      color: gw.textPrimary,
      fontSize: 14,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    // Distinct per-row glyph colours (the sketch's multi-colour stat icons),
    // each legible in dark AND light: appearance-aware status tones + brand
    // steps + slate. Replaces the single restrained accent per user request.
    Widget statRow(String svg, Color color, String label, Widget value) {
      // sketch 152 `.statrow`: padding 11px 12px, a 22px leading glyph box, a
      // 16px SketchIcon tinted to the per-row colour.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Center(child: SketchIcon(svg, size: 16, color: color)),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(child: Text(label, style: keyStyle)),
            value,
          ],
        ),
      );
    }

    final infoTiles = <Widget>[
      if (network != null)
        statRow(
          SketchIcons.network,
          GeniusWalletColors.brandPrimaryOnSurface,
          "Network",
          Text(network!, style: valStyle),
        ),
      if (address != null)
        statRow(
          SketchIcons.address,
          GeniusWalletColors.brandPrimaryStrong,
          "Address",
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                address!.length > 12
                    ? "${address!.substring(0, 6)}...${address!.substring(address!.length - 6)}"
                    : address!,
                style: valStyle,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(left: 6),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address!));
                  showAppSnackBar(context, 'Address copied to clipboard');
                },
                tooltip: "Copy address",
                icon: Icon(Icons.copy, size: 15, color: gw.textSecondary),
              ),
            ],
          ),
        ),
      statRow(
        SketchIcons.marketCap,
        gw.statusSuccess,
        "Market Cap",
        Text(_formatCompactCurrency(marketData?.marketCap), style: valStyle),
      ),
      statRow(
        SketchIcons.circulating,
        GeniusWalletColors.brandTertiary,
        "Circulating Supply",
        Text(_formatCompactDecimal(marketData?.circulatingSupply),
            style: valStyle),
      ),
      statRow(
        SketchIcons.totalSupply,
        gw.statusError,
        "Total Supply",
        Text(_formatCompactDecimal(marketData?.totalSupply), style: valStyle),
      ),
      statRow(
        SketchIcons.volume,
        GeniusWalletColors.statusNeutral,
        "Volume",
        Text(_formatCompactCurrency(marketData?.totalVolume), style: valStyle),
      ),
    ];

    // sketch 152 `.surf` Info card: the "Info" title moves INSIDE the card
    // (sectitle style) and the duplicate token-identity header row is gone —
    // the hero already shows identity. The first stat row carries no top
    // divider (sketch `.statrow:first-child { border-top:0 }`).
    return GWCard(
      radius: GeniusWalletConsts.radiusMd,
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Info"),
          const SizedBox(height: GeniusWalletConsts.space4),
          Column(
            children: [
              for (int i = 0; i < infoTiles.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                infoTiles[i],
              ],
            ],
          ),
        ],
      ),
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
