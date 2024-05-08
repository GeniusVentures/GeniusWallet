import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/export_history_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ExportHistory extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrExportHistory;
  const ExportHistory(
    this.constraints, {
    Key? key,
    this.ovrExportHistory,
  }) : super(key: key);
  @override
  _ExportHistory createState() => _ExportHistory();
}

class _ExportHistory extends State<ExportHistory> {
  _ExportHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: ExportHistoryCustom(
            child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth,
            top: 0,
            height: widget.constraints.maxHeight,
            child: Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  height: widget.constraints.maxHeight,
                  width: widget.constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: GeniusWalletColors.grayPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              Positioned(
                left: 9.0,
                width: 102.0,
                top: 12.0,
                height: 15.0,
                child: Container(
                    height: 15.0,
                    width: 102.0,
                    child: AutoSizeText(
                      widget.ovrExportHistory ?? 'Export History',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.48750001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ]),
          ),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
