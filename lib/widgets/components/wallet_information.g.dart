import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/widgets/loading/loading.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/send_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/buy_button_custom.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_address_custom.dart';
import 'package:go_router/go_router.dart';

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
  WalletInformationState createState() => WalletInformationState();
}

class WalletInformationState extends State<WalletInformation> {
  WalletInformationState();

  @override
  Widget build(BuildContext context) {
    final walletCubit = context.read<WalletDetailsCubit>();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (walletCubit.state.balanceStatus == WalletStatus.loading)
        const Loading(),
      if (walletCubit.state.balanceStatus == WalletStatus.successful)
        Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
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
              const SizedBox(width: 8),
              Text(
                widget.ovrCurrency ?? "",
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontFamily: 'Roboto',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: GeniusWalletColors.gray500,
                ),
              ),
            ]),
      const SizedBox(height: 20),
      Row(children: [
        if (widget.walletType == WalletType.tracking) ...[
          Expanded(
              child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          GeniusWalletConsts.borderRadiusCard),
                      color: GeniusWalletColors.deepBlueCardColor),
                  child: const Text(
                    "You are watching this account",
                    style: TextStyle(fontSize: 20),
                  )),
              const SizedBox(height: 24),
              WalletAddressCustom(
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Flexible(
                        child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widget.ovrAddressField ?? "",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    )),
                    const SizedBox(width: 12),
                    const Icon(Icons.copy_rounded, size: 24)
                  ]))
            ],
          ))
        ],
        if (widget.walletType != WalletType.tracking) ...[
          SquareButton(
              text: 'Receive',
              icon: Icons.qr_code,
              onPressed: () {
                context.push('/receive',
                    extra: context.read<WalletDetailsCubit>());
              }),
          const SizedBox(width: 12),
          const SquareButton(
            text: 'Send',
            icon: Icons.send,
          ),
          const SizedBox(width: 12),
          SquareButton(
              text: 'Swap', icon: Icons.swap_horiz, onPressed: null //() {
              // TODO: renable swap...
              // Open the Swap Screen as a popup
              // context.push('/swap',
              //     extra: context.read<WalletDetailsCubit>());
              //}
              ),
          const SizedBox(width: 12),
          SquareButton(
            text: 'Buy',
            icon: Icons.attach_money,
          ),
        ]
      ]),
      const SizedBox(height: 8),
    ]);
    // SendButtonCustom(
    //     child: LayoutBuilder(builder: (context, constraints) {
    //   return Container(
    //       alignment: Alignment.center,
    //       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    //       width: widget.constraints.maxWidth * .25,
    //       decoration: const BoxDecoration(
    //           borderRadius: BorderRadius.all(Radius.circular(
    //               GeniusWalletConsts.borderRadiusButton)),
    //           color: GeniusWalletColors.gray800),
    //       child: const Text('Send',
    //           style: TextStyle(
    //               fontSize: 16, fontWeight: FontWeight.w700)));
    // })),
    // BuyButtonCustom(
    //     child: LayoutBuilder(builder: (context, constraints) {
    //   return Container(
    //       alignment: Alignment.center,
    //       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    //       width: widget.constraints.maxWidth * .40,
    //       decoration: const BoxDecoration(
    //           borderRadius: BorderRadius.all(Radius.circular(
    //               GeniusWalletConsts.borderRadiusButton)),
    //           color: GeniusWalletColors.lightGreenSecondary),
    //       child: const Text('Buy',
    //           style: TextStyle(
    //               fontSize: 16,
    //               fontWeight: FontWeight.w700,
    //               color: GeniusWalletColors.deepBlueTertiary)));
    // })),
    // ReceiveButtonCustom(
    //     child: LayoutBuilder(builder: (context, constraints) {
    //   return Container(
    //       alignment: Alignment.center,
    //       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    //       width: widget.constraints.maxWidth * .25,
    //       decoration: const BoxDecoration(
    //           borderRadius: BorderRadius.all(Radius.circular(
    //               GeniusWalletConsts.borderRadiusButton)),
    //           color: GeniusWalletColors.gray800),
    //       child: const Text('Receive',
    //           style: TextStyle(
    //               fontSize: 16, fontWeight: FontWeight.w700)));
    // })),
    //         ]
    //       ]),
    // ),
    // Positioned(
    //   left: 0,
    //   width: widget.constraints.maxWidth,
    //   top: 225,
    //   height: 35.0,
    //   child: Center(
    //       child: SizedBox(
    //           height: 35.0,
    //           child: WalletAddressCustom(
    //               child: SizedBox(
    //                   child: Stack(children: [
    //             Positioned(
    //               left: 0,
    //               right: 0,
    //               top: 0,
    //               bottom: 10.0,
    //               child: SizedBox(
    //                   height: 14.0,
    //                   width: widget.constraints.maxWidth,
    //                   child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Text(
    //                           overflow: TextOverflow.ellipsis,
    //                           widget.ovrAddressField ?? "",
    //                           style: const TextStyle(
    //                             fontFamily: 'Roboto',
    //                             fontSize: 16.0,
    //                             fontWeight: FontWeight.w400,
    //                             letterSpacing: 0.4,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                         const SizedBox(width: 12),
    //                         const Icon(Icons.copy_rounded, size: 14)
    //                       ])),
    //             ),
    //           ]))))),
    // )
    //     ]),
    //   ),
    // ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SquareButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const SquareButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.backgroundColor = GeniusWalletColors.deepBlueCardColor,
    this.iconColor = GeniusWalletColors.lightGreenSecondary,
    this.textColor = GeniusWalletColors.lightGreenSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _iconColor =
        onPressed != null ? iconColor : GeniusWalletColors.gray600;
    final _textColor =
        onPressed != null ? textColor : GeniusWalletColors.gray600;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4),
        fixedSize: Size(MediaQuery.of(context).size.width * .25 - 19, 110),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
        disabledBackgroundColor: GeniusWalletColors.deepBlueCardColor,
        backgroundColor: backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: _iconColor), // Icon
          const SizedBox(height: 8),
          Flexible(
              child: Text(
            overflow: TextOverflow.ellipsis,
            text,
            style: TextStyle(
              color: _textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          )), // Text below the icon
        ],
      ),
    );
  }
}
