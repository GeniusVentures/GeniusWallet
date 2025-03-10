import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:intl/intl.dart';

class MarketDataInfo extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;
  final Widget? topSlot;

  const MarketDataInfo(
      {Key? key, this.marketData, this.network, this.address, this.topSlot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **Title Outside the Table**
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: AutoSizeText(
            "Info",
            maxLines: 1,
            style: TextStyle(
              fontSize: 18,
              color: GeniusWalletColors.gray500,
            ),
          ),
        ),

        // **Market Data Card**
        Card(
          color: GeniusWalletColors.deepBlueCardColor,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              if (topSlot != null) ...[
                topSlot!,
                Container(
                  height: 2,
                  color: GeniusWalletColors.deepBlueTertiary,
                ),
              ],
              _buildInfoRow("Symbol", marketData?.symbol.toUpperCase()),
              if (network != null) _buildInfoRow("Network", network),
              if (address != null)
                _buildCopyableRow(context, "Address", address!),
              _buildInfoRow(
                  "Market Cap", _formatCompactCurrency(marketData?.marketCap)),
              _buildInfoRow("Circulating Supply",
                  _formatCompactDecimal(marketData?.circulatingSupply)),
              _buildInfoRow("Total Supply",
                  _formatCompactDecimal(marketData?.totalSupply)),
              _buildInfoRow(
                  "Volume", _formatCompactCurrency(marketData?.totalVolume)),
            ],
          ),
        ),
      ],
    );
  }

  /// **Builds a Row for Market Data with a 1px Separator**
  Widget _buildInfoRow(String label, String? value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: AutoSizeText(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  color: GeniusWalletColors.gray500,
                ),
              )),
              Flexible(
                  child: AutoSizeText(
                value ?? "",
                maxLines: 1,
                minFontSize: 12,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              )),
            ],
          ),
        ),
        Container(
          height: 2,
          color: GeniusWalletColors.deepBlueTertiary,
        ),
      ],
    );
  }

  /// **Builds a Row with a Copyable Address**
  Widget _buildCopyableRow(BuildContext context, String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  color: GeniusWalletColors.gray500,
                ),
              ),
              Flexible(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      child: AutoSizeText(
                    value.length > 10
                        ? "${value.substring(0, 6)}...${value.substring(value.length - 6)}"
                        : value,
                    maxLines: 1,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  )),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _copyToClipboard(context, value),
                    child: const Icon(
                      Icons.copy,
                      size: 16,
                      color: GeniusWalletColors.lightGreenPrimary,
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        Container(
          height: 2,
          color: GeniusWalletColors.deepBlueTertiary,
        ),
      ],
    );
  }

  /// **Copies the Address to Clipboard**
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
