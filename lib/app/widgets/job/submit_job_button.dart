import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class SubmitJobButton extends StatefulWidget {
  const SubmitJobButton({
    Key? key,
  }) : super(key: key);

  @override
  SubmitJobButtonState createState() => SubmitJobButtonState();
}

class SubmitJobButtonState extends State<SubmitJobButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
            builder: (context, state) {
          final connection = snapshot.data;
          final isDisabled = connection == null || !connection.isConnected;
          final walletCubit = context.read<WalletDetailsCubit>();
          final isSelectedWalletLinkedToSGNUS =
              state.selectedWallet?.address == connection?.walletAddress;

          if (!isSelectedWalletLinkedToSGNUS) {
            return const SizedBox.shrink();
          }

          return TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    side: BorderSide(
                        width: 1, color: GeniusWalletColors.deepBlue))),
            onPressed: isDisabled
                ? null
                : () async {
                    await context.push('/submit_job', extra: walletCubit);
                    // after we come back to the wallet details screen reload coins / balance
                    walletCubit.getCoins();
                    walletCubit.getWalletBalance();
                  },
            child: const AutoSizeText('Submit Job'),
          );
        });
      },
    );
  }
}
