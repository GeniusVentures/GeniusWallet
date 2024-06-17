import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class Status extends StatefulWidget {
  final BoxConstraints constraints;
  final String? status;
  final Color? color;
  final Color? textColor;
  final Icon? icon;
  const Status(this.constraints,
      {Key? key, this.status, this.color, this.textColor, this.icon})
      : super(key: key);
  @override
  _Status createState() => _Status();
}

class _Status extends State<Status> {
  _Status();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: widget.color ?? const Color(0xff78797e),
        borderRadius: const BorderRadius.all(
            Radius.circular(GeniusWalletConsts.borderRadiusButton)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        AutoSizeText(
          widget.status ?? 'Pending',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.30000001192092896,
            color: widget.textColor ?? Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        widget.icon ?? const Icon(Icons.lock_clock),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
