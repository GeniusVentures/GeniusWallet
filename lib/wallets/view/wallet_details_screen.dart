import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/wallet_information.g.dart';
import 'package:intl/intl.dart';

class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen({Key? key}) : super(key: key);

  @override
  WalletDetailsScreenState createState() => WalletDetailsScreenState();
}

class WalletDetailsScreenState extends State<WalletDetailsScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch coins once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<WalletDetailsCubit>();
      final wallet = cubit.state.selectedWallet;

      if (wallet != null) {
        cubit.getCoins();
      }
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

        final selectedWallet = state.selectedWallet!;
        final balance =
            double.tryParse(state.selectedWalletBalance ?? '0') ?? 0;

        final displayBalance = balance == 0
            ? "\$0.00"
            : NumberFormat.simpleCurrency().format(balance);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AppScreenView(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return WalletInformation(
                          constraints,
                          totalBalance: displayBalance,
                          ovrAddressField: selectedWallet.address,
                          walletType: selectedWallet.walletType,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    StreamBuilder<SGNUSConnection>(
                      stream:
                          context.read<GeniusApi>().getSGNUSConnectionStream(),
                      builder: (context, snapshot) {
                        final connection = snapshot.data;
                        return CoinsScreen(
                          isGnusWalletConnected:
                              (connection?.walletAddress ?? false) ==
                                  selectedWallet.address,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
