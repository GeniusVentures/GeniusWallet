import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/job/submit_job_dashboard_button.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:genius_wallet/components/sgnus/sgnus_connection_widget.dart';
import 'package:intl/intl.dart';

class WalletsOverview extends StatefulWidget {
  final Account? account;
  final GeniusApi geniusApi;
  const WalletsOverview(
      {super.key, required this.geniusApi, required this.account});
  @override
  WalletsOverviewState createState() => WalletsOverviewState();
}

class WalletsOverviewState extends State<WalletsOverview> {
  WalletsOverviewState();
  late Future<String?> futurePrices;
  bool useMinions = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'Current Balance',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          if (state.selectedWallet == null) {
            return Text('No wallet selected');
          }

          if (state.selectedWallet?.walletType == WalletType.sgnus) {
            return Column(
              children: [
                GeniusBalanceDisplay(useMinions: useMinions),
                _buildToggle(),
              ],
            );
          }

          final balance =
              double.tryParse(state.selectedWalletBalance ?? '0') ?? 0;

          if (balance == 0) {
            return Text(
              'No funds available',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            );
          }

          final displayBalance = balance == 0
              ? "\$0.00"
              : NumberFormat.simpleCurrency().format(balance);

          return Text(
            displayBalance,
            style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.w500),
            textAlign: TextAlign.left,
          );
        },
      ),
      SizedBox(height: 20),
      SGNUSConnectionWidget(),
      SGNUSConnectionStatusWidget(),
      BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
          builder: (context, state) {
        if (state.selectedWallet != null) {
          return StreamBuilder<SGNUSConnection>(
              stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
              builder: (context, snapshot) {
                final connection = snapshot.data;
                return SubmitJobDashboardButton(
                  walletDetailsCubit: context.read<WalletDetailsCubit>(),
                  walletAddress: state.selectedWallet!.address,
                  gnusConnectedWalletAddress: connection?.walletAddress ?? "",
                );
              });
        } else {
          return const SizedBox.shrink();
        }
      })
    ]);
  }

  Widget _buildToggle() {
    return ToggleButtons(
      isSelected: [!useMinions, useMinions],
      onPressed: (index) {
        setState(() {
          useMinions = index == 1;
        });
      },
      constraints: const BoxConstraints(minHeight: 36, minWidth: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Image.asset("assets/images/crypto/gnus.png", height: 20, width: 20),
            const Text("GNUS", style: TextStyle(fontSize: 13)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Image.asset("assets/images/crypto/minion.png",
                height: 20, width: 20),
            const Text("Minions", style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
