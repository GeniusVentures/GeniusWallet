import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class HistoricTransactionDetailView extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCryptoTypeLabel;
  final String? ovrReceiverWalletIDLabel;
  final String? ovrTransactionIDLabel;
  final String? ovrTransactionFeeLabel;
  final String? ovrTransactionTimestampLabel;
  final String? ovrTransactionAmountLabel;
  final String? ovrCryptoType;
  final String? ovrReceiverWalletID;
  final String? ovrTransactionID;
  final String? ovrTransactionFee;
  final String? ovrTransactionType;
  final String? ovrTransactionTimestamp;
  final String? ovrTransactionAmount;
  final Widget? ovrTransactionTypeArrow;
  const HistoricTransactionDetailView(
    this.constraints, {
    Key? key,
    this.ovrCryptoTypeLabel,
    this.ovrReceiverWalletIDLabel,
    this.ovrTransactionIDLabel,
    this.ovrTransactionFeeLabel,
    this.ovrTransactionTimestampLabel,
    this.ovrTransactionAmountLabel,
    this.ovrCryptoType,
    this.ovrReceiverWalletID,
    this.ovrTransactionID,
    this.ovrTransactionFee,
    this.ovrTransactionType,
    this.ovrTransactionTimestamp,
    this.ovrTransactionAmount,
    this.ovrTransactionTypeArrow,
  }) : super(key: key);
  @override
  _HistoricTransactionDetailView createState() =>
      _HistoricTransactionDetailView();
}

class _HistoricTransactionDetailView
    extends State<HistoricTransactionDetailView> {
  _HistoricTransactionDetailView();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 15.0,
                width: 298.0,
                top: 85.0,
                child: Container(
                    width: 298.0,
                    child: AutoSizeText(
                      widget.ovrCryptoTypeLabel ?? 'Cryptocurrency',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 15.0,
                width: 302.0,
                top: 149.0,
                child: Container(
                    width: 302.0,
                    child: AutoSizeText(
                      widget.ovrReceiverWalletIDLabel ?? 'Receiver',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 15.0,
                top: 211.0,
                child: Container(
                    child: AutoSizeText(
                  widget.ovrTransactionIDLabel ?? 'Transaction',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.30000001192092896,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                )),
              ),
              Positioned(
                left: 15.0,
                width: 302.0,
                top: 273.0,
                child: Container(
                    width: 302.0,
                    child: AutoSizeText(
                      widget.ovrTransactionFeeLabel ?? 'Fee',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 15.0,
                width: 302.0,
                top: 345.0,
                child: Container(
                    width: 302.0,
                    child: AutoSizeText(
                      'Transaction Direction',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 15.0,
                width: 302.0,
                top: 421.0,
                child: Container(
                    width: 302.0,
                    child: AutoSizeText(
                      widget.ovrTransactionTimestampLabel ?? 'Date',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 15.0,
                width: 298.0,
                top: 31.0,
                child: Container(
                    width: 298.0,
                    child: AutoSizeText(
                      widget.ovrTransactionAmountLabel ?? 'Amount',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 14.0,
                width: 299.0,
                top: 106.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 299.0,
                    child: AutoSizeText(
                      widget.ovrCryptoType ?? 'Bitcoin',
                      style: TextStyle(
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
                left: 17.0,
                width: 300.0,
                top: 173.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 300.0,
                    child: AutoSizeText(
                      widget.ovrReceiverWalletID ??
                          '0x0xeacdeeefxceadefe3ad567cda5cxc6879',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 17.0,
                top: 235.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    child: AutoSizeText(
                      widget.ovrTransactionID ??
                          '0xeacdacdvafedswvsvxfsafedavedvaseav832',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 17.0,
                width: 300.0,
                top: 297.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 300.0,
                    child: AutoSizeText(
                      widget.ovrTransactionFee ?? '123',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 36.0,
                width: 281.0,
                top: 375.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 281.0,
                    child: AutoSizeText(
                      widget.ovrTransactionType ?? 'Incoming',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 17.0,
                width: 300.0,
                top: 445.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 300.0,
                    child: AutoSizeText(
                      widget.ovrTransactionTimestamp ??
                          '29th September 2022, 11:23PM',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                left: 14.0,
                width: 303.0,
                top: 52.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 303.0,
                    child: AutoSizeText(
                      widget.ovrTransactionAmount ?? '+ 0.221764 BTC',
                      style: TextStyle(
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
                left: widget.constraints.maxWidth * 0.047,
                width: widget.constraints.maxWidth * 0.05,
                top: widget.constraints.maxHeight * 0.755,
                height: widget.constraints.maxHeight * 0.022,
                child: widget.ovrTransactionTypeArrow ??
                    SvgPicture.asset(
                      'assets/images/transactiontypearrow.svg',
                      package: 'genius_wallet',
                      height:
                          widget.constraints.maxHeight * 0.02163640577459432,
                      width: widget.constraints.maxWidth * 0.050473186119873815,
                      fit: BoxFit.fill,
                    ),
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
