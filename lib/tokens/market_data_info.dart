import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:intl/intl.dart';

class MarketDataInfo extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;
  final Widget? topSlot;
  final String? aboutText;

  const MarketDataInfo({
    Key? key,
    this.marketData,
    this.network,
    this.address,
    this.topSlot,
    this.aboutText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build rows for ListView
    final infoTiles = <Widget>[
      // Network row (with icon)
      if (network != null)
        ListTile(
          dense: true,
          leading: const Icon(
            Icons.bubble_chart,
            color: GeniusWalletColors.lightGreenPrimary,
            size: 20,
          ),
          title: Text("Network",
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.gray500)),
          trailing: Text(
            network ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GeniusWalletColors.textPrimary,
            ),
          ),
        ),
      // Address row (with icon + copy)
      if (address != null)
        ListTile(
          dense: true,
          leading: const Icon(
            Icons.link,
            color: GeniusWalletColors.lightGreenPrimary,
            size: 20,
          ),
          title: Text("Address",
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.gray500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                address!.length > 12
                    ? "${address!.substring(0, 6)}...${address!.substring(address!.length - 6)}"
                    : address!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GeniusWalletColors.textPrimary,
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              GestureDetector(
                onTap: () => _copyToClipboard(context, address!),
                child: const Icon(
                  Icons.copy,
                  size: 18,
                  color: GeniusWalletColors.lightGreenPrimary,
                ),
              ),
            ],
          ),
        ),
      // Market Cap
      ListTile(
        dense: true,
        leading: Icon(Icons.pie_chart, color: Colors.amber[200], size: 20),
        title: Text("Market Cap",
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactCurrency(marketData?.marketCap),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GeniusWalletColors.textPrimary,
          ),
        ),
      ),
      // Circulating Supply
      ListTile(
        dense: true,
        leading: Icon(Icons.sync, color: Colors.lightBlue[200], size: 20),
        title: Text("Circulating Supply",
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactDecimal(marketData?.circulatingSupply),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GeniusWalletColors.textPrimary,
          ),
        ),
      ),
      // Total Supply
      ListTile(
        dense: true,
        leading: Icon(Icons.storage, color: Colors.orange[200], size: 20),
        title: Text("Total Supply",
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactDecimal(marketData?.totalSupply),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GeniusWalletColors.textPrimary,
          ),
        ),
      ),
      // Volume
      ListTile(
        dense: true,
        leading: const Icon(Icons.bar_chart,
            color: GeniusWalletColors.mutedRed, size: 20),
        title: Text("Volume",
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactCurrency(marketData?.totalVolume),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GeniusWalletColors.textPrimary,
          ),
        ),
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // center if possible
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
          child: Text(
            "Info",
            style: TextStyle(
              fontSize: 18,
              color: GeniusWalletColors.gray500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Card with ListTile and info
        Card(
          color: GeniusWalletColors.deepBlueCardColor,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top ListTile (icon, name, symbol)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space8,
                    vertical: GeniusWalletConsts.space6),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: GeniusWalletColors.textPrimary,
                  backgroundImage: marketData?.imageUrl != null
                      ? NetworkImage(marketData!.imageUrl)
                      : null,
                  child: marketData?.imageUrl == null
                      ? const Icon(Icons.token,
                          color: GeniusWalletColors.gray500, size: 32)
                      : null,
                ),
                title: Text(
                  marketData?.name ?? "Unknown Token",
                  maxLines: 2,
                  style: const TextStyle(
                    color: GeniusWalletColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  (marketData?.symbol ?? "").toUpperCase(),
                  style: GeniusWalletTypography.bodyMd
                      .copyWith(color: GeniusWalletColors.gray500),
                ),
              ),
              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 1,
                color: GeniusWalletColors.deepBlueTertiary,
              ),
              Column(
                children: [
                  for (int i = 0; i < infoTiles.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 10),
                        child: Divider(
                          height: 1,
                          color: GeniusWalletColors.deepBlue,
                        ),
                      ),
                    infoTiles[i],
                  ]
                ],
              ),

              if (aboutText != null && aboutText!.isNotEmpty) ...[
                const Divider(color: GeniusWalletColors.deepBlue, height: 1),
                ExpansionTile(
                  title: Text(
                    "About",
                    style: GeniusWalletTypography.titleMd
                        .copyWith(color: GeniusWalletColors.gray500),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: GeniusWalletConsts.space8,
                          vertical: GeniusWalletConsts.space6),
                      child: Text(
                        aboutText!,
                        style: GeniusWalletTypography.bodyMd
                            .copyWith(color: GeniusWalletColors.textPrimary70),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        )
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showAppSnackBar(context, 'Address copied to clipboard');
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
