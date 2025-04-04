import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionDetailTile extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrLeftfield;
  final String? ovrAmount;
  const TransactionDetailTile(
    this.constraints, {
    Key? key,
    this.ovrLeftfield,
    this.ovrAmount,
  }) : super(key: key);
  @override
  _TransactionDetailTile createState() => _TransactionDetailTile();
}

class _TransactionDetailTile extends State<TransactionDetailTile> {
  _TransactionDetailTile();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      Positioned(
        left: 0,
        width: widget.constraints.maxWidth,
        top: 0,
        height: widget.constraints.maxHeight * 1.0,
        child: Stack(children: [
          Positioned(
            left: 17.0,
            top: 12.0,
            height: 16.0,
            child: Container(
                height: 14.0,
                child: AutoSizeText(
                  widget.ovrLeftfield ?? 'Available Balance',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
          ),
          Positioned(
            right: 13.0,
            top: 12.0,
            height: 14.0,
            child: Container(
                height: 14.0,
                child: AutoSizeText(
                  widget.ovrAmount ?? '0.221764 BTC',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                )),
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
