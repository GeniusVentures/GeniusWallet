import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/widgets/components/sgnus/sgnus_connection_widget.dart';
import 'package:intl/intl.dart';

class WalletsOverview extends StatefulWidget {
  final String totalBalance;
  final String numberOfWallets;
  final String numberOfTransactions;
  final Account? account;
  final GeniusApi geniusApi;
  const WalletsOverview(
      {Key? key,
      required this.totalBalance,
      required this.numberOfWallets,
      required this.numberOfTransactions,
      required this.geniusApi,
      required this.account})
      : super(key: key);
  @override
  WalletsOverviewState createState() => WalletsOverviewState();
}

class WalletsOverviewState extends State<WalletsOverview> {
  WalletsOverviewState();
  late Future<String?> futurePrices;

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
          coinIds:
              'ethereum', // these ids are mapped from the coingecko list in assets/json/coins_list
          coinBalances: [
            CoinBalance(
                coinId: 'ethereum', balance: double.parse(widget.totalBalance)),
          ],
          geniusApi: widget.geniusApi);
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
              child: AutoSizeText(widget.numberOfTransactions,
                  textScaleFactor: 1,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      overflow: TextOverflow.ellipsis))),
          const Flexible(
              child: AutoSizeText('Transactions',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12)))
        ])),
        Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          AutoSizeText(widget.numberOfWallets,
              textScaleFactor: 1,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          const AutoSizeText('Wallets',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: Colors.white, fontSize: 12))
        ]))
      ]),
      Row(children: [
        Flexible(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(
                child: AutoSizeText('Current Balance',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 12))),
            Flexible(
                child: FutureBuilder<String?>(
              future: futurePrices,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: AutoSizeText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // fallback to stale account balance if call fails
                                snapshot.data != ""
                                    ? snapshot.data ??
                                        "\$${NumberFormat('#,##0.00').format(widget.account?.balance)}"
                                    : "\$${NumberFormat('#,##0.00').format(widget.account?.balance)}",
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left)),
                        const SizedBox(width: 4),
                      ]);
                }
                return const SizedBox();
              },
            )),
          ],
        ))
      ]),
      const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Flexible(child: SGNUSConnectionWidget())])
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
