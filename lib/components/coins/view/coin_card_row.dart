import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_row_rhythm.dart';
import 'package:genius_wallet/components/effects/gw_hover_row.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:intl/intl.dart';

/// A2 · Market-forward Assets row (sketch 001). The subtitle carries MARKET
/// data (price + 24h% chip [+ · network]) at full strength regardless of
/// balance, so a zero-balance row still reads as alive; the trailing column
/// carries the HOLDING (fiat value over token amount) and is the only thing
/// dimmed (~38%) when the balance is zero.
// Text, not AutoSizeText: AutoSizeText searches for a font size that
// fits its box, so a drag-resize mints a distinct TextStyle — a distinct
// skia ParagraphCacheKey — per frame, per row. That is the cache thrash
// that freezes the macOS window (37639d5). Every one of these already
// carried `overflow: ellipsis`, so the swap only drops the shrink-to-fit
// step, which is precisely the part that could not be made safe.
class CoinCardRow extends StatelessWidget {
  final String iconPath;
  final String name;
  final String symbol;
  final double? balance;
  final CoinGeckoMarketData? marketData;
  final VoidCallback? onTap;

  const CoinCardRow({
    super.key,
    required this.iconPath,
    required this.name,
    this.balance,
    required this.symbol,
    this.marketData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final NumberFormat currencyFormatter = NumberFormat.currency(symbol: "\$");

    final double price = marketData?.currentPrice ?? 0.0;
    final double pct = marketData?.priceChangePercentage24h ?? 0.0;
    final double fiatValue = price * (balance ?? 0.0);
    final bool noBalance = (balance ?? 0.0) == 0.0;

    // Up/down standardized on the status tokens (never cyan): positive =
    // success, negative = error. No longer balance-gated.
    final Color changeColor = pct >= 0 ? gw.statusSuccess : gw.statusError;

    final String amountText = noBalance
        ? "0.0000 $symbol"
        : "${WalletUtils.truncateToDecimals(balance.toString())} $symbol";

    // **The Assets rows had no hover at all, and the `ListTile` was why.**
    // A `ListTile` draws its highlight on the nearest ANCESTOR `Material`, and
    // in the dashboard's Assets panel that ancestor sits beneath the panel's
    // own painted background - so the highlight was rendered and then covered
    // by the very surface it was meant to light up. `GWHoverRow` carries its
    // own transparent `Material` above the caller's paint, so the highlight
    // cannot be buried, and it clips to `radiusMd` like the other two lists.
    //
    // The tile keeps its layout and loses only its tap: two overlapping ink
    // responses on one row would double the highlight and fight for the
    // pointer. `ListTile` renders no background of its own, so the highlight
    // shows straight through it.
    return GWHoverRow(
      onTap: onTap,
      semanticLabel: name,
      // 2026-08-07, 260807-wbu: the `ListTile` is gone. `contentPadding` is
      // charged INSIDE Material's default two-line tile snap, so it could
      // never subtract from it - this row already declared `vertical: 4` and
      // still rendered 15.63 / 20.00 around the rule between two rows,
      // because the snap's centring slack ate the difference. `kGWRowPadding`
      // (`gw_row_rhythm.dart`) is charged on a plain `Row` with no snap to
      // absorb it, which is what makes 8 / 38 / 8 / 8 and 12 / 1 / 12 the
      // numbers that actually paint, not just the numbers in source.
      child: Padding(
        padding: kGWRowPadding,
        child: Row(
          children: [
            buildTokenIcon(iconPath: iconPath, size: kGWRowIconSize),
            const SizedBox(width: kGWRowIconToText),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GeniusWalletTypography.titleMd.copyWith(
                      color: gw.textPrimary,
                    ),
                  ),
                  // The `ListTile` gave title/subtitle their gap for free;
                  // a bare Column does not, so this states it explicitly
                  // rather than let the two paragraphs touch. `space2`
                  // matches the same title-to-subtitle gap
                  // `transaction_displays.dart`'s row uses.
                  const SizedBox(height: GeniusWalletConsts.space2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          currencyFormatter.format(price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Filled 24h% chip — market data, always full strength.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
                          style: GeniusWalletTypography.labelMd.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: kGWRowIconToText),
            // `Flexible`, not `Expanded`, and that is a deliberate difference
            // from `transaction_displays.dart`'s amount column. That row's
            // amount is `Expanded` because it must right-align flush to the
            // card edge and ellipsise at a fixed 320px case. Here the
            // trailing column is two UNBOUNDED `Text`s with no fixed-width
            // caller, so it needs a bounded box to ellipsise inside at all -
            // but `Expanded` would force the Column to occupy the full
            // flex share (tight fit) even when its content ("$0.00" /
            // "0.0000 ETH") is short. `Flexible` keeps that fit loose, so
            // the Column itself never widens past its own content.
            //
            // The `Align` below is still required: `crossAxisAlignment: end`
            // on its own only right-aligns children WITHIN the Column's own
            // (shrink-wrapped) width, not within the row's full flex
            // allocation - measured, a bare `Flexible` here left a ~33px gap
            // on the right instead of the wall's 8. `Align` (no width
            // factor) fills the loose allocation and positions the
            // shrink-wrapped Column at its right edge, which reproduces what
            // `ListTile`'s intrinsic-width `trailing` slot did. A future
            // shared row component must not "tidy" this into `Expanded` to
            // match the other row - the two anatomies disagree here on
            // purpose (see `crypto_simple_chart.dart`'s own trailing, which
            // disagrees a third way: non-flex, because its content is
            // bounded by construction).
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                // `heightFactor: 1` is load-bearing, not decoration: without
                // it `Align` fills the ROW's own (unbounded, in a plain
                // `Row`) cross-axis height too, not just its width - the row
                // measured 398 tall instead of the intended ~62 until this
                // was added. `widthFactor` stays null on purpose so the
                // width still fills the loose flex allocation for the
                // right-alignment this block exists for.
                heightFactor: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyFormatter.format(fiatValue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GeniusWalletTypography.numericBody.copyWith(
                        fontWeight: FontWeight.bold,
                        // 24-01: was `textPrimary38`. Measured on `surfaceBase`
                        // #0B0D12 that composites to 3.54:1 -- under WCAG AA's 4.5:1
                        // for body text, and this IS body text: a balance is content,
                        // not a disabled control. `textPrimary80` lands at 12.4:1.
                        //
                        // The dimming is kept, just legibly: a zero balance still reads
                        // quieter than a funded one (80% against 100%), which is the
                        // whole point of the `noBalance` branch. It stops reading as
                        // broken -- the sketch MANIFEST's own rule, "a wallet with no
                        // funds is not a broken wallet".
                        color: noBalance ? gw.textPrimary80 : gw.textPrimary,
                      ),
                    ),
                    Text(
                      amountText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        // Same 24-01 fix. `textSecondary` (#8A8F9D) is itself 6.0:1, so
                        // the funded branch was already fine; only the zero branch fell
                        // through the floor.
                        color: noBalance ? gw.textPrimary80 : gw.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
