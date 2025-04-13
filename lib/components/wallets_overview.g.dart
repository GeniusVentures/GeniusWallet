import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/job/submit_job_dashboard_button.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:genius_wallet/components/sgnus/sgnus_connection_widget.dart';
import 'package:intl/intl.dart';

class WalletsOverview extends StatefulWidget {
  final String totalBalance;
  final Account? account;
  final GeniusApi geniusApi;
  const WalletsOverview(
      {Key? key,
      required this.totalBalance,
      required this.geniusApi,
      required this.account})
      : super(key: key);
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

    // only fetch every x mins from the last fetch to ensure rate limiting doesn't occur
    const fetchDelay = 5;
    final completer = Completer<String>();

    DateTime nowDate = DateTime.now();
    DateTime retrievalDate =
        widget.account?.lastBalanceRetrievalDate ?? nowDate;

    Duration difference = nowDate.difference(retrievalDate);

    int differenceInMinutes = difference.inMinutes;

    final isFetchAllowed =
        differenceInMinutes >= fetchDelay || nowDate == retrievalDate;

    // fetch prices if last fetch < x mins or there is no previous fetch
    // TODO UPDATE THIS LOGIC TO PROVIDE A BETTER CURRENT BALANCE....
    if (isFetchAllowed) {
      futurePrices = fetchCoinPricesSum(
        coinIds: [
          'ethereum'
        ], // these ids are mapped from the coingecko list in assets/json/coins_list
        coinBalances: [
          CoinBalance(
              coinId: 'ethereum', balance: double.parse(widget.totalBalance)),
        ],
        geniusApi: widget.geniusApi,
      );
      return;
    }

    // if we can't fetch (rate limit) just return the account balance (stale)
    completer.complete(
        "\$${NumberFormat('#,##0.00').format(widget.account?.balance)}");

    futurePrices = completer.future;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Flexible(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: AutoSizeText('Current Balance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
                builder: (context, state) {
              if (state.selectedWallet == null) {
                return const Center(child: Text('No wallet selected'));
              }

              if (state.selectedWallet?.walletType == WalletType.sgnus) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GeniusBalanceDisplay(useMinions: useMinions),
                    const SizedBox(height: 8),
                    _buildToggle(),
                  ],
                );
              }

              final balance =
                  double.tryParse(state.selectedWalletBalance ?? '0') ?? 0;

              final displayBalance = balance == 0
                  ? "\$0.00"
                  : NumberFormat.simpleCurrency().format(balance);

              return Flexible(
                child: AutoSizeText(
                  displayBalance,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              );
            }),
          ],
        ))
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Row(children: [Flexible(child: SGNUSConnectionWidget())]),
        BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
            builder: (context, state) {
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
        }),
      ])
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
      borderRadius: BorderRadius.circular(12),
      borderColor: Colors.white24,
      selectedBorderColor: Colors.white,
      fillColor: Colors.white10,
      selectedColor: Colors.white,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/crypto/gnus.png", height: 20, width: 20),
            const SizedBox(width: 6),
            const Text("GNUS", style: TextStyle(fontSize: 13)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/crypto/minion.png",
                height: 20, width: 20),
            const SizedBox(width: 6),
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
