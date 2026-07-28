import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/action_button.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/custom/wallet_address_custom.dart';
import 'package:genius_wallet/components/job/submit_job_button.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/components/sgnus/sgnus_connection_widget.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class WalletInformation extends StatefulWidget {
  final BoxConstraints constraints;
  final Widget? ovrShowMoreIcon;
  final String? totalBalance;
  final String ovrAddressField;
  final WalletType walletType;
  const WalletInformation(
    this.constraints, {
    super.key,
    this.ovrShowMoreIcon,
    this.totalBalance,
    required this.ovrAddressField,
    this.walletType = WalletType.tracking,
  });
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Label
                Text(
                  'Total Balance',
                  style: GeniusWalletTypography.bodyLg.copyWith(
                    color: GeniusWalletColors.textPrimary70,
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
                        style: GeniusWalletTypography.numericDisplay.copyWith(
                          letterSpacing: 1.0,
                        ),
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
                  Text(
                    'No funds available',
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: GeniusWalletColors.statusError,
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        SGNUSConnectionWidget(),
                        SizedBox(height: 8),
                        SGNUSConnectionStatusWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.walletType == WalletType.tracking) ...[
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.borderRadiusCard,
                            ),
                            color: GeniusWalletColors.surfaceElevated,
                          ),
                          child: Text(
                            "You are watching this account",
                            style: GeniusWalletTypography.headlineMd,
                          ),
                        ),
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
                                  style: GeniusWalletTypography.bodyLg.copyWith(
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.copy_rounded, size: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (widget.walletType != WalletType.tracking) ...[
                  ActionButton(
                    onPressed: () {
                      ResponsiveDrawer.show<void>(
                        context: context,
                        title: "Your ${state.selectedNetwork?.name} address",
                        child: Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .15,
                          ),
                          alignment: Alignment.center,
                          child: CryptoAddressQR(
                            iconPath: state.selectedNetwork?.iconPath,
                            address: state.selectedWallet?.address ?? "",
                            network: state.selectedNetwork?.name ?? "",
                          ),
                        ),
                      );
                    },
                    text: 'Receive',
                    semanticLabel: "Receive ",
                    icon: Icons.qr_code,
                  ),
                  const SizedBox(width: 8),
                  // No send flow yet — muted/disabled rather than a dead button.
                  const ActionButton(
                    text: 'Send',
                    icon: Icons.send,
                    semanticLabel: "Send",
                    iconColor: GeniusWalletColors.textSecondary,
                    textColor: GeniusWalletColors.textSecondary,
                    onPressed: null,
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    text: 'Buy GNUS',
                    semanticLabel: "Buy GNUS crypto",
                    icon: Icons.attach_money,
                    onPressed: () async {
                      context.push('/buy');
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    text: "More",
                    semanticLabel: "See more options",
                    icon: Icons.more_horiz,
                    onPressed: () {
                      ResponsiveDrawer.show<void>(
                        context: context,
                        title: "More Options",
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreamBuilder<SGNUSConnection>(
                              stream: geniusApi.getSGNUSConnectionStream(),
                              builder: (context, snapshot) {
                                final connection = snapshot.data;
                                return SubmitJobButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  walletDetailsCubit: walletDetailsCubit,
                                  walletAddress:
                                      state.selectedWallet?.address ?? "",
                                  gnusConnectedWalletAddress:
                                      connection?.walletAddress ?? "",
                                );
                              },
                            ),
                            SlidingDrawerButton(
                              onPressed: () {
                                geniusApi.deleteWallet(
                                  state.selectedWallet?.address ?? "",
                                );
                                showAppSnackBar(
                                  context,
                                  'Wallet ${state.selectedWallet?.walletName ?? ""} deleted!',
                                );

                                Navigator.of(context).pop();
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    // ignore: use_build_context_synchronously
                                    context.go('/dashboard');
                                  },
                                );
                              },
                              color: GeniusWalletColors.statusError,
                              icon: FontAwesomeIcons.trash.data,
                              label: "Delete Wallet",
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
