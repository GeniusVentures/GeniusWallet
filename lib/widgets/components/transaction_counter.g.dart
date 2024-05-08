import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_counter_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionCounter extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTransactions;
  final String? ovr2345;
  const TransactionCounter(
    this.constraints, {
    Key? key,
    this.ovrTransactions,
    this.ovr2345,
  }) : super(key: key);
  @override
  _TransactionCounter createState() => _TransactionCounter();
}

class _TransactionCounter extends State<TransactionCounter> {
  _TransactionCounter();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: TransactionCounterCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth,
            top: 0,
            height: widget.constraints.maxHeight,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 109.0,
                top: 0,
                height: 40.0,
                child: Container(
                    height: 40.0,
                    width: 109.0,
                    child: AutoSizeText(
                      widget.ovr2345 ?? '2,345 ',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
