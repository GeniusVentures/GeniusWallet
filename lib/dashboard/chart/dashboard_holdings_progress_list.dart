import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class DashboardHoldingsProgressList extends StatelessWidget {
  final Map<String, double> holdings;

  const DashboardHoldingsProgressList({Key? key, required this.holdings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final processedHoldings = _processHoldings(holdings);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(top: GeniusWalletConsts.space6),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: processedHoldings.length,
        separatorBuilder: (_, __) => const Divider(
          color: Colors.transparent,
          height: 24,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final entry = processedHoldings[index];
          return HoldingProgressItem(
            label: entry.key,
            percentage: entry.value,
          );
        },
      ),
    );
  }

  /// Groups holdings: top 5 + "Other"
  List<MapEntry<String, double>> _processHoldings(
      Map<String, double> holdings) {
    final sortedEntries = holdings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topHoldings = sortedEntries.take(5).toList();
    final otherTotal =
        sortedEntries.skip(5).fold(0.0, (sum, entry) => sum + entry.value);

    if (otherTotal > 0) {
      topHoldings.add(MapEntry('Other', otherTotal));
    }

    return topHoldings;
  }
}

class HoldingProgressItem extends StatelessWidget {
  final String label;
  final double percentage;

  const HoldingProgressItem({
    Key? key,
    required this.label,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circular progress indicator
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 2,
                // Themeable track: gray800 was a fixed dark tone that vanished
                // on the light canvas; textPrimary12 stays a subtle ring in
                // both appearances.
                valueColor: AlwaysStoppedAnimation<Color>(
                    GeniusWalletColors.textPrimary12),
              ),
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    GeniusWalletColors.lightGreenPrimary),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),

        const SizedBox(width: GeniusWalletConsts.space8),

        // Percentage Text
        SizedBox(
          width: 50,
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: GeniusWalletColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Coin label
        Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: AutoSizeText(
                  label,
                  maxLines: 1,
                  style: GeniusWalletTypography.bodyMd.copyWith(
                    color: GeniusWalletColors.textPrimary,
                  ),
                ))),
      ],
    );
  }
}
