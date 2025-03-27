import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/home/widgets/containers.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/genius_wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';

class GeniusWalletDetailsScreen extends StatelessWidget {
  const GeniusWalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeniusWalletDetailsCubit, GeniusWalletDetailsState>(
      builder: (context, state) {
        return const View();
      },
    );
  }
}

class View extends StatelessWidget {
  const View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
        stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
        builder: (context, snapshot) {
          return BlocBuilder<GeniusWalletDetailsCubit,
              GeniusWalletDetailsState>(
            builder: (context, state) {
              final geniusApi = context.read<GeniusApi>();
              final connection = snapshot.data;
              final isDisabled = connection == null || !connection.isConnected;
              final walletCubit = context.read<GeniusWalletDetailsCubit>();

              return Scaffold(
                  appBar: AppBar(),
                  body: Center(
                      child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: AppScreenView(
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 18),
                            SizedBox(
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: Row(children: [
                                          Image.asset(
                                            "assets/images/crypto/gnus.png",
                                            height: 36,
                                            width: 36,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const SizedBox(
                                                  height: 40, width: 40);
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          const Flexible(
                                              child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            "Super Genius Wallet",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ))
                                        ])),
                                      ]);
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            LayoutBuilder(builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // if (walletCubit.state.balanceStatus == WalletStatus.loading)
                                    //   const Loading(),
                                    // if (walletCubit.state.balanceStatus == WalletStatus.successful)
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Flexible(
                                              child: AutoSizeText(
                                            geniusApi.getMinionsBalance(),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 48.0,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          )),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "minions",
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: GeniusWalletColors.gray500,
                                            ),
                                          ),
                                        ]),

                                    // TODO: add any square buttons for actions within the genius wallet view
                                    // const Row(children: [
                                    //   Expanded(
                                    //       child: SquareButton(
                                    //     text: 'Bridge',
                                    //     icon: Icons.send,
                                    //   )),
                                    //   SizedBox(width: 8),
                                    //   Expanded(
                                    //       child: SquareButton(
                                    //     text: 'Other',
                                    //     icon: Icons.attach_money,
                                    //   )),
                                    // ]),
                                  ]);
                            }),

                            // TODO: wire up an alternate coins screen to show child tokens of the sgnus wallet
                            // const SizedBox(child: CoinsScreen()),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 280,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return DashboardScrollContainer(
                                      child: TransactionsSlimView(
                                          transactions: geniusApi
                                              .getSGNUSTransactions()));
                                },
                              ),
                            ),
                            const SizedBox(height: 18)
                          ],
                        ),
                      ),
                    ),
                  )));
            },
          );
        });
  }
}
