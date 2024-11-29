import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/sgnus/sgnus_wallet.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';
import 'package:go_router/go_router.dart';

class HorizontalWalletsScrollview extends StatelessWidget {
  const HorizontalWalletsScrollview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return () {
          if (state.wallets.isEmpty) {
            return const Center(
                child: AutoSizeText(
              "You Have No Wallets!",
              style: TextStyle(fontSize: 20),
            ));
          }
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<SGNUSConnection>(
                  stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
                  builder: (context, snapshot) {
                    final connection = snapshot.data;
                    final sortedWallets = state.wallets;
                    // sort connected wallet to the front
                    sortedWallets.sort((a, b) {
                      if (a.address == connection?.walletAddress &&
                          b.address != connection?.walletAddress) {
                        return -1;
                      } else if (b.address == connection?.walletAddress &&
                          a.address != connection?.walletAddress) {
                        return 1;
                      } else {
                        return 0;
                      }
                    });
                    return Row(children: [
                      if (connection != null && connection.isConnected) ...[
                        WalletContainerButton(
                            onPressed: () {}, child: const SGNUSWallet()),
                        const SizedBox(width: 12)
                      ],
                      for (int i = 0; i < sortedWallets.length; i++) ...[
                        WalletContainerButton(
                          onPressed: () {
                            context
                                .push('/wallets/${sortedWallets[i].address}');
                          },
                          child: WalletPreview(
                              isConnected: connection != null &&
                                  connection.isConnected &&
                                  connection.walletAddress ==
                                      sortedWallets[i].address,
                              ovrWalletBalance: sortedWallets[i].balance == 0
                                  ? '0'
                                  : sortedWallets[i].balance.toStringAsFixed(3),
                              walletAddress: sortedWallets[i].address,
                              walletType: sortedWallets[i].walletType,
                              ovrCoinSymbol: sortedWallets[i].currencySymbol,
                              walletName: sortedWallets[i].walletName),
                        ),
                        const SizedBox(width: 12)
                      ],
                      WalletContainerButton(
                          width: 200,
                          onPressed: () => context.push('/landing_screen'),
                          child: const Center(
                              child: Text(GeniusWalletText.btnAddWallet,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: GeniusWalletColors.lightGreenPrimary,
                                  ))))
                    ]);
                  }));
        }();
      },
    );
  }
}

class WalletContainerButton extends StatelessWidget {
  final Widget child; // The content inside the button
  final VoidCallback? onPressed; // The callback for button press
  final double width; // Customizable width
  final double borderRadius; // Border radius
  final Color color; // Background color

  const WalletContainerButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = 350.0,
    this.borderRadius = GeniusWalletConsts.borderRadiusCard,
    this.color = GeniusWalletColors.deepBlueCardColor, // Default color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MaterialButton(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        color: color,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
