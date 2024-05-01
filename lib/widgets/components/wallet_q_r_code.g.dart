import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_q_r_code_custom.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletQRCode extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrWalletID;
  const WalletQRCode(
    this.constraints, {
    Key? key,
    this.ovrWalletID,
  }) : super(key: key);
  @override
  _WalletQRCode createState() => _WalletQRCode();
}

class _WalletQRCode extends State<WalletQRCode> {
  _WalletQRCode();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      WalletQRCodeCustom(
          child: SvgPicture.asset(
        'assets/images/walletqrcodecustom.svg',
        package: 'genius_wallet',
        width: widget.constraints.maxWidth * 0.3409090909090909,
      )),
      AutoSizeText(
        widget.ovrWalletID ?? '3HP94BwsdMHifjdsfJksdndaJhd oopskd',
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
