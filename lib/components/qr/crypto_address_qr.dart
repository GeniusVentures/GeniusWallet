import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/components/button/copy_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CryptoAddressQR extends StatelessWidget {
  final String address;
  final String network;
  final String? iconPath;

  const CryptoAddressQR({
    super.key,
    required this.address,
    required this.network,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: address,
          version: QrVersions.auto,
          // §4.4 always-light exception + finding 16/6: a SOLID light backing in
          // BOTH appearance modes so the default-black QR modules stay scannable
          // by a phone camera over the dark drawer. NEVER an appearance token.
          backgroundColor: Colors.white,
          embeddedImage: AssetImage(iconPath ?? ""),
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(60, 60)),
        ),
        const SizedBox(height: GeniusWalletConsts.space16),
        Text(
          "Your $network Address",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        Text("Use this address to receive tokens.", maxLines: 1),
        const SizedBox(height: GeniusWalletConsts.space16),
        CopyButton(
          buttonText: WalletUtils.getAddressForDisplay(address),
          textToCopy: address,
        ),
      ],
    );
  }
}
