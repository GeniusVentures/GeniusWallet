import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

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

    print("Tokens here are ${widget.tokens}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (val) => setState(() => _query = val),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search Tokens...",
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final token = filtered[index];
            return Card(
              color: GeniusWalletColors.deepBlueCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        color: Colors.grey[700],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white70, size: 16),
                      );
                    },
                  ),
                ),
                title: Text(token.name,
                    style: const TextStyle(color: Colors.white)),
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
