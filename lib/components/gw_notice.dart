import 'package:flutter/material.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A centred title, message and stacked actions, for a screen that has nothing
/// to show but a state. [busy] adds the spinner above the title.
class GWNotice extends StatelessWidget {
  const GWNotice({
    super.key,
    required this.title,
    required this.message,
    this.busy = false,
    this.actions = const [],
  });

  final String title;
  final String message;
  final bool busy;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GeniusWalletConsts.space12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy) ...[
                const Loading(),
                const SizedBox(height: GeniusWalletConsts.space8),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.titleLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              for (final action in actions) ...[
                const SizedBox(height: GeniusWalletConsts.space6),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
