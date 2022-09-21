// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/mobile/custom/wallet_address_logic.dart';
import 'package:genius_wallet/widgets/mobile/wallet_address_widget.g.dart';

class WalletAddress extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWalletAddresshinttext;
  const WalletAddress(
    this.constraints, {
    Key? key,
    this.ovrWalletAddresshinttext,
  }) : super(key: key);
  @override
  _WalletAddress createState() => _WalletAddress();
}

class _WalletAddress extends State<WalletAddress> {
  _WalletAddress();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Stack(children: [
          Positioned(
            left: 0,
            width: widget.constraints.maxWidth * 1.0,
            top: 0,
            height: widget.constraints.maxHeight * 1.0,
            child: WalletAddressWidget(),
          ),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
