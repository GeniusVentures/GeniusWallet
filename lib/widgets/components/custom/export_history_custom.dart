import 'package:genius_wallet/widgets/components/export_history.g.dart';

import 'package:flutter/material.dart';

class ExportHistoryCustom extends StatefulWidget {
  final Widget? child;
  ExportHistoryCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _ExportHistoryCustomState createState() => _ExportHistoryCustomState();
}

class _ExportHistoryCustomState extends State<ExportHistoryCustom> {
  @override
  Widget build(BuildContext context) {
    return widget.child ??
        ExportHistory(BoxConstraints(
          maxWidth: 120.0,
          maxHeight: 35.0,
        ));
  }
}
