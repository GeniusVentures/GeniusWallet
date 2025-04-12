import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/coins/view/coins_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:intl/intl.dart';

class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen({Key? key}) : super(key: key);

  @override
  WalletDetailsScreenState createState() => WalletDetailsScreenState();
}

class WalletDetailsScreenState extends State<WalletDetailsScreen> {
  double _totalValue = 0.0;

  void _updateTotalValue(double value) {
    setState(() {
      _totalValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        if (state.selectedWallet == null) {
          return const Center(
            child: Text('Error'),
          );
        }

        return View(
            onTotalValueCalculated: _updateTotalValue, totalValue: _totalValue);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Safely wait for the first frame to access context without BuildContext warnings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<WalletDetailsCubit>();
      final wallet = cubit.state.selectedWallet;

      if (wallet != null) {
        cubit.getCoins();
      }
    });
  }
}

class View extends StatelessWidget {
  final Function(double) onTotalValueCalculated;
  final double totalValue;

  const View(
      {Key? key,
      required this.onTotalValueCalculated,
      required this.totalValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final selectedWallet = state.selectedWallet!;

        return Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AppScreenView(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return WalletInformation(constraints,
                          totalBalance: totalValue == 0
                              ? "\$0.00"
                              : NumberFormat.simpleCurrency()
                                  .format(totalValue),
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
                                        state.selectedWallet?.address,
                                onTotalValueCalculated: onTotalValueCalculated);
                          })),
                ],
              ),
            ),
          ),
        ));
      },
    );
  }
}
