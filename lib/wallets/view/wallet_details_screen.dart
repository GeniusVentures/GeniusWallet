import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/coins/view/coins_screen.dart';
import 'package:genius_wallet/app/widgets/networks/network_dropdown.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:genius_wallet/widgets/components/wallet_type_icon.dart';

class WalletDetailsScreen extends StatelessWidget {
  const WalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();
        if (state.selectedWallet == null) {
          return const Center(
            child: Text('Error'),
          );
        }

        if (state.fetchNetworksStatus == WalletStatus.initial) {
          walletCubit.getNetworks();
        }

        // load networks / select network first then fetch balance
        if (state.balanceStatus == WalletStatus.initial &&
            state.fetchNetworksStatus == WalletStatus.successful) {
          walletCubit.getWalletBalance();
        }

        return const View();
      },
    );
  }
}

class View extends StatelessWidget {
  const View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final selectedWallet = state.selectedWallet!;
        return Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  actions: [
                    SizedBox(
                        width: 250,
                        child: NetworkDropdown(
                            wallet: selectedWallet,
                            network: state.selectedNetwork,
                            networkList: state.networks)),
                  ],
                )),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                      child: Row(children: [
                                    WalletTypeIcon(
                                        walletType: selectedWallet.walletType),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Flexible(
                                        child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      selectedWallet.walletName,
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.33,
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
                      LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return WalletInformation(constraints,
                              ovrQuantity: state.balance == 0
                                  ? "0"
                                  : state.balance.toStringAsFixed(4),
                              ovrCurrency: state.selectedNetwork?.symbol,
                              ovrAddressField: selectedWallet.address,
                              walletType: selectedWallet.walletType);
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                          child: StreamBuilder<SGNUSConnection>(
                              stream: context
                                  .read<GeniusApi>()
                                  .getSGNUSConnectionStream(),
                              builder: (context, snapshot) {
                                final connection = snapshot.data;
                                return CoinsScreen(
                                    isGnusWalletConnected:
                                        (connection?.walletAddress ?? false) ==
                                            state.selectedWallet?.address);
                              })),
                    ],
                  ),
                ),
              ),
            )));
      },
    );
  }
}
