import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
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
                        decoration: InputDecoration(
                          hintText: "0.0",
                          hintStyle: heroStyle.copyWith(
                            color: gw.textPrimary38,
                          ),
                          border: InputBorder.none,
                        ),
                        controller: controller,
                        onChanged: onChanged,
                      ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      TokenSelectorDrawer.show(
                        context: context,
                        tokens: tokens,
                        onTokenSelected: onTokenSelected,
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
                        color: gw.surfaceMenu,
                        borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.radiusPill,
                        ),
                        border: Border.all(color: gw.borderSubtle, width: 1),
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
                  Padding(
                    padding: const EdgeInsets.only(
                      top: GeniusWalletConsts.space4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedToken?.balance != null
                              ? "${selectedToken!.balance!.formattedBalance} ${selectedToken!.balance!.symbol}"
                              : "",
                          style: GeniusWalletTypography.labelMd.copyWith(
                            color: gw.textSecondary,
                          ),
                        ),
                        if (showMax) ...[
                          const SizedBox(width: GeniusWalletConsts.space4),
                          InkWell(
                            onTap: () {
                              final formatted = selectedToken!
                                  .balance!
                                  .formattedBalance;
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
                                color: GeniusWalletColors.brandPrimarySubtle,
                                borderRadius: BorderRadius.circular(
                                  GeniusWalletConsts.radiusSm,
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
    );
  }
}
