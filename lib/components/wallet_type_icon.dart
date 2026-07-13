import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        return Icon(
          semanticLabel: 'account',
          FontAwesomeIcons.user.data,
          size: 20,
        );
      }

      if (walletType == WalletType.tracking) {
        return Icon(
          semanticLabel: 'watching',
          FontAwesomeIcons.eye.data,
          size: 20,
        );
      }
      return Icon(
        semanticLabel: 'wallet',
        FontAwesomeIcons.wallet.data,
        size: 20,
      );
    }();
  }
}
