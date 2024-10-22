import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class SuccessfulTransactionDetails extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrUserBalanceLabel;
  final String? ovrReceiverWalletIDLabel;
  final String? ovrTransactionIDLabel;
  final String? ovrTransactionFeeLabel;
  final String? ovrTransactionTimestampLabel;
  final String? ovrTransactionValueLabel;
  final String? ovrUserBalance;
  final String? ovrReceiverWalletID;
  final String? ovrTransactionID;
  final String? ovrGasFee;
  final String? ovrTransactionTimestamp;
  final String? ovrTransactionValue;
  const SuccessfulTransactionDetails(
    this.constraints, {
    Key? key,
    this.ovrUserBalanceLabel,
    this.ovrReceiverWalletIDLabel,
    this.ovrTransactionIDLabel,
    this.ovrTransactionFeeLabel,
    this.ovrTransactionTimestampLabel,
    this.ovrTransactionValueLabel,
    this.ovrUserBalance,
    this.ovrReceiverWalletID,
    this.ovrTransactionID,
    this.ovrGasFee,
    this.ovrTransactionTimestamp,
    this.ovrTransactionValue,
  }) : super(key: key);
  @override
  _SuccessfulTransactionDetails createState() =>
      _SuccessfulTransactionDetails();
}

class _SuccessfulTransactionDetails
    extends State<SuccessfulTransactionDetails> {
  _SuccessfulTransactionDetails();

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
                left: 15.0,
                width: 299.0,
                top: 85.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 299.0,
                    child: AutoSizeText(
                      widget.ovrUserBalanceLabel ?? 'Balance',
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
                left: 15.0,
                width: 295.0,
                top: 149.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 295.0,
                    child: AutoSizeText(
                      widget.ovrReceiverWalletIDLabel ?? 'Receiver',
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
                left: 15.0,
                width: 299.0,
                top: 211.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 299.0,
                    child: AutoSizeText(
                      widget.ovrTransactionIDLabel ?? 'Transaction',
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
                left: 15.0,
                width: 299.0,
                top: 273.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 299.0,
                    child: AutoSizeText(
                      widget.ovrTransactionFeeLabel ?? 'Fee',
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
                left: 15.0,
                width: 299.0,
                top: 339.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 299.0,
                    child: AutoSizeText(
                      widget.ovrTransactionTimestampLabel ?? 'Date',
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
                left: 15.0,
                width: 299.0,
                top: 31.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 299.0,
                    child: AutoSizeText(
                      widget.ovrTransactionValueLabel ?? 'Amount',
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
                left: 14.0,
                width: 300.0,
                top: 106.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 300.0,
                    child: AutoSizeText(
                      widget.ovrUserBalance ?? '0.000014 BTC',
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
                width: 297.0,
                top: 173.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 297.0,
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
                width: 284.0,
                top: 235.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 284.0,
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
                width: 297.0,
                top: 297.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 297.0,
                    child: AutoSizeText(
                      widget.ovrGasFee ??
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
                width: 297.0,
                top: 363.0,
                height: 16.0,
                child: Container(
                    height: 16.0,
                    width: 297.0,
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
                width: 300.0,
                top: 52.0,
                height: 14.0,
                child: Container(
                    height: 14.0,
                    width: 300.0,
                    child: AutoSizeText(
                      widget.ovrTransactionValue ?? '0.221764 BTC',
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
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
