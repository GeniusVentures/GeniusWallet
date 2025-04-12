import 'package:flutter/material.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer_button.dart';
import 'package:go_router/go_router.dart';

class SubmitJobButton extends StatefulWidget {
  final String walletAddress;
  final String gnusConnectedWalletAddress;
  final WalletDetailsCubit walletDetailsCubit;
  final Function()? onPressed;

  const SubmitJobButton(
      {Key? key,
      required this.walletAddress,
      required this.gnusConnectedWalletAddress,
      required this.walletDetailsCubit,
      this.onPressed})
      : super(key: key);

  @override
  SubmitJobButtonState createState() => SubmitJobButtonState();
}

class SubmitJobButtonState extends State<SubmitJobButton> {
  @override
  Widget build(BuildContext context) {
    final isSelectedWalletLinkedToSGNUS =
        widget.walletAddress == widget.gnusConnectedWalletAddress;

    if (!isSelectedWalletLinkedToSGNUS) {
      return const SizedBox.shrink();
    }

    return SlidingDrawerButton(
      icon: Icons.create,
      label: 'Create a Processing Job',
      onPressed: () async {
        widget.onPressed?.call();
        await context.push('/submit_job', extra: widget.walletDetailsCubit);
        // after we come back to the wallet details screen reload coins / balance
        widget.walletDetailsCubit.getCoins();
      },
    );
  }
}
