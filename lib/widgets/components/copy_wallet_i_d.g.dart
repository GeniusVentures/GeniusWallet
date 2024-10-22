import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/copy_wallet_i_d_custom.dart';

class CopyWalletID extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrCopyWalletLabel;
  final Widget? ovrCopyIcon;
  const CopyWalletID(
    this.constraints, {
    Key? key,
    this.ovrCopyWalletLabel,
    this.ovrCopyIcon,
  }) : super(key: key);
  @override
  _CopyWalletID createState() => _CopyWalletID();
}

class _CopyWalletID extends State<CopyWalletID> {
  _CopyWalletID();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CopyWalletIDCustom(
        child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(
              Icons.copy,
              size: 16,
              color: Colors.white,
            ),
            style: ButtonStyle(
                side: WidgetStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.white)),
                backgroundColor: WidgetStateColor.resolveWith(
                    (states) => GeniusWalletColors.grayPrimary)),
            label: Text(widget.ovrCopyWalletLabel ?? 'Copy',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ))),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
