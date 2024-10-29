import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';
import 'package:genius_api/coin_gecko/coin_gecko_api.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/buy_button_custom.dart';

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
  _WalletsOverview createState() => _WalletsOverview();
}

class _WalletsOverview extends State<WalletsOverview> {
  _WalletsOverview();
  late Future<String?> futurePrices;

  @override
  void initState() {
    super.initState();

    // only fetch every x mins from the last fetch to ensure rate limiting doesn't occur
    const fetchDelay = 3;
    final completer = Completer<String>();

    DateTime nowDate = DateTime.now();
    DateTime retrievalDate =
        widget.account?.lastBalanceRetrievalDate ?? nowDate;

    Duration difference = nowDate.difference(retrievalDate);

    int differenceInMinutes = difference.inMinutes;

    final isFetchAllowed =
        differenceInMinutes >= fetchDelay || nowDate == retrievalDate;

    // fetch prices if last fetch < x mins or there is no previous fetch
    if (isFetchAllowed) {
      futurePrices = fetchCoinPricesSum(
          coinIds: 'ethereum',
          coinBalances: [
            CoinBalance(
                coinId: 'ethereum', balance: double.parse(widget.totalBalance))
          ],
          geniusApi: widget.geniusApi);
      return;
    }

    // if we can't fetch (rate limit) just return the account balance (stale)
    completer.complete("\$ ${widget.account?.balance?.toStringAsFixed(2)}");

    futurePrices = completer.future;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Expanded(
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                children: [
              Text(widget.numberOfTransactions,
                  style: const TextStyle(color: Colors.white, fontSize: 34)),
              const Text('Transactions',
                  style: TextStyle(color: Colors.white, fontSize: 12))
            ])),
        Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            children: [
              Text(widget.numberOfWallets,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700)),
              const Text('Wallets',
                  style: TextStyle(color: Colors.white, fontSize: 12))
            ])
      ]),
      Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Balance',
                style: TextStyle(color: Colors.white, fontSize: 12)),
            FutureBuilder<String?>(
              future: futurePrices,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        AutoSizeText(
                            // fallback to stale account balance if call fails
                            snapshot.data ??
                                "\$ ${widget.account?.balance?.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 48.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left),
                        const SizedBox(width: 4),
                        const AutoSizeText('USD')
                      ]);
                }
                return const SizedBox();
              },
            ),
          ],
        )
      ]),
      Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [BuyButtonCustom(child: const Text('Buy'))])
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
