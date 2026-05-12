import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class DashboardChart extends StatelessWidget {
  final String coinGeckoCoinId;
  final String tokenDecimals;
  final String tokenSymbol;
  final String? title;

  const DashboardChart({
    super.key,
    required this.coinGeckoCoinId,
    required this.tokenDecimals,
    required this.tokenSymbol,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool is3Column = screenWidth > GeniusBreakpoints.tablet;

    final double chartHeight = is3Column
        ? screenHeight * 0.20 // desktop height
        : screenHeight * 0.14; // mobile height
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Center(
              child: AutoSizeText(
            title!,
            maxLines: 1,
            style: const TextStyle(
              fontSize: GeniusWalletFontSize.sectionHeader,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          )),
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
