// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/transaction_card.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';
import 'package:genius_wallet/widgets/components/custom/transactions_preview_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/view_more_custom.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_filter_custom.dart';

class Transactions extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrTransactionCard;
  final String? ovrTransactions;
  final String? ovrViewmore;
  const Transactions(
    this.constraints, {
    Key? key,
    this.ovrTransactionCard,
    this.ovrTransactions,
    this.ovrViewmore,
  }) : super(key: key);
  @override
  _Transactions createState() => _Transactions();
}

class _Transactions extends State<Transactions> {
  _Transactions();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          left: 0,
          width: widget.constraints.maxWidth * 1.0,
          top: 0,
          height: widget.constraints.maxHeight * 1.0,
          child: Stack(children: [
            Positioned(
              left: 0,
              width: widget.constraints.maxWidth * 1.0,
              top: 0,
              height: widget.constraints.maxHeight * 1.0,
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
              left: 0,
              width: widget.constraints.maxWidth,
              top: 67.0,
              height: 236.0,
              child: TransactionsPreviewCustom(
                  child: Stack(children: [
                Positioned(
                  left: 0,
                  width: 271.0,
                  top: 160.0,
                  height: 53.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return TransactionCard(
                      constraints,
                      ovrTimestamp: '16:23, 12 dec 2018',
                      ovrTransactionID: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                      ovrTransactionQuantity: '0.009 BTC',
                    );
                  }),
                ),
                Positioned(
                  left: 0,
                  width: 271.0,
                  top: 0,
                  height: 53.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return TransactionCard(
                      constraints,
                      ovrTimestamp: '16:23, 12 dec 2018',
                      ovrTransactionID: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                      ovrTransactionQuantity: '0.009 BTC',
                    );
                  }),
                ),
                Positioned(
                  left: 0,
                  width: 271.0,
                  top: 80.0,
                  height: 53.0,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return TransactionCard(
                      constraints,
                      ovrTimestamp: '16:23, 12 dec 2018',
                      ovrTransactionID: '1PRj85hu9RXPZTzxtko9stfs6nRo1vyrQB',
                      ovrTransactionQuantity: '0.009 BTC',
                    );
                  }),
                ),
              ])),
            ),
            Positioned(
              left: 19.0,
              top: 25.0,
              child: AutoSizeText(
                widget.ovrTransactions ?? 'Transactions',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              right: 19.0,
              width: 85.0,
              bottom: 19.0,
              height: 23.0,
              child: ViewMoreCustom(
                  child: Container(
                      decoration: const BoxDecoration(
                          color: GeniusWalletColors.gray800,
                          borderRadius: BorderRadius.all(Radius.circular(
                              GeniusWalletConsts.borderRadiusButton))),
                      child: Stack(children: [
                        Positioned(
                          left: 5.0,
                          width: 75.0,
                          top: 5.0,
                          height: 14.0,
                          child: AutoSizeText(
                            widget.ovrViewmore ?? 'View All',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]))),
            ),
            Positioned(
              right: 20.0,
              width: 150.0,
              top: 28.0,
              height: 13.0,
              child: TransactionFilterCustom(
                  child: LayoutBuilder(builder: (context, constraints) {
                return TransactionFilter(
                  constraints,
                  ovrALL: 'ALL',
                  ovrSEND: 'SEND',
                  ovrRECENT: 'RECENT',
                );
              })),
            ),
          ])),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
