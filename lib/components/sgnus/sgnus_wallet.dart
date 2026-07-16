import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:genius_wallet/components/wallet_preview.g.dart';

class SGNUSWallet extends StatefulWidget {
  const SGNUSWallet({Key? key}) : super(key: key);

  @override
  SGNUSWalletState createState() => SGNUSWalletState();
}

class SGNUSWalletState extends State<SGNUSWallet> {
  @override
  Widget build(BuildContext context) {
    final geniusApi = context.read<GeniusApi>();
    return StreamBuilder<SGNUSConnection>(
      stream: geniusApi.getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Renders nothing
        }

        final connection = snapshot.data!;

        if (connection.isConnected) {
          return WalletPreview(
              walletBalance: const Flexible(
                  child: GeniusBalanceDisplay(
                      useMinions: true,
                      fontSize: 12,
                      isShowSuffix: true,
                      fontColor: GeniusWalletColors.gray500)),
              walletAddress: connection.sgnusAddress,
              walletType: WalletType.sgnus,
              ovrCoinSymbol: 'minions',
              isShowSymbol: false,
              walletName: 'Super Genius Wallet');
        }

        return const SizedBox.shrink();
      },
    );
  }
}
