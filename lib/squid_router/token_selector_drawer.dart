import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class TokenSelectorDrawer extends StatefulWidget {
  final List<SquidTokenInfo> tokens;
  final ValueChanged<SquidTokenInfo> onTokenSelected;
  final String title;

  const TokenSelectorDrawer({
    super.key,
    required this.tokens,
    required this.onTokenSelected,
    this.title = "Select Token",
  });

  static void show({
    required BuildContext context,
    required List<SquidTokenInfo> tokens,
    required ValueChanged<SquidTokenInfo> onTokenSelected,
    String title = "Select Token",
  }) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: title,
      children: [
        TokenSelectorDrawer(
          tokens: tokens,
          onTokenSelected: onTokenSelected,
          title: title,
        ),
      ],
    );
  }

  @override
  State<TokenSelectorDrawer> createState() => _TokenSelectorDrawerState();
}

class _TokenSelectorDrawerState extends State<TokenSelectorDrawer> {
  String _query = '';

  @override
  @override
  Widget build(BuildContext context) {
    final lowerQuery = _query.toLowerCase();

    // Always filter first
    final filtered = widget.tokens
        .where((token) {
          return token.symbol.toLowerCase().contains(lowerQuery) ||
              token.name.toLowerCase().contains(lowerQuery);
        })
        .take(30)
        .toList(); // Always limit to top 20 after filtering

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (val) => setState(() => _query = val),
          style: TextStyle(color: GeniusWalletColors.textPrimary),
          decoration: InputDecoration(
            hintText: "Search Tokens...",
            hintStyle: TextStyle(color: GeniusWalletColors.textPrimary54),
            prefixIcon:
                Icon(Icons.search, color: GeniusWalletColors.textPrimary54),
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        if (filtered.isEmpty && _query.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: GeniusWalletConsts.space16),
            child: Text('No tokens found',
                style: TextStyle(color: GeniusWalletColors.textPrimary70)),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final token = filtered[index];
            return Card(
              color: GeniusWalletColors.deepBlueCardColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: GeniusWalletColors.borderSubtle, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space8,
                    vertical: GeniusWalletConsts.space2),
                leading: ClipOval(
                  child: Image.network(
                    token.logoURI,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    semanticLabel: token.name,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 36,
                        height: 36,
                        color: Colors.grey[700],
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image,
                            color: GeniusWalletColors.textPrimary70, size: 16),
                      );
                    },
                  ),
                ),
                title: Text(token.name,
                    style: TextStyle(color: GeniusWalletColors.textPrimary)),
                subtitle: Row(children: [
                  if (token.balance != null)
                    Text('${token.balance!.formattedBalance} ',
                        style:
                            const TextStyle(color: GeniusWalletColors.gray500)),
                  Text(token.symbol,
                      style: const TextStyle(color: GeniusWalletColors.gray500))
                ]),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onTokenSelected(token);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
