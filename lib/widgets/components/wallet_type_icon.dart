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
          Icons.account_box_outlined,
          size: 24,
        );
      }

      if (walletType == WalletType.tracking) {
        return const Icon(
          Icons.remove_red_eye_outlined,
          size: 24,
        );
      }
      return const Icon(Icons.wallet_outlined);
    }();
  }
}
