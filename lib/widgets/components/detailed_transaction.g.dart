import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/detailed_transaction_options_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/detailed_transaction_status_custom.dart';

class DetailedTransaction extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTimestamp;
  final String? ovrTransactionID;
  final Widget? ovrTransactionArrow;
  final String? ovrTransactionValue;
  final Widget? ovrMask2;
  final Widget? ovrMask3;
  final String? ovrCompleted;
  final Widget? ovrCoinIcon;
  const DetailedTransaction(
    this.constraints, {
    Key? key,
    this.ovrTimestamp,
    this.ovrTransactionID,
    this.ovrTransactionArrow,
    this.ovrTransactionValue,
    this.ovrMask2,
    this.ovrMask3,
    this.ovrCompleted,
    this.ovrCoinIcon,
  }) : super(key: key);
  @override
  _DetailedTransaction createState() => _DetailedTransaction();
}

class _DetailedTransaction extends State<DetailedTransaction> {
  _DetailedTransaction();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width - 110,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard)),
        ),
        child: Wrap(
          spacing: 30,
          runSpacing: 30,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
                spacing: 30,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DetailedTransactionOptionsCustom(
                    child: const Icon(Icons.output_rounded),
                  ),
                  AutoSizeText(
                    widget.ovrTimestamp ?? '16:23, 12 dec 2018',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3500000238418579,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  widget.ovrCoinIcon ??
                      SvgPicture.asset(
                        'assets/images/coinicon.svg',
                        package: 'genius_wallet',
                        height: 35.0,
                        width: 35.0,
                        fit: BoxFit.none,
                      ),
                ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              widget.ovrTransactionArrow ??
                  SvgPicture.asset(
                    'assets/images/transactionarrow.svg',
                    package: 'genius_wallet',
                    height: 10.666748046875,
                    width: 16.0,
                    fit: BoxFit.none,
                  ),
              const SizedBox(width: 20),
              Flexible(
                  child: AutoSizeText(
                widget.ovrTransactionID ?? '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.32499998807907104,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              )),
            ]),
            AutoSizeText(
              widget.ovrTransactionValue ?? '0.0094 LTC',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
            DetailedTransactionStatusCustom(),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
