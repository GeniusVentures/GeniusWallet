import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

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
      child: ListView(
        children: [
          TokenSelectorDrawer(
            tokens: tokens,
            onTokenSelected: onTokenSelected,
            title: title,
          ),
        ],
      ),
    );
  }

  @override
  State<TokenSelectorDrawer> createState() => _TokenSelectorDrawerState();
}

class _TokenSelectorDrawerState extends State<TokenSelectorDrawer> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
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
          style: TextStyle(color: gw.textPrimary),
          decoration: InputDecoration(
            hintText: "Search Tokens...",
            hintStyle: TextStyle(color: gw.textSecondary),
            prefixIcon: Icon(Icons.search, color: gw.textSecondary),
            filled: true,
            fillColor: gw.surfaceMenu,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final token = filtered[index];
            return Container(
              decoration: BoxDecoration(
                color: gw.surfaceMenu,
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radiusMd,
                ),
              ),
              margin: const EdgeInsets.only(
                bottom: GeniusWalletConsts.space4,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: ClipOval(
                  child: Image.network(
                    token.logoURI,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 36,
                        height: 36,
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
                title: Text(token.name, style: TextStyle(color: gw.textPrimary)),
                subtitle: Row(
                  children: [
                    if (token.balance != null)
                      Text(
                        '${token.balance!.formattedBalance} ',
                        style: TextStyle(color: gw.textSecondary),
                      ),
                    Text(token.symbol, style: TextStyle(color: gw.textSecondary)),
                  ],
                ),
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
