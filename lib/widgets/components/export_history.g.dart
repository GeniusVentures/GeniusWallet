// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
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
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 120.0,
                top: 0,
                height: 35.0,
                child: Container(
                  height: 35.0,
                  width: 120.0,
                  decoration: BoxDecoration(
                    color: Color(0xff2a2b31),
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
              ),
              Positioned(
                left: 9.0,
                width: 102.0,
                top: 10.0,
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
