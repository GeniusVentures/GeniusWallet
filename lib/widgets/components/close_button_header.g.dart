import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/genius_close_button.g.dart';
import 'package:genius_wallet/widgets/components/custom/genius_close_button_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CloseButtonHeader extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrSendBitcoin;
  const CloseButtonHeader(
    this.constraints, {
    Key? key,
    this.ovrSendBitcoin,
  }) : super(key: key);
  @override
  _CloseButtonHeader createState() => _CloseButtonHeader();
}

class _CloseButtonHeader extends State<CloseButtonHeader> {
  _CloseButtonHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 10,
            height: widget.constraints.maxHeight * 1.0,
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 79.0,
                top: 5,
                height: 35.0,
                child: GeniusCloseButtonCustom(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return GeniusCloseButton(
                    constraints,
                    ovrCloseText: 'Close',
                  );
                })),
              ),
              Positioned(
                left: 92.0,
                right: 91.0,
                top: 11.0,
                bottom: 10.0,
                child: Container(
                    height: widget.constraints.maxHeight * 0.4,
                    width: widget.constraints.maxWidth * 0.41533546325878595,
                    child: AutoSizeText(
                      widget.ovrSendBitcoin ?? 'Send Bitcoin',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30000001192092896,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ]),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
