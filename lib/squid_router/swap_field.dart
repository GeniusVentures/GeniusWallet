import 'package:flutter/material.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/squid_router/token_selector_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class SwapField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final SquidTokenInfo? selectedToken;
  final bool isSelectingFrom;
  final List<SquidTokenInfo> tokens;
  final void Function(SquidTokenInfo token) onTokenSelected;

  const SwapField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.selectedToken,
    required this.isSelectingFrom,
    required this.tokens,
    required this.onTokenSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: GeniusWalletColors.deepBlueCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space8,
          vertical: GeniusWalletConsts.space4),
      child: Padding(
        padding: const EdgeInsets.only(
            left: GeniusWalletConsts.space8,
            right: GeniusWalletConsts.space8,
            top: GeniusWalletConsts.space8,
            bottom: GeniusWalletConsts.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GeniusWalletTypography.bodyMd
                    .copyWith(color: GeniusWalletColors.textPrimary70)),
            const SizedBox(height: GeniusWalletConsts.space4),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    style: const TextStyle(color: GeniusWalletColors.textPrimary),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: "0.0",
                      hintStyle: TextStyle(color: GeniusWalletColors.textPrimary30),
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
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: GeniusWalletConsts.space2,
                            right: GeniusWalletConsts.space4,
                            top: 2,
                            bottom: 2),
                        decoration: BoxDecoration(
                          color: GeniusWalletColors.deepBlue,
                          borderRadius: BorderRadius.circular(40),
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
                                      color: Colors.grey[700],
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image,
                                          color: GeniusWalletColors.textPrimary70, size: 16),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(width: GeniusWalletConsts.space4),
                            Text(
                              selectedToken?.symbol ?? "Select",
                              style: const TextStyle(
                                color: GeniusWalletColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: GeniusWalletConsts.space4),
                            const Icon(Icons.keyboard_arrow_down,
                                color: GeniusWalletColors.textPrimary, size: 14),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: GeniusWalletConsts.space4),
                      child: Text(
                        selectedToken?.balance != null
                            ? "${selectedToken!.balance!.formattedBalance} ${selectedToken!.balance!.symbol}"
                            : "",
                        style: const TextStyle(
                            color: GeniusWalletColors.textPrimary54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
