import 'package:flutter/material.dart';
import 'package:genius_wallet/landing/view/wallet_creation_screen.dart';

class GeniusBackButtonCustom extends StatefulWidget {
  final Widget? child;
  GeniusBackButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _GeniusBackButtonCustomState createState() => _GeniusBackButtonCustomState();
}

class _GeniusBackButtonCustomState extends State<GeniusBackButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LandingScreen()));
        }
      },
      child: widget.child,
    );
  }
}
