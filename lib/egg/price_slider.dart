import 'package:flutter/material.dart';

class PriceSlider extends StatefulWidget {
  final Widget child;
  PriceSlider({Key key, this.child}) : super(key: key);

  @override
  _PriceSliderState createState() => _PriceSliderState();
}

class _PriceSliderState extends State<PriceSlider> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
