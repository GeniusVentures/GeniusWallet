import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyButtonCustom extends StatefulWidget {
  final Widget? child;
  const BuyButtonCustom({
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
        await launchUrl(Uri.parse('https://moonpay.com/buy'));
        // context.push('/buy', extra: context.read<WalletDetailsCubit>());
      },
      child: widget.child!,
    );
  }
}
