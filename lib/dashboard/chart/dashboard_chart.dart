import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';

class DashboardChart extends StatelessWidget {
  final String coinGeckoCoinId;
  final String tokenDecimals;
  final String tokenSymbol;
  final String? title;

  const DashboardChart({
    Key? key,
    required this.coinGeckoCoinId,
    required this.tokenDecimals,
    required this.tokenSymbol,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool is3Column = screenWidth > 1150; // Adjust breakpoint if needed

    final double chartHeight = is3Column
        ? screenHeight * 0.20 // desktop height
        : screenHeight * 0.14; // mobile height
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          const SizedBox(height: 16),
          AutoSizeText(
            title!,
            maxLines: 1,
            style: const TextStyle(
              fontSize: GeniusWalletFontSize.sectionHeader,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
        ],
        CryptoLiveChart(
          coinGeckoCoinId: coinGeckoCoinId,
          chartHeight: chartHeight,
          priceHeight: 28,
          tokenSymbol: tokenSymbol,
        ),
      ],
    ));
  }
}
