import 'package:flutter/material.dart';

class AmountToPaySlider extends StatefulWidget {
  final Widget child;
  AmountToPaySlider({Key key, this.child}) : super(key: key);

  @override
  _AmountToPaySliderState createState() => _AmountToPaySliderState();
}

class _AmountToPaySliderState extends State<AmountToPaySlider> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
