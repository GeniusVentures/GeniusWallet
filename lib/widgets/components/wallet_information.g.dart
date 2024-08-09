import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/total_balance_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/widgets/components/custom/send_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/buy_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/receive_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_address_custom.dart';
import 'package:genius_wallet/widgets/components/custom/q_r_code_button_custom.dart';

class WalletInformation extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrShowMoreIcon;
  final String? ovrTotalbalance;
  final String? ovrCurrency;
  final String? ovrQuantity;
  final String? ovrAddressField;
  final String? ovrYourbitcoinaddress;
  const WalletInformation(
    this.constraints, {
    Key? key,
    this.ovrShowMoreIcon,
    this.ovrTotalbalance,
    this.ovrCurrency,
    this.ovrQuantity,
    this.ovrAddressField,
    this.ovrYourbitcoinaddress,
  }) : super(key: key);
  @override
  _WalletInformation createState() => _WalletInformation();
}

class _WalletInformation extends State<WalletInformation> {
  _WalletInformation();

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
                width: widget.constraints.maxWidth * 1.0,
                top: 0,
                height: 91.0,
                child: Center(
                    child: SizedBox(
                        child: TotalBalanceCustom(
                            child: SizedBox(
                                child: Stack(children: [
                  Positioned(
                    left: 0,
                    top: 35.0,
                    child: Row(children: [
                      AutoSizeText(
                        widget.ovrQuantity ?? '0.221746',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 48.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 30, left: 4),
                          child: AutoSizeText(
                            widget.ovrCurrency ?? 'BTC ',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25714290142059326,
                              color: GeniusWalletColors.btnTextDisabled,
                            ),
                          ))
                    ]),
                  ),
                  Positioned(
                    left: 0,
                    width: widget.constraints.maxWidth,
                    top: 6.0,
                    height: 16.0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            widget.ovrTotalbalance ?? 'Total balance:',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          widget.ovrShowMoreIcon ??
                              Image.asset(
                                'assets/images/showmoreicon.png',
                                package: 'genius_wallet',
                                height: 16.0,
                                width: 4.0,
                                color: Colors.white,
                                fit: BoxFit.none,
                              ),
                        ]),
                  ),
                ]))))),
              ),
              Positioned(
                left: 4.0,
                right: 5.0,
                top: 110.0,
                height: 40.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SendButtonCustom(
                          child: LayoutBuilder(builder: (context, constraints) {
                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            width: widget.constraints.maxWidth * .25,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    GeniusWalletConsts.borderRadiusButton)),
                                color: GeniusWalletColors.gray800),
                            child: const Text('Send',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)));
                      })),
                      BuyButtonCustom(
                          child: LayoutBuilder(builder: (context, constraints) {
                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            width: widget.constraints.maxWidth * .40,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    GeniusWalletConsts.borderRadiusButton)),
                                color: GeniusWalletColors.lightGreenSecondary),
                            child: const Text('Buy',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        GeniusWalletColors.deepBlueTertiary)));
                      })),
                      ReceiveButtonCustom(
                          child: LayoutBuilder(builder: (context, constraints) {
                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            width: widget.constraints.maxWidth * .25,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    GeniusWalletConsts.borderRadiusButton)),
                                color: GeniusWalletColors.gray800),
                            child: const Text('Receive',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)));
                      })),
                    ]),
              ),
              Positioned(
                left: 0,
                width: widget.constraints.maxWidth,
                bottom: 0,
                height: 35.0,
                child: Center(
                    child: SizedBox(
                        height: 35.0,
                        child: WalletAddressCustom(
                            child: SizedBox(
                                child: Stack(children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: GeniusWalletColors.deepBlueCardColor,
                              borderRadius: BorderRadius.all(Radius.circular(
                                  GeniusWalletConsts.borderRadiusButton)),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 11.0,
                            bottom: 10.0,
                            child: SizedBox(
                                height: 14.0,
                                width: widget.constraints.maxWidth,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        widget.ovrAddressField ??
                                            '1Cs4wu6pu5qCZ35bSLNVzGyEx5N6uzbg9t',
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.30000001192092896,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.copy_rounded, size: 14)
                                    ])),
                          ),
                        ]))))),
              ),
              Positioned(
                left: 0,
                bottom: 49.0,
                height: 14.0,
                child: SizedBox(
                    height: 14.0,
                    child: AutoSizeText(
                      widget.ovrYourbitcoinaddress ?? 'Your bitcoin adress:',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    )),
              ),
              Positioned(
                right: 0,
                width: 63.0,
                bottom: 49.0,
                height: 14.0,
                child: QRCodeButtonCustom(
                    child: const AutoSizeText(
                  'QR-code',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationThickness: 2,
                    fontFamily: 'Roboto',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
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
