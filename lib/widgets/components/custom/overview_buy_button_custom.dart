import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewBuyButtonCustom extends StatefulWidget {
  final Widget? child;
  OverviewBuyButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _OverviewBuyButtonCustomState createState() =>
      _OverviewBuyButtonCustomState();
}

class _OverviewBuyButtonCustomState extends State<OverviewBuyButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        launchUrl(Uri.parse('https://moonpay.com/buy'));
      },
      child: widget.child!,
    );
  }
}
