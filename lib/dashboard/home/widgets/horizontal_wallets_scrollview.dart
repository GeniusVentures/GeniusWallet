import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              child: Row(children: [
                const SizedBox(width: 4),
                WalletContainerButton(
                    onPressed: () {}, child: const SGNUSWallet()),
                const SizedBox(width: 12),
                for (int i = 0; i < state.wallets.length; i++) ...[
                  WalletContainerButton(
                    onPressed: () {
                      context.push('/wallets/${state.wallets[i].address}');
                    },
                    child: WalletPreview(
                        ovrWalletBalance: state.wallets[i].balance == 0
                            ? '0'
                            : state.wallets[i].balance.toStringAsFixed(3),
                        walletAddress: state.wallets[i].address,
                        walletType: state.wallets[i].walletType,
                        ovrCoinSymbol: state.wallets[i].currencySymbol,
                        walletName: state.wallets[i].walletName),
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
              ]));
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
