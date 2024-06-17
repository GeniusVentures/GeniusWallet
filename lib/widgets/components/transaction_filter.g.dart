import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_filter_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionFilter extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrALL;
  final String? ovrSEND;
  final String? ovrRECENT;
  const TransactionFilter(
    this.constraints, {
    Key? key,
    this.ovrALL,
    this.ovrSEND,
    this.ovrRECENT,
  }) : super(key: key);
  @override
  _TransactionFilter createState() => _TransactionFilter();
}

class _TransactionFilter extends State<TransactionFilter> {
  _TransactionFilter();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: TransactionFilterCustom(
            child: Wrap(spacing: 5, children: [
          Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: const BoxDecoration(
                  color: GeniusWalletColors.grayPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: AutoSizeText(
                widget.ovrALL ?? 'All',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              )),
          Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: const BoxDecoration(
                  color: GeniusWalletColors.grayPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: AutoSizeText(
                widget.ovrSEND ?? 'Sent',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Color(0xff606166),
                ),
                textAlign: TextAlign.center,
              )),
          Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: const BoxDecoration(
                  color: GeniusWalletColors.grayPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: AutoSizeText(
                widget.ovrRECENT ?? 'Recent',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Color(0xff606166),
                ),
                textAlign: TextAlign.center,
              )),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
