import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
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
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:go_router/go_router.dart';

/// Bridge: push /bridge with the cubit payload, then refresh the coins so a
/// completed bridge shows up on the balance you came back to.
///
/// **074-C2 dropped a `Navigator.of(context).pop()` that used to open this
/// function.** It was there to close the "More Options" drawer this row lived
/// in; Bridge is now a direct icon on the section line, so with no drawer above
/// it that pop would have popped the PAGE and pushed /bridge onto whatever was
/// underneath.
Future<void> _pushBridgeScreen(
  BuildContext context,
  WalletDetailsCubit walletDetailsCubit,
) async {
  await GoRouter.of(context).push('/bridge', extra: walletDetailsCubit);
  walletDetailsCubit.getCoins();
}

/// Height of everything the chart shares the viewport with on desktop - back
/// chip, header, stat rail, the action line and the gaps between them. Measured
/// from the built layout rather than derived, and it only has to be close: it
/// feeds a `max()` whose floor is [_kMinChartHeight].
///
/// 074-C2 took ~38px out of it: the full-width four-tile action bar (74px plus
/// its 16px gap) became a 44px section line sharing its row with the kicker.
const double _kChromeAboveChart = 342;

/// The chart never goes below this, so a short window scrolls instead of
/// squashing the one thing the page is for.
const double _kMinChartHeight = 300;

/// How tall the chart is, given the viewport.
///
/// Pure and public ONLY so the 480 literal cannot come back unnoticed: this
/// used to be `SizedBox(height: 480)`, and with a ~530px Info+Convert column
/// beside it the page ended near 620px on a 1335px window - half the screen
/// empty, which was the whole of "wygląda słabo". A constant would pass any
/// screenshot; it fails the test that asks for two different viewports.
///
/// Mobile keeps a fixed 260 because below 768 the page is one scrolling column
/// (sketch 152-D) and there is no viewport to fill - the chart is a station on
/// the way down, not the page.
double coinChartHeight({
  required double viewportHeight,
  required bool isDesktop,
}) => isDesktop
    ? math.max(_kMinChartHeight, viewportHeight - _kChromeAboveChart)
    : 260;

/// "0 means unknown", not "zero". `CoinGeckoMarketData.fromJson` defaults every
/// numeric to `0.0` and the rank to `0`, so without this a missing field prints
/// a confident `$0.00` / `#0`. Lifted out of `CoinInfoCard` on 2026-07-28 so the
/// stat rail uses the SAME rule rather than inventing a third one.
String formatCompactCurrency(double? number) {
  if (number == 0 || number == null) return "N/A";
  return NumberFormat.compactSimpleCurrency().format(number);
}

String formatCompactDecimal(double? number) {
  if (number == 0 || number == null) return "N/A";
  return NumberFormat.compact().format(number);
}

/// A signed percentage, or "N/A" when the field never arrived.
String formatPercent(double? pct) {
  if (pct == null || pct == 0) return "N/A";
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(2)}%';
}

/// A price, or "N/A". Not compact - a price is read digit by digit.
String formatPrice(double? value) {
  if (value == null || value == 0) return "N/A";
  return NumberFormat.currency(locale: "en_US", symbol: "\$").format(value);
}

/// sketch 152 `.sectitle`: a small uppercase section label that lives INSIDE
/// each token-detail card (Info, Convert) rather than floating above it.
Widget _buildSectionTitle(BuildContext context, String text) =>
    // Was a hand-rolled 13/w600/0.4 built off labelLarge; joins GWKicker's
    // default step (sketch 065). This call site is the one that made the case
    // for the component — a section title INSIDE a card is exactly the job the
    // transaction receipt (154-A) needs done too.
    GWKicker(text);

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
      // 071-B: the 48px Material AppBar and its hand-built "Markets / Bitcoin"
      // breadcrumb are gone. This screen now sits INSIDE the ShellRoute, so the
      // app's navbar is the top of the window like everywhere else, and the
      // title is a GWPageHeader in the body exactly as Markets/News/Transactions
      // render theirs.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // sketch 152 (locked 2026-07-24): the two-panel layout switches at
          // GeniusBreakpoints.medium (768), matching the code's own
          // ResponsiveDrawer/useDesktopLayout threshold.
          final bool isDesktop =
              constraints.maxWidth > GeniusBreakpoints.medium;
          final bool isWide = constraints.maxWidth >= GeniusBreakpoints.large;

          // **The 480 literal, replaced.** `_buildMainCard` used to be
          // `SizedBox(height: 480)`; with a ~530px Info+Convert column beside it
          // the page's content ended near 620px on a 1335px window, so roughly
          // half the screen was empty. That is the whole of Jakub's "wygląda
          // słabo".
          //
          // `constraints.maxHeight` is the viewport because the Scaffold body is
          // bounded - the SingleChildScrollView below is what makes height
          // unbounded, so the number has to be read HERE, above it. The floor
          // keeps the chart usable on a short window and lets the page scroll
          // rather than squashing it.
          final double chartHeight = coinChartHeight(
            viewportHeight: constraints.maxHeight,
            isDesktop: isDesktop,
          );

          return SingleChildScrollView(
            // The Markets / News / Transactions frame: NO horizontal page
            // padding - every block carries its own 12px gutter - so the coin
            // title lands on the same x as "Markets" on the page you came from.
            // It used to be `EdgeInsets.all(space10)` around a 1200-wide centred
            // column, which put the title ~170px further in on a 1500px window.
            padding: const EdgeInsets.fromLTRB(
              0,
              GeniusWalletConsts.space6,
              0,
              GeniusWalletConsts.space20,
            ),
            primary: true,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: GeniusBreakpoints.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BackToMarkets(),
                    _header(
                      context,
                      selectedCoin,
                      selectedWallet,
                      selectedNetwork,
                      isGnusBridgeEnabled,
                      walletDetailsCubit,
                    ),
                    if (marketData != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _StatRail(data: marketData!),
                      ),
                      const SizedBox(height: GeniusWalletConsts.space8),
                    ],
                    // 075-E2 moved the wallet actions up onto the title's line,
                    // so this is a plain label for the chart card again. It
                    // stops reserving the 44px an action row needed - which is
                    // the height E2 hands back.
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: GWKicker('Price'),
                    ),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: isWide && marketData != null
                          // >=1024: chart | Info+Convert side by side, and the
                          // chart is EXACTLY as tall as the column beside it.
                          //
                          // Jakub 2026-07-28: *"ten graph jest znacznie
                          // większy [...] ma być dostosowane do wysokości
                          // łącznych sekcji INFO i CONVERT. Musi być IN LINE."*
                          // The viewport-derived height this replaced fixed the
                          // 480 literal's empty page but overshot in the other
                          // direction - a chart taller than everything next to
                          // it left the row ragged at the bottom.
                          //
                          // `IntrinsicHeight` asks each child how tall it wants
                          // to be and gives the row the largest answer. The
                          // side column answers honestly; the chart is wrapped
                          // so it answers ZERO (see `_FillHeight`), which makes
                          // Info+Convert the sole source of the row's height and
                          // the chart stretch to meet it.
                          ? IntrinsicHeight(
                              child: Row(
                                spacing: GeniusWalletConsts.space8,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 2, child: _chartCard(null)),
                                  Expanded(
                                    flex: 1,
                                    child: _buildActionSection(
                                      marketData,
                                      selectedCoin,
                                      selectedNetwork,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // <1024 (and the no-market-data case): one column.
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: GeniusWalletConsts.space8,
                              children: [
                                // The card under the line is the chart, or - on
                                // the route that reaches this page from the
                                // wallet's own Assets list - the empty state
                                // saying why there is none.
                                if (marketData != null)
                                  _chartCard(chartHeight)
                                else
                                  _noMarketData(context),
                                _buildActionSection(
                                  marketData,
                                  selectedCoin,
                                  selectedNetwork,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Identity + actions + price, in the app's page header instead of an AppBar
  /// crumb.
  Widget _header(
    BuildContext context,
    Coin? selectedCoin,
    Wallet? selectedWallet,
    Network? selectedNetwork,
    bool isGnusBridgeEnabled,
    WalletDetailsCubit walletDetailsCubit,
  ) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // marketData is what can be missing, not the coin - so the title falls back
    // to the wallet's own record rather than to "Token".
    final String title =
        marketData?.name ??
        selectedCoin?.name ??
        selectedCoin?.symbol ??
        'Token';
    // Symbol and network only. **Rank left the subtitle on 2026-07-28** - the
    // stat rail's first tile is Rank, so the page was printing it twice, six
    // pixels apart. The rail is the better home: it formats 0 as "N/A" through
    // the shared rule, where a subtitle segment could only be present or
    // absent.
    final parts = <String>[
      (marketData?.symbol ?? selectedCoin?.symbol ?? '').toUpperCase(),
      if (selectedNetwork?.name != null) selectedNetwork!.name!,
    ].where((s) => s.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GWPageHeader(
        title: title,
        subtitle: parts.isEmpty ? null : parts.join('  ·  '),
        // Jakub 2026-07-28: *"Przed Genius AI powinna być ikona tokenu,
        // zawsze."* `buildTokenIcon` is the helper Markets already uses for
        // exactly this - it takes a URL or an asset path, and falls back to a
        // placeholder circle when the image is missing or fails to load, so
        // "zawsze" holds even for a coin with no artwork.
        //
        // CoinGecko's URL first, the wallet's own asset second: the market
        // record is what names the coin in the title, so the glyph beside it
        // should come from the same source.
        leading: buildTokenIcon(
          iconPath: (marketData?.imageUrl.isNotEmpty ?? false)
              ? marketData!.imageUrl
              : selectedCoin?.iconPath,
          size: 40,
        ),
        // **075-E2: the actions ride the title's own line**, separated from the
        // name by a hairline. Without it they read as part of the name -
        // "Receive" beside "GENIUS AI" as a label about the coin rather than an
        // action on your wallet. The rule is one `borderSubtle` line, the same
        // weight every card edge in the app uses.
        titleTrailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: GeniusWalletConsts.space6),
            Container(width: 1, height: 24, color: gw.borderSubtle),
            const SizedBox(width: GeniusWalletConsts.space4),
            _buildActionRow(
              context,
              selectedCoin,
              selectedWallet,
              selectedNetwork,
              isGnusBridgeEnabled,
              walletDetailsCubit,
            ),
          ],
        ),
        trailing: marketData == null ? null : _PriceBlock(data: marketData!),
      ),
    );
  }

  /// The chart card.
  ///
  /// [height] null means "fill whatever the parent hands down" - the wide
  /// layout, where `IntrinsicHeight` has already sized the row from the
  /// Info+Convert column. A number is for the stacked layouts, which have no
  /// column to line up with.
  Widget _chartCard(double? height) => GWCard(
    radius: GeniusWalletConsts.radiusMd,
    padding: const EdgeInsets.all(GeniusWalletConsts.space8),
    child: height == null
        ? _FillHeight(child: _buildGraphSection(marketData!))
        : SizedBox(height: height, child: _buildGraphSection(marketData!)),
  );

  /// Jakub 2026-07-28: *"wtedy no data czy coś"*. Says so, instead of dropping
  /// three blocks and leaving a shorter page with no explanation.
  ///
  /// **074-C2 moved it into the chart card's slot** rather than above the
  /// actions. It now stands exactly where the chart stands on every other
  /// route, under the same section line, so nothing on the page changes
  /// position between a covered coin and an uncovered one. The actions and the
  /// Info card are still not part of it - Receive does not need a market price.
  Widget _noMarketData(BuildContext context) => GWCard(
    radius: GeniusWalletConsts.radiusMd,
    padding: const EdgeInsets.all(GeniusWalletConsts.space8),
    child: const GWEmptyState(
      icon: Icons.show_chart,
      title: 'No market data',
      message:
          'This token is not covered by our market data provider, so there '
          'is no price, chart or market statistics for it. Everything else '
          'on this page still works.',
    ),
  );

  Widget _buildGraphSection(CoinGeckoMarketData marketData) {
    // sketch 152: the hero card owns the big price + % pill, so the chart
    // renders series-only (no built-in price header).
    return CryptoLiveChart(
      coinGeckoCoinId: marketData.id,
      tokenSymbol: marketData.symbol,
      showPriceHeader: false,
    );
  }

  /// **074-C2's action row: only what the code can actually do.**
  ///
  /// Jakub's rule, 2026-07-28: *"Jeśli czegoś nie ma w kodzie, to nie
  /// uwzględniamy designu."* Sketch 072 traced all four of the old tiles:
  ///
  ///  * **Receive** is real - the QR drawer, and it needs no market price, so
  ///    it works on every route including the no-data one.
  ///  * **Send is gone.** There is no send screen and no route;
  ///    `send_transaction_details.dart` is the WalletConnect *request* view, and
  ///    `GeniusApi.transferTokens` has zero callers in the repository. It is a
  ///    feature, not a wiring job, so it leaves the design rather than shipping
  ///    as a fourth grey box.
  ///  * **Swap** was built and never wired. It is wired here - but
  ///    `SwapScreen` takes no parameters, so this opens an EMPTY form and the
  ///    coin is not preselected. Nothing on screen promises otherwise.
  ///  * **Bridge** replaces the "More Options" drawer, which held exactly one
  ///    row. A drawer to reach one item was a click that bought nothing.
  ///
  /// **Bridge is ABSENT rather than disabled when the coin is not GNUS.** A
  /// permanently-grey button on Bitcoin says "unavailable", when the truth is
  /// "does not apply" - the old bar collapsed three different truths into one
  /// grey box (072 finding 3). Zero balance is the one case that IS a disabled
  /// state, because it is a state the user can change, so it lands on
  /// `onPressed: null`.
  ///
  /// The glyphs are Material icons, not the sketch-152 SVGs the old bar used:
  /// `GWButton` drives icon colour and size through an `IconTheme`, which a
  /// `SketchIcon` cannot read (it takes a required `color`), so an SVG would be
  /// the one glyph in the row that does not dim when Bridge is disabled.
  Widget _buildActionRow(
    BuildContext context,
    Coin? selectedCoin,
    Wallet? selectedWallet,
    Network? selectedNetwork,
    bool isGnusBridgeEnabled,
    WalletDetailsCubit walletDetailsCubit,
  ) {
    // Icon-only, so each button must say its own name: `tooltip` for the mouse,
    // `semanticLabel` for the screen reader.
    //
    // **`ghost`, not `icon`, and `md`, not `sm` - both because of one
    // constraint.** Jakub, 2026-07-28: *"te ikony powinny być [...] wysokości
    // tytułu, nie większe."* `headlineLg` is 24/32, so a 44px filled chip
    // stands 12px taller than the line it sits on and the header reads as if
    // the buttons were the headline.
    //
    // Shrinking the BUTTON to 32 was the obvious answer and is the wrong one:
    // `GWButton`'s `sm` carries `return 44; // was 36 — touch floor (iOS 44)`,
    // a decision this repository already made and reversed once. 32 clears
    // WCAG 2.5.8 (AA, 24x24) but drops below 2.5.5 (AAA, 44x44), on a page
    // that also renders on a phone.
    //
    // So the PAINTED box goes and the TARGET stays. `ghost` is transparent
    // fill, no border, leaving only the glyph - there is nothing left to be
    // taller than the title - while the button still measures 48. `md` rather
    // than `sm` because `sm`'s glyph is 16px, too faint beside a 24px title;
    // `md` gives 20px and a 48px target, above the floor rather than below it.
    // The row costs no height either way: the header line is already 62px,
    // driven by the two-line price block opposite.
    //
    // The accepted cost: at rest the icons have no boundary, and the hover
    // circle is the only edge. That is fine under 1.4.11 - a control's edge
    // must clear 3:1 only when the EDGE is what identifies the control, and
    // here the glyph is, at 15.8:1 dark / 16.1:1 light. Same argument
    // `GWSelectRow` recorded for its check mark.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GWButton.icon(
          icon: const Icon(Icons.qr_code_2),
          variant: GWButtonVariant.ghost,
          size: GWButtonSize.md,
          tooltip: 'Receive',
          semanticLabel: 'Receive',
          // The child goes in BARE, exactly as `coins_screen.dart` passes it.
          // This used to arrive wrapped in `Align(topCenter)` + `Padding(8)` +
          // `SizedBox(width: small * 0.5)`, all three of which are now the
          // shell's business or nobody's: the drawer applies
          // `kDrawerBodyPadding` itself (so the 8 was a second inset on top of
          // 20/24), `CryptoAddressQR` is a `mainAxisSize.min` centred Column
          // (so the Align did nothing), and the 300px cap squeezed the warning
          // note narrower than the panel it sits in.
          onPressed: () => ResponsiveDrawer.show<void>(
            context: context,
            // **The name comes from `selectedCoin` ONLY, never `marketData`.**
            // The QR shows the WALLET's address on the wallet's network, and
            // arriving here from Markets that network has nothing to do with
            // the coin you were reading about - titling this "Receive Bitcoin"
            // over an Ethereum address would be worse than saying less. When
            // there is no coin the title is just "Receive", which is what put
            // **"Receive null"** on screen before this.
            title: selectedCoin?.name == null
                ? 'Receive'
                : 'Receive ${selectedCoin!.name}',
            child: CryptoAddressQR(
              iconPath: selectedCoin?.iconPath,
              address: selectedWallet?.address ?? "",
              network: selectedNetwork?.name ?? "",
            ),
          ),
        ),
        GWButton.icon(
          icon: const Icon(Icons.swap_horiz),
          variant: GWButtonVariant.ghost,
          size: GWButtonSize.md,
          tooltip: 'Swap',
          semanticLabel: 'Swap',
          // **Preselection, gained in the 2026-07-28 merge.** Sketch 072 said
          // no variant may promise it, because `SwapScreen` took no parameters
          // - that was true of this branch and false of the base, which built
          // `preselectSymbol` / `preselectChainId` in Phase 8. The promise is
          // now keepable, so it is kept.
          //
          // **`marketData.symbol` FIRST, `selectedCoin` only as a fallback**,
          // which is the base branch's hard-won finding rather than a
          // preference: `selectedCoin` is the WALLET's currently-selected coin,
          // not the coin this page is showing. Opening a coin from Markets
          // leaves it null or pointing somewhere else entirely, which is why
          // preselection did nothing on exactly the route it was asked for.
          //
          // **`push`, not the base branch's `go`.** That `go` was a workaround
          // for a real crash - `/token-info` used to live OUTSIDE the
          // ShellRoute while `/swap` lived inside it, so pushing built a second
          // shell, the root navigatorKey appeared twice, and go_router asserted
          // `!keyReservation.contains(key)` while the navigation silently did
          // nothing. **071-B moved this route INSIDE the shell**, so both now
          // push onto the same navigator and the cause is gone - and `push`
          // keeps the back stack, where `go` replaced the location and lost the
          // way back to the coin. Walk this one: the failure it replaces was
          // real and was reported from a walk.
          onPressed: () => GoRouter.of(context).push(
            '/swap',
            extra: <String, dynamic>{
              'symbol': marketData?.symbol ?? selectedCoin?.symbol,
              // A weak hint, and only a preference - an unmatched chain falls
              // back rather than blocking.
              'chainId': selectedNetwork?.chainId,
            },
          ),
        ),
        if (isGnusBridgeEnabled)
          GWButton.icon(
            icon: const Icon(Icons.alt_route),
            variant: GWButtonVariant.ghost,
            size: GWButtonSize.md,
            tooltip: selectedCoin?.balance == 0
                ? 'Bridge - no balance to move'
                : 'Bridge',
            semanticLabel: 'Bridge tokens',
            onPressed: selectedCoin?.balance == 0
                ? null
                : () => _pushBridgeScreen(context, walletDetailsCubit),
          ),
      ],
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
    return CoinInfoCard(
      marketData: marketData,
      address: selectedCoin?.address,
      network: selectedNetwork?.name,
    );
  }

  /// The Convert card alone — reused standalone on mobile (sketch 152 D) so it
  /// can render directly below the chart, above the Info card.
  Widget _buildConvertSection(CoinGeckoMarketData? marketData) {
    return CoinConvertCard(tokenPrice: marketData?.currentPrice ?? 0.0);
  }
}

/// Public only so the 070-A check can pump it without standing up a
/// `WalletDetailsCubit` and a router. It is not exported anywhere else and has
/// exactly one call site, `_buildConvertSection`.
class CoinConvertCard extends StatefulWidget {
  final double tokenPrice;

  const CoinConvertCard({super.key, required this.tokenPrice});

  @override
  State<CoinConvertCard> createState() => CoinConvertCardState();
}

class CoinConvertCardState extends State<CoinConvertCard> {
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
          const SizedBox(height: GeniusWalletConsts.space6),
          Column(
            spacing: GeniusWalletConsts.space6,
            children: [
              // Read-only display of marketData.currentPrice (sketch 152: only
              // Token Amount is editable).
              //
              // 070-A: both fields left the notched Material floating label -
              // the only pattern of its kind in the app besides
              // `custom_drop_down.dart` - for `GWTextField`, which puts the
              // label ABOVE the box at labelMd/textSecondary/space4 like every
              // other field the app ships.
              //
              // The READ-ONLY chip rides in `suffix` rather than beside the
              // label because `GWTextField.label` is a `String`, not a `Widget`;
              // growing it for one consumer fails the promotion test everything
              // else this week was held to. It also lands on the thing it
              // describes.
              //
              // **The two fields rest at different edge weights on purpose.**
              // The editable one is `borderControl` (3.30:1) via `focusRing`;
              // this one keeps the component's `borderSubtle` default (1.32:1).
              // A read-only display is not a UI component under 1.4.11, and the
              // difference is information - the louder edge is the one you can
              // type in. `focusRing` here was rejected deliberately: a
              // `readOnly` field still takes focus in Flutter, so it would light
              // a gradient promising an edit that cannot happen.
              GWTextField(
                controller: _tokenPriceController,
                label: "Token price",
                readOnly: true,
                fill: gw.surfaceSunken,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(
                    right: GeniusWalletConsts.space6,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 1,
                    child: Container(
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: gw.textPrimary54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // The one editable control on this card, so it is the one that
              // gets the brand GRADIENT on focus. It lit a FLAT
              // `brandPrimaryStrong` before - structurally, not by oversight: a
              // `BorderSide` takes a single `Color`, so no `InputBorder` can be
              // a gradient, which is the whole reason `GWFocusRing` exists.
              GWTextField(
                controller: _tokenAmountController,
                label: "Token amount",
                focusRing: true,
                fill: gw.surfaceSunken,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => _calculateTotalValue(),
              ),
              // The card's one computed answer, given the same frame as the
              // facts it is computed from (070-A). It was a bare right-aligned
              // `bodyLarge` - the only element on the page with no structure at
              // all, which read as a caption rather than a result.
              GWDetailGrid(
                rows: [
                  Padding(
                    padding: kGWDetailRowPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textPrimary,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: "en_US",
                            symbol: "\$",
                          ).format(_totalValue),
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Public for the same reason as [CoinConvertCard]: so the glyph rule below can
/// be pinned by a test that pumps the card directly. One call site,
/// `_buildInfoSection`.
class CoinInfoCard extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;

  const CoinInfoCard({super.key, this.marketData, this.network, this.address});

  /// ONE accent for every info-row glyph, chosen by Jakub 2026-07-28 on sketch
  /// 070's four-panel comparison.
  ///
  /// **This replaces a deliberate per-row rainbow that was Jakub's own earlier
  /// request, so here is the measurement it was replaced on rather than a silent
  /// revert.** Five of the six colours were raw constants tuned against the dark
  /// canvas, and on the light well (`#CFD4DB`) they collapse:
  ///
  /// | glyph | dark | light |
  /// |---|---|---|
  /// | `statusSuccess` (Market Cap) | 10.80 | **1.25** |
  /// | `brandTertiary` (Circulating) | 8.27 | **1.63** |
  /// | `brandPrimaryStrong` (Address) | 7.84 | **1.72** |
  /// | `statusError` (Total Supply) | 6.13 | **2.19** |
  /// | `statusNeutral` (Volume) | 4.21 | 3.19 |
  /// | `brandPrimaryOnSurface` (Network) | 10.25 | **4.23** |
  ///
  /// Network was the tell: it is the ONLY appearance-aware colour in the set
  /// (`#14C8FF` dark / `#0A6885` light) and the only one that survives. So the
  /// real choice was five new light-mode tokens, or the one colour that already
  /// carries both - and it is this one.
  ///
  /// None of this is a WCAG failure: every row is fully identified by its label,
  /// so the glyphs are decorative under 1.4.11. It is legibility, plus one
  /// semantic gain - `statusError` red is the app's ERROR tone and it was being
  /// spent on Total Supply, where nothing is wrong.
  ///
  /// The accepted cost, stated: the card reads quieter, and rows lose per-row
  /// colour coding.
  static Color get _glyph => GeniusWalletColors.brandPrimaryOnSurface;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final textTheme = Theme.of(context).textTheme;
    // sketch 152 `.statrow`: grayish key + primary tabular value, both compact.
    final TextStyle keyStyle = (textTheme.bodySmall ?? const TextStyle())
        .copyWith(color: gw.textSecondary, fontSize: 14);
    final TextStyle valStyle = (textTheme.bodySmall ?? const TextStyle())
        .copyWith(
          color: gw.textPrimary,
          fontSize: 14,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    /// One row of the grid. The 11/12 padding this used to hard-code was
    /// `kGWDetailRowPadding` written out by hand; the row applies it itself so a
    /// TAPPABLE row's hit area covers the whole cell (see the constant's doc).
    Widget statRow(String svg, String label, Widget value) {
      return Padding(
        padding: kGWDetailRowPadding,
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Center(child: SketchIcon(svg, size: 16, color: _glyph)),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(
              child: Text(
                label,
                style: keyStyle,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            value,
          ],
        ),
      );
    }

    final infoTiles = <Widget>[
      if (network != null)
        statRow(
          SketchIcons.network,
          "Network",
          Text(network!, style: valStyle),
        ),
      if (address != null)
        _CopyAddressRow(
          address: address!,
          keyStyle: keyStyle,
          valStyle: valStyle,
          glyph: _glyph,
        ),
      statRow(
        SketchIcons.marketCap,
        "Market Cap",
        Text(formatCompactCurrency(marketData?.marketCap), style: valStyle),
      ),
      statRow(
        SketchIcons.circulating,
        "Circulating Supply",
        Text(
          formatCompactDecimal(marketData?.circulatingSupply),
          style: valStyle,
        ),
      ),
      statRow(
        SketchIcons.totalSupply,
        "Total Supply",
        Text(formatCompactDecimal(marketData?.totalSupply), style: valStyle),
      ),
      statRow(
        SketchIcons.volume,
        "Volume",
        Text(formatCompactCurrency(marketData?.totalVolume), style: valStyle),
      ),
    ];

    // sketch 152 `.surf` Info card: the "Info" title moves INSIDE the card
    // (sectitle style) and the duplicate token-identity header row is gone —
    // the hero already shows identity.
    //
    // 070-A: the rows were a hand-written `GWDetailGrid` - 11/12 padding, a 22px
    // glyph slot, a bare `Column` with `Divider(height: 1)` between children and
    // no well around any of it - written days after the component shipped for
    // the transaction receipt. Now it IS the component, so the group reads as
    // recessed and the rules stop at the rounded corners.
    return GWCard(
      radius: GeniusWalletConsts.radiusMd,
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Info"),
          const SizedBox(height: GeniusWalletConsts.space6),
          GWDetailGrid(rows: infoTiles),
        ],
      ),
    );
  }
}

/// The Address row: the WHOLE row copies, and the glyph is there at rest.
///
/// It used to be an inline 15px `IconButton` at the end of the value - a target
/// you had to hit precisely, on a row whose remaining ~330px did nothing. The
/// transaction receipt settled this on 2026-07-28: the copy affordance is
/// present at rest (an affordance you must hover to discover is not one) and the
/// hit area is the whole grid cell, which is exactly why `GWDetailGrid` makes
/// its ROWS apply [kGWDetailRowPadding] instead of padding them itself.
///
/// **`_CopyRow` is deliberately NOT promoted out of `transaction_displays.dart`
/// to serve both.** That would put it at TWO consumers, under the 3+ bar
/// `GWKicker`, `GWSelectRow` and `GWWarningNote` each had to clear - and the two
/// rows are not the same shape anyway: this one carries a leading glyph and
/// truncates 6…6, the receipt's carries none and chunks 8+8 in four-character
/// groups. Sharing them would mean two new parameters for one extra consumer.
/// What is shared is the BEHAVIOUR, which is the part a user can tell apart.
///
/// ponytail: two implementations of one affordance, on purpose.
/// Ceiling: they can drift, and only a walk would notice.
/// Upgrade path: a third consumer makes the component worth building, and at
/// that point the glyph slot and the truncation strategy become its parameters.
class _CopyAddressRow extends StatefulWidget {
  const _CopyAddressRow({
    required this.address,
    required this.keyStyle,
    required this.valStyle,
    required this.glyph,
  });

  final String address;
  final TextStyle keyStyle;
  final TextStyle valStyle;
  final Color glyph;

  @override
  State<_CopyAddressRow> createState() => _CopyAddressRowState();
}

class _CopyAddressRowState extends State<_CopyAddressRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final a = widget.address;
    final short = a.length > 12
        ? "${a.substring(0, 6)}...${a.substring(a.length - 6)}"
        : a;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // The FULL address goes to the clipboard, never the truncated form.
          Clipboard.setData(ClipboardData(text: a));
          showAppSnackBar(context, 'Address copied to clipboard');
        },
        // Inside the detector, so the whole cell is the target.
        child: Padding(
          padding: kGWDetailRowPadding,
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Center(
                  child: SketchIcon(
                    SketchIcons.address,
                    size: 16,
                    color: widget.glyph,
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(child: Text("Address", style: widget.keyStyle)),
              Text(short, style: widget.valStyle),
              const SizedBox(width: GeniusWalletConsts.space3),
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: _hovered ? gw.textPrimary : gw.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "‹ Markets" - the way back, now that the AppBar's chevron is gone.
///
/// `context.pop()` rather than `Navigator.of(context).maybePop()`: inside a
/// ShellRoute the go_router call is the one that means "back in the route
/// stack", where the raw Navigator call pops whichever Navigator happens to be
/// nearest - which after 071-B's route move is the shell's, not the root's.
class _BackToMarkets extends StatefulWidget {
  const _BackToMarkets();

  @override
  State<_BackToMarkets> createState() => _BackToMarketsState();
}

class _BackToMarketsState extends State<_BackToMarkets> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          GeniusWalletConsts.space4,
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space6,
                vertical: GeniusWalletConsts.space3,
              ),
              decoration: BoxDecoration(
                // The app-wide hover recipe: brand tint + brand hairline. The
                // border is ALWAYS 1px, transparent at rest, because a
                // BoxDecoration border is layout - appearing on hover would
                // grow the chip and shift the header under the cursor.
                color: _hovered ? GWDecorations.hoverFill : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _hovered ? GWDecorations.hoverEdge : gw.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: 16,
                    color: _hovered ? gw.textPrimary : gw.textSecondary,
                  ),
                  const SizedBox(width: GeniusWalletConsts.space3),
                  Text(
                    'Markets',
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: _hovered ? gw.textPrimary : gw.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The price and its 24h pill, in `GWPageHeader`'s trailing slot.
class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.data});

  final CoinGeckoMarketData data;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final pct = data.priceChangePercentage24h;
    final up = pct >= 0;
    final tone = up ? gw.statusSuccess : gw.statusError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatPrice(data.currentPrice),
          style: GeniusWalletTypography.numericBody.copyWith(
            color: gw.textPrimary,
            fontSize: 28,
            height: 34 / 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (pct != 0) ...[
          const SizedBox(height: GeniusWalletConsts.space3),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 16,
                  color: tone,
                ),
                Text(
                  formatPercent(pct),
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Sketch 071-B's stat rail: six tiles of data the app was already paying for.
///
/// **Every field here was already parsed and already cached** - the request at
/// `coin_gecko_api.dart:140` is `/coins/markets`, which returns all of them by
/// default, and they land in `marketDataBox` on a 3-minute TTL. So this row
/// costs zero new requests, which is the entire reason it is the fill for the
/// space the 480px literal used to waste.
///
/// Every number goes through the shared "0 means unknown" formatters, because
/// `fromJson` defaults numerics to `0.0` and the rank to `0` - without that a
/// coin missing a field would print `$0.00` and `#0` with total confidence.
class _StatRail extends StatelessWidget {
  const _StatRail({required this.data});

  final CoinGeckoMarketData data;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final pct = data.priceChangePercentage24h;
    final ath = data.athChangePercentage;

    final tiles = <Widget>[
      GWStatTile(
        label: 'Rank',
        value: data.marketCapRank > 0 ? '#${data.marketCapRank}' : 'N/A',
      ),
      GWStatTile(
        label: '24h change',
        value: formatPercent(pct),
        valueColor: pct == 0
            ? null
            : (pct > 0 ? gw.statusSuccess : gw.statusError),
      ),
      GWStatTile(
        label: 'Volume 24h',
        value: formatCompactCurrency(data.totalVolume),
      ),
      GWStatTile(
        label: 'Market cap',
        value: formatCompactCurrency(data.marketCap),
      ),
      GWStatTile(
        label: 'From ATH',
        value: formatPercent(ath),
        valueColor: ath == 0
            ? null
            : (ath > 0 ? gw.statusSuccess : gw.statusError),
      ),
      _RangeTile(low: data.low24h, high: data.high24h, now: data.currentPrice),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Six across needs roughly 150 each; below that they wrap rather than
        // ellipsing every value at once.
        final int perRow = constraints.maxWidth >= 900
            ? 6
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        final double gap = GeniusWalletConsts.space6.toDouble();
        final double w = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles)
              SizedBox(
                width: w,
                child: GWCard(
                  radius: GeniusWalletConsts.radiusMd,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space6,
                    vertical: GeniusWalletConsts.space6,
                  ),
                  child: t,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The 24h low/high tile: a [GWStatTile] with a position bar under it.
///
/// Composed rather than given to `GWStatTile` as a `footer` slot, which would
/// have been a parameter for exactly one consumer.
class _RangeTile extends StatelessWidget {
  const _RangeTile({required this.low, required this.high, required this.now});

  final double low;
  final double high;
  final double now;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final bool known = low > 0 && high > low;
    final double t = known ? ((now - low) / (high - low)).clamp(0.0, 1.0) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GWStatTile(
          label: '24h range',
          value: known
              ? '${formatCompactCurrency(low)} - ${formatCompactCurrency(high)}'
              : 'N/A',
        ),
        if (known) ...[
          const SizedBox(height: GeniusWalletConsts.space4),
          // A 4px track with the current price's position along it. Decorative:
          // the numbers above say the same thing, so 1.4.11 does not apply and
          // borderSubtle is the right weight.
          LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: gw.surfaceSunken,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: gw.borderSubtle, width: 0.5),
                  ),
                ),
                Positioned(
                  left: (c.maxWidth - 6) * t,
                  child: Container(
                    width: 6,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: GeniusWalletGradient.brandCta,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Reports **zero** intrinsic height, then fills whatever height it is given.
///
/// This is what makes the chart line up with Info+Convert instead of driving
/// the row. `IntrinsicHeight` sizes a Row to the tallest child's *intrinsic*
/// height; a chart has no meaningful answer to "how tall do you want to be"
/// (and `CryptoLiveChart` contains an `Expanded`, which throws outright when
/// asked). Answering 0 hands the decision entirely to the Info+Convert column,
/// which is exactly Jakub's *"musi być IN LINE"*.
///
/// ponytail: a `RenderProxyBox` override rather than a layout algorithm.
/// Ceiling: inside a plain unbounded Column this would collapse to nothing, so
/// it is only correct under a parent that supplies a tight height - which the
/// single call site does. Upgrade path: none needed; if a second caller appears
/// it should assert its parent instead.
class _FillHeight extends SingleChildRenderObjectWidget {
  const _FillHeight({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFillHeight();
}

class _RenderFillHeight extends RenderProxyBox {
  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;
}
