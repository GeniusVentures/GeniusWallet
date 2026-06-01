import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/components/button/copy_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CryptoAddressQR extends StatelessWidget {
  final String address;
  final String network;
  final String? iconPath;

  const CryptoAddressQR(
      {super.key, required this.address, required this.network, this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: address,
          version: QrVersions.auto,
          backgroundColor: GeniusWalletColors.white.withValues(alpha: 0.6),
          embeddedImage: AssetImage(iconPath ?? ""),
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(60, 60)),
        ),
        const SizedBox(height: 32),
        Text(
          "Your $network Address",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          "Use this address to receive tokens.",
          maxLines: 1,
        ),
        const SizedBox(height: 32),
        CopyButton(
            buttonText: WalletUtils.getAddressForDisplay(address),
            textToCopy: address)
      ],
    );
  }
}
