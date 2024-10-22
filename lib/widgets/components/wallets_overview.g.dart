import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/coin_gecko/coin_gecko_api.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/buy_button_custom.dart';

class WalletsOverview extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCurrentbalance;
  final String? ovrPercentChange;
  final String? ovrCurrencyChange;
  final String? ovrTotalWalletBalance;
  final String? ovrBalancecurrency;
  final String? ovrWalletCounter;
  final String? ovrWallets;
  final String? ovrTransactions;
  final String? ovrTransactionCounter;
  final String? ovrbuy;
  final Account? account;
  final GeniusApi geniusApi;
  const WalletsOverview(this.constraints,
      {Key? key,
      this.ovrCurrentbalance,
      this.ovrPercentChange,
      this.ovrCurrencyChange,
      this.ovrTotalWalletBalance,
      this.ovrBalancecurrency,
      this.ovrWalletCounter,
      this.ovrWallets,
      this.ovrTransactions,
      this.ovrTransactionCounter,
      this.ovrbuy,
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
                coinId: 'ethereum',
                balance: double.parse(widget.ovrTotalWalletBalance ?? '0'))
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
    return SizedBox(
        child: Stack(children: [
      Positioned(
        left: 0,
        width: widget.constraints.maxWidth * 1.0,
        top: 0,
        height: widget.constraints.maxHeight * 1.0,
        child: Stack(children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              height: widget.constraints.maxHeight * 1.0,
              width: widget.constraints.maxWidth * 1.0,
              decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard)),
              ),
            ),
          ),
          Positioned(
            left: 18.0,
            width: 144.0,
            bottom: 139.0,
            height: 14.0,
            child: SizedBox(
                height: 14.0,
                width: 144.0,
                child: AutoSizeText(
                  widget.ovrCurrentbalance ?? 'Current balance',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            left: 110.0,
            width: 62.0,
            bottom: 31.0,
            height: 14.0,
            child: SizedBox(
                height: 14.0,
                width: 62.0,
                child: AutoSizeText(
                  widget.ovrPercentChange ?? '+12%',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.30000001192092896,
                    color: Color(0xff0068ef),
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            left: 19.0,
            width: 104.0,
            bottom: 31.0,
            height: 14.0,
            child: SizedBox(
                height: 14.0,
                width: 104.0,
                child: AutoSizeText(
                  widget.ovrCurrencyChange ?? '2.7995  EUR',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
              left: 19.0,
              bottom: 90,
              child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SizedBox(
                      child: FutureBuilder<String?>(
                        future: futurePrices,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return AutoSizeText(
                                // fallback to stale account balance if call fails
                                snapshot.data ??
                                    "\$ ${widget.account?.balance?.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3272727131843567,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left);
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    AutoSizeText(widget.ovrTotalWalletBalance ?? ""),
                    AutoSizeText(
                      widget.ovrBalancecurrency ?? 'USD',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25714290142059326,
                        color: GeniusWalletColors.gray500,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ])),
          Positioned(
            right: 20.0,
            width: 65.0,
            top: 29.0,
            height: 76.0,
            child: SizedBox(
                child: Stack(children: [
              Positioned(
                left: 10.0,
                width: 45.0,
                top: 49.0,
                height: 15.0,
                child: SizedBox(
                    height: 15.0,
                    width: 45.0,
                    child: AutoSizeText(
                      widget.ovrWallets ?? 'Wallets',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
              Positioned(
                left: 22.0,
                width: 20.0,
                top: 6.0,
                height: 40.0,
                child: SizedBox(
                    height: 40.0,
                    width: 20.0,
                    child: AutoSizeText(
                      widget.ovrWalletCounter ?? '5 ',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 34.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ])),
          ),
          Positioned(
            left: 20.0,
            width: 103.0,
            top: 78.0,
            height: 14.0,
            child: SizedBox(
                height: 14.0,
                width: 103.0,
                child: AutoSizeText(
                  widget.ovrTransactions ?? 'Transactions',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            left: 20.0,
            width: 84.0,
            top: 34.0,
            height: 40.0,
            child: SizedBox(
                height: 40.0,
                width: 84.0,
                child: AutoSizeText(
                  widget.ovrTransactionCounter ?? '2,345 ',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 30.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            right: 20.0,
            width: 140.0,
            bottom: 27.0,
            height: 40.0,
            child: BuyButtonCustom(
                child: SizedBox(
                    child: Stack(children: [
              Positioned(
                left: 0,
                width: 140,
                top: 0,
                height: 40.0,
                child: Container(
                  height: 40.0,
                  width: 140.0,
                  decoration: const BoxDecoration(
                    color: GeniusWalletColors.lightGreenPrimary,
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusButton)),
                  ),
                ),
              ),
              Positioned(
                  left: 0,
                  width: 140.0,
                  top: 10.0,
                  height: 40.0,
                  child: AutoSizeText(
                    widget.ovrbuy ?? 'Buy ',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.30000001192092896,
                      color: GeniusWalletColors.deepBlueCardColor,
                    ),
                    textAlign: TextAlign.center,
                  )),
            ]))),
          ),
        ]),
      ),
    ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
