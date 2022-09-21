import 'package:genius_wallet/widgets/components/date_selector.g.dart';

import 'package:flutter/material.dart';

class DateSelectorCustom extends StatefulWidget {
  final Widget? child;
  DateSelectorCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DateSelectorCustomState createState() => _DateSelectorCustomState();
}

class _DateSelectorCustomState extends State<DateSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        DateSelector(BoxConstraints(
          maxWidth: 271.0,
          maxHeight: 21.0,
        ));
  }
}
