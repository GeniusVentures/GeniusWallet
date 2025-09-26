import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_service.dart';
import 'package:genius_wallet/components/job/submit_job_button.dart';
import 'package:genius_wallet/components/job/submit_job_dashboard_button.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/components/sgnus/sgnus_connection_widget.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/components/action_button.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/custom/wallet_address_custom.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
import 'package:go_router/go_router.dart';

class WalletInformation extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrShowMoreIcon;
  final String? totalBalance;
  final String ovrAddressField;
  final WalletType walletType;
  const WalletInformation(this.constraints,
      {Key? key,
      this.ovrShowMoreIcon,
      this.totalBalance,
      required this.ovrAddressField,
      this.walletType = WalletType.tracking})
      : super(key: key);
  @override
  WalletInformationState createState() => WalletInformationState();
}

class WalletInformationState extends State<WalletInformation> {
  WalletInformationState();

  @override
  Widget build(BuildContext context) {
    final walletDetailsCubit = context.read<WalletDetailsCubit>();
    final geniusApi = context.read<GeniusApi>();

    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Label
            const Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: AutoSizeText(
                    widget.totalBalance ?? "0.00",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 36.0, // Changed to 36sp
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 8),
            if ((widget.totalBalance == null) ||
                widget.totalBalance == "0" ||
                widget.totalBalance == "0.00" ||
                widget.totalBalance == "\$0.00")
              const Text(
                'No funds available',
                style: TextStyle(
                  color: GeniusWalletColors.red,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 8),
            const SGNUSConnectionMobileWidget(),
            // BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
            //     builder: (context, state) {
            //   if (state.selectedWallet != null) {
            //     return StreamBuilder<SGNUSConnection>(
            //         stream:
            //             context.read<GeniusApi>().getSGNUSConnectionStream(),
            //         builder: (context, snapshot) {
            //           final connection = snapshot.data;
            //           return SubmitJobDashboardButton(
            //             walletDetailsCubit: context.read<WalletDetailsCubit>(),
            //             walletAddress: state.selectedWallet!.address,
            //             gnusConnectedWalletAddress:
            //                 connection?.walletAddress ?? "",
            //           );
            //         });
            //   } else {
            //     return const SizedBox.shrink();
            //   }
            // }),
          ],
        ),
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
                        widget.ovrAddressField,
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
            ActionButton(
              onPressed: () {
                ResponsiveDrawer.show<void>(
                  context: context,
                  title: "Your ${state.selectedNetwork?.name} address",
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .15),
                      alignment: Alignment.center,
                      child: CryptoAddressQR(
                        iconPath: state.selectedNetwork?.iconPath,
                        address: state.selectedWallet?.address ?? "",
                        network: state.selectedNetwork?.name ?? "",
                      ),
                    ),
                  ],
                );
              },
              text: 'Receive',
              semanticLabel: "Recieve ",
              icon: Icons.qr_code,
            ),
            const SizedBox(width: 8),
            const ActionButton(
              text: 'Send',
              icon: Icons.send,
              semanticLabel: "Send",
            ),
            const SizedBox(width: 8),
            ActionButton(
                text: 'Buy GNUS',
                semanticLabel: "Buy Gnus cryptos for your thining fucking",
                icon: Icons.attach_money,
                onPressed: () async {
                  final url = await BanxaService.getBanxaCheckoutUrl(
                    walletAddress: widget.ovrAddressField,
                    userEmail: '',
                  );

                  if (!context.mounted) return;

                  if (url != null) {
                    context.push('/buy', extra: url);
                  } else {
                    showAppSnackBar(context, 'Failed to launch Banxa checkout');
                  }
                }),
            const SizedBox(width: 8),
            ActionButton(
              text: "More",
              semanticLabel: "See more options",
              icon: Icons.more_horiz,
              onPressed: () {
                ResponsiveDrawer.show<void>(
                  context: context,
                  title: "More Options",
                  children: [
                    StreamBuilder<SGNUSConnection>(
                      stream: geniusApi.getSGNUSConnectionStream(),
                      builder: (context, snapshot) {
                        final connection = snapshot.data;
                        return SubmitJobButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // closes drawer
                          },
                          walletDetailsCubit: walletDetailsCubit,
                          walletAddress: state.selectedWallet?.address ?? "",
                          gnusConnectedWalletAddress:
                              connection?.walletAddress ?? "",
                        );
                      },
                    ),
                    SlidingDrawerButton(
                      onPressed: () {
                        geniusApi
                            .deleteWallet(state.selectedWallet?.address ?? "");
                        showAppSnackBar(context,
                            'Wallet ${state.selectedWallet?.walletName ?? ""} deleted!');

                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          // ignore: use_build_context_synchronously
                          context.go('/dashboard');
                        });
                      },
                      color: Colors.red,
                      icon: FontAwesomeIcons.trash,
                      label: "Delete Wallet",
                    ),
                  ],
                );
              },
            ),
          ]
        ]),
      ]);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
