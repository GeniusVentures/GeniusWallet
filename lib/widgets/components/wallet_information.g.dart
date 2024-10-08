import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/widgets/loading/loading.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
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
  final WalletType walletType;
  const WalletInformation(this.constraints,
      {Key? key,
      this.ovrShowMoreIcon,
      this.ovrTotalbalance,
      this.ovrCurrency,
      this.ovrQuantity,
      this.ovrAddressField,
      this.walletType = WalletType.tracking})
      : super(key: key);
  @override
  _WalletInformation createState() => _WalletInformation();
}

class _WalletInformation extends State<WalletInformation> {
  _WalletInformation();

  @override
  Widget build(BuildContext context) {
    final walletCubit = context.read<WalletDetailsCubit>();
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
                width: widget.constraints.maxWidth,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: widget.constraints.maxWidth * 1.0),
                    child: () {
                      if (walletCubit.state.balanceStatus ==
                          WalletStatus.loading) {
                        return const Loading();
                      }
                      if (walletCubit.state.balanceStatus ==
                          WalletStatus.successful) {
                        return Row(children: [
                          AutoSizeText(
                            widget.ovrQuantity ?? "0",
                            overflow: TextOverflow.ellipsis,
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
                                  color: GeniusWalletColors.btnTextDisabled,
                                ),
                              ))
                        ]);
                      }
                    }()),
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
                      )
                    ]),
              ),
            ]))))),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 110.0,
            height: 40.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.walletType == WalletType.tracking) ...[
                    Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    GeniusWalletConsts.borderRadiusCard),
                                color: GeniusWalletColors.deepBlueCardColor),
                            child: const Text(
                              "You are watching this account",
                              style: TextStyle(fontSize: 16),
                            )))
                  ],
                  if (widget.walletType != WalletType.tracking) ...[
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
                                  fontSize: 16, fontWeight: FontWeight.w700)));
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
                                  color: GeniusWalletColors.deepBlueTertiary)));
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
                                  fontSize: 16, fontWeight: FontWeight.w700)));
                    })),
                  ]
                ]),
          ),
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth,
            top: 160,
            height: 35.0,
            child: Center(
                child: SizedBox(
                    height: 35.0,
                    child: WalletAddressCustom(
                        child: SizedBox(
                            child: Stack(children: [
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
          if (widget.walletType != WalletType.tracking) ...[
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
            )
          ],
        ]),
      ),
    ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
