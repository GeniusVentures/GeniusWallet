import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class SubmitJobDashboardButton extends StatelessWidget {
  final String walletAddress;
  final String gnusConnectedWalletAddress;
  final WalletDetailsCubit walletDetailsCubit;
  final Function()? onPressed;

  const SubmitJobDashboardButton({
    Key? key,
    required this.walletAddress,
    required this.gnusConnectedWalletAddress,
    required this.walletDetailsCubit,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelectedWalletLinkedToSGNUS =
        walletAddress == gnusConnectedWalletAddress;

    if (!isSelectedWalletLinkedToSGNUS) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 36,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: GeniusWalletColors.deepBlueCardColor,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          onPressed?.call();
          await context.push('/submit_job');
          walletDetailsCubit.getCoins(); // Refresh after returning
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.create,
                size: 16, color: GeniusWalletColors.brandGreen),
            const SizedBox(width: 6),
            Text(
              'Create Processing Job',
              style: GeniusWalletTypography.bodySm
                  .copyWith(color: GeniusWalletColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
