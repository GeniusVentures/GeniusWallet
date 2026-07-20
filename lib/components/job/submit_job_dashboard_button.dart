import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class SubmitJobDashboardButton extends StatelessWidget {
  final String walletAddress;
  final String gnusConnectedWalletAddress;
  final WalletDetailsCubit walletDetailsCubit;
  final Function()? onPressed;

  const SubmitJobDashboardButton({
    super.key,
    required this.walletAddress,
    required this.gnusConnectedWalletAddress,
    required this.walletDetailsCubit,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelectedWalletLinkedToSGNUS =
        walletAddress == gnusConnectedWalletAddress;

    if (!isSelectedWalletLinkedToSGNUS) {
      return const SizedBox.shrink();
    }

    return GWButton(
      variant: GWButtonVariant.primary,
      size: GWButtonSize.md,
      label: 'Create Processing Job',
      leading: const Icon(Icons.create),
      onPressed: () async {
        onPressed?.call();
        await context.push('/submit_job');
        walletDetailsCubit.getCoins(); // Refresh after returning
      },
    );
  }
}
