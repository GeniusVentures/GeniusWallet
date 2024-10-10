import 'package:flutter/material.dart';
import 'package:genius_api/types/wallet_type.dart';

class WalletTypeIcon extends StatelessWidget {
  final WalletType? walletType;

  const WalletTypeIcon({Key? key, this.walletType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return () {
      if (walletType == null) {
        return const SizedBox();
      }
      if (walletType == WalletType.mnemonic) {
        return const Icon(
          semanticLabel: 'account',
          Icons.account_box_outlined,
          size: 20,
        );
      }

      if (walletType == WalletType.tracking) {
        return const Icon(
          semanticLabel: 'watching',
          Icons.remove_red_eye_outlined,
          size: 20,
        );
      }
      return const Icon(
        semanticLabel: 'wallet',
        Icons.wallet_outlined,
        size: 20,
      );
    }();
  }
}
