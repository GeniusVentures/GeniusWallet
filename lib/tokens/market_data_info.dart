import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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
          title: const Text("Network",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: GeniusWalletColors.gray500)),
          trailing: Text(
            network ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
          title: const Text("Address",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: GeniusWalletColors.gray500)),
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
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
        title: const Text("Market Cap",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactCurrency(marketData?.marketCap),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      // Circulating Supply
      ListTile(
        dense: true,
        leading: Icon(Icons.sync, color: Colors.lightBlue[200], size: 20),
        title: const Text("Circulating Supply",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactDecimal(marketData?.circulatingSupply),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      // Total Supply
      ListTile(
        dense: true,
        leading: Icon(Icons.storage, color: Colors.orange[200], size: 20),
        title: const Text("Total Supply",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactDecimal(marketData?.totalSupply),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      // Volume
      ListTile(
        dense: true,
        leading: Icon(Icons.bar_chart, color: Colors.red[200], size: 20),
        title: const Text("Volume",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: GeniusWalletColors.gray500)),
        trailing: Text(
          _formatCompactCurrency(marketData?.totalVolume),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          padding: EdgeInsets.symmetric(vertical: 8),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  (marketData?.symbol ?? "").toUpperCase(),
                  style: const TextStyle(
                    color: GeniusWalletColors.gray500,
                    fontSize: 14,
                  ),
                ),
              ),
              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 1,
                color: GeniusWalletColors.deepBlueTertiary,
              ),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: infoTiles.length,
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(left: 50.0, right: 10),
                  child: Divider(
                    height: 1,
                    color: GeniusWalletColors.deepBlue,
                  ),
                ),
                itemBuilder: (context, index) => infoTiles[index],
              ),
              if (aboutText != null && aboutText!.isNotEmpty) ...[
                const Divider(color: GeniusWalletColors.deepBlue, height: 1),
                ExpansionTile(
                  title: const Text(
                    "About",
                    style: TextStyle(
                        fontSize: 16,
                        color: GeniusWalletColors.gray500,
                        fontWeight: FontWeight.w500),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        aboutText!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
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
