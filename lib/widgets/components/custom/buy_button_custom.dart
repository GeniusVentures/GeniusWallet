import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyButtonCustom extends StatefulWidget {
  final Widget? child;
  BuyButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BuyButtonCustomState createState() => _BuyButtonCustomState();
}

class _BuyButtonCustomState extends State<BuyButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        // TODO: enable buying
        //await launchUrl(Uri.parse('https://moonpay.com/buy'));
        // context.push('/buy', extra: context.read<WalletDetailsCubit>());
      },
      child: widget.child!,
      textColor: GeniusWalletColors.btnText,
      color: GeniusWalletColors.lightGreenPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusButton))),
    );
  }
}
