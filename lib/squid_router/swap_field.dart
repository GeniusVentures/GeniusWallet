import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/utils/formatters.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/token_selector_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class SwapField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final SquidTokenInfo? selectedToken;
  final bool isSelectingFrom;
  final List<SquidTokenInfo> tokens;
  final void Function(SquidTokenInfo token) onTokenSelected;

  /// When non-null AND [controller] is empty, the amount slot renders this
  /// string in the 38px hero style (coloured `gw.textPrimary38`) INSTEAD of
  /// the TextField's hint. Defaults to null so every current call site
  /// renders exactly as it does today; the hook exists for a future
  /// route-error state ("—" instead of a stale amount).
  final String? emptyPlaceholder;

  const SwapField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.selectedToken,
    required this.isSelectingFrom,
    required this.tokens,
    required this.onTokenSelected,
    this.emptyPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final heroStyle = GeniusWalletTypography.numericDisplay.copyWith(
      fontSize: 38,
      height: 1.0,
    );

    final showMax = isSelectingFrom && selectedToken?.balance != null;

    final double? usdValue = selectedToken != null
        ? fiatValue(
            symbol: selectedToken!.symbol,
            amount: double.tryParse(controller.text) ?? 0,
            pricesBySymbol: livePricesBySymbol(),
          )
        : null;

    return GWFocusRing(
      radius: GeniusWalletConsts.radiusLg + 2,
      // Transparent at rest, so the card keeps its own hairline and elevation
      // and nothing about the resting card changes. On focus the ring lights
      // as a gradient halo just outside that hairline. The 1.5px is reserved
      // in BOTH states, so clicking into the amount never nudges the card.
      restingColor: Colors.transparent,
      background: Colors.transparent,
      // "You Receive" is readOnly but still focusable for selection/copy —
      // lighting a ring on a field that refuses typing would be a lie.
      enabled: isSelectingFrom,
      child: GWCard(
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
              label,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: (emptyPlaceholder != null && controller.text.isEmpty)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            emptyPlaceholder!,
                            style: heroStyle.copyWith(color: gw.textPrimary38),
                          ),
                        )
                      : TextField(
                          style: heroStyle.copyWith(color: gw.textPrimary),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          // The bridge — this screen's twin — has guarded its
                          // amount field since 08-04; Swap accepted letters.
                          // `decimalRange` caps precision at what the token can
                          // actually represent, so the field cannot promise more
                          // digits than survive on chain.
                          inputFormatters: [
                            DecimalTextInputFormatter(
                              decimalRange: selectedToken?.decimals,
                            ),
                          ],
                          // "You Receive" is derived from the route, never typed:
                          // its `onChanged` only calls `setState`, and the next
                          // quote overwrites whatever was entered. A field that
                          // accepts input and silently discards it is worse than
                          // one that declines it. If a reverse quote ever lands,
                          // this becomes its own flag rather than riding along.
                          readOnly: !isSelectingFrom,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            hintText: "0.0",
                            hintStyle: heroStyle.copyWith(
                              color: gw.textPrimary38,
                            ),
                            border: InputBorder.none,
                            // `border` is only the FALLBACK. theme.dart:242 sets
                            // an app-wide `focusedBorder` (a radiusLg brand
                            // outline), and a per-state border always beats the
                            // fallback — so this "borderless" hero amount grew a
                            // blue rounded box the moment it took focus, cutting
                            // across the card that is its real frame. Silencing
                            // the state explicitly is the only thing that holds;
                            // the card already carries the border.
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            // Material 3's default for an unfilled, non-dense
                            // borderless field is vertical 8 (measured, not
                            // assumed: input_decorator.dart:2617). Pinning it
                            // keeps this branch and the placeholder branch above
                            // on ONE baseline — a framework default drifting
                            // would otherwise make the amount jump as the "—"
                            // is replaced by a number.
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                          controller: controller,
                          onChanged: onChanged,
                        ),
                ),
                const SizedBox(width: GeniusWalletConsts.space4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Hoverable(
                      builder: (hovered) => InkWell(
                        onTap: () {
                          TokenSelectorDrawer.show(
                            context: context,
                            tokens: tokens,
                            onTokenSelected: onTokenSelected,
                            // Without this the picker reopens showing no trace
                            // of what is already chosen (032-A1's selection).
                            selectedToken: selectedToken,
                          );
                        },
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.radiusPill,
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 4,
                            right: 8,
                            top: 2,
                            bottom: 2,
                          ),
                          decoration: BoxDecoration(
                            // THE app-wide hover recipe (sketch 044 variant 3):
                            // brand tint + brand hairline, no geometry — the same
                            // two tokens nav chips, tabs and GWCard read. This
                            // control is the primary affordance on the card and
                            // was the only one on it that read as inert.
                            color: hovered
                                ? GWDecorations.hoverFill
                                : gw.surfaceMenu,
                            borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.radiusPill,
                            ),
                            border: Border.all(
                              color: hovered
                                  ? GWDecorations.hoverEdge
                                  : gw.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (selectedToken != null)
                                ClipOval(
                                  child: Image.network(
                                    selectedToken!.logoURI,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    // The slot is already 32x32, so nothing moves
                                    // when the bytes land — but until they do it
                                    // is a hole beside the symbol. A neutral disc
                                    // holds the shape, reusing the error branch's
                                    // idea of "no logo" rather than inventing a
                                    // second one.
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        color: gw.surfaceMenu,
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        color: gw.surfaceMenu,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.broken_image,
                                          color: gw.textSecondary,
                                          size: 16,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                selectedToken?.symbol ?? "Select",
                                style: GeniusWalletTypography.titleMd.copyWith(
                                  color: gw.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: gw.textSecondary,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: GeniusWalletConsts.space4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            // `displayBalance`, not `formattedBalance`: this
                            // line is FOR EYES, and an 18-decimal token renders
                            // its float error verbatim - 0.01 DAI reached this
                            // row as `0.010000000000000221`. The MAX tap below
                            // deliberately keeps the exact string, which is the
                            // split `displayBalance`'s own doc describes.
                            selectedToken?.balance != null
                                ? "${selectedToken!.balance!.displayBalance} ${selectedToken!.balance!.symbol}"
                                : "",
                            style: GeniusWalletTypography.labelMd.copyWith(
                              color: gw.textSecondary,
                            ),
                          ),
                          if (showMax) ...[
                            const SizedBox(width: GeniusWalletConsts.space4),
                            _Hoverable(
                              builder: (hovered) => InkWell(
                                onTap: () {
                                  final formatted =
                                      selectedToken!.balance!.formattedBalance;
                                  controller.text = formatted;
                                  onChanged(controller.text);
                                },
                                borderRadius: BorderRadius.circular(
                                  GeniusWalletConsts.radiusSm,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: GeniusWalletConsts.space4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    // This chip's resting fill IS the hover tint
                                    // (`brandPrimarySubtle` == `GWDecorations
                                    // .hoverFill`), so re-tinting would say nothing.
                                    // Hover adds the recipe's other half — the brand
                                    // hairline — and the control still answers.
                                    color:
                                        GeniusWalletColors.brandPrimarySubtle,
                                    borderRadius: BorderRadius.circular(
                                      GeniusWalletConsts.radiusSm,
                                    ),
                                    // ALWAYS a 1px border, transparent at rest.
                                    // A `BoxDecoration` border is layout, not
                                    // paint: `Border.all(width: 1)` adds 1px to
                                    // every side of the box, so appearing on
                                    // hover grew the chip 2x2, which grew the
                                    // Row, the card and the whole centred swap
                                    // column - the page visibly jumped under the
                                    // cursor. Same defect `GWSelectRow` fixed on
                                    // 2026-07-28 (068-A) and pins with a test.
                                    border: Border.all(
                                      color: hovered
                                          ? GWDecorations.hoverEdge
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "MAX",
                                    style: GeniusWalletTypography.labelMd
                                        .copyWith(
                                          color: GeniusWalletColors
                                              .brandPrimaryOnSurface,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (usdValue != null) ...[
              const SizedBox(height: GeniusWalletConsts.space2),
              Text(
                "\$${usdValue.toStringAsFixed(2)}",
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reports pointer hover to [builder] so a plain `Container` can take the
/// app-wide hover recipe.
///
/// The nav bar gets this for free because its controls are buttons, and a
/// `ButtonStyle` resolves `WidgetState.hovered` on its own. These two are an
/// `InkWell` wrapping a decorated `Container`, which has no such channel — and
/// `InkWell.onHover` cannot repaint a decoration it does not own. Kept private:
/// this is a local shim, not a component, and it disappears the day these two
/// controls become buttons.
class _Hoverable extends StatefulWidget {
  const _Hoverable({required this.builder});

  final Widget Function(bool hovered) builder;

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: widget.builder(_hovered),
  );
}
