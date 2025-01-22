import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CryptoAddressQR extends StatelessWidget {
  final String address;
  final String network;
  final AssetImage? icon;

  const CryptoAddressQR(
      {Key? key, required this.address, required this.network, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // QR Code
        QrImageView(
          data: address,
          version: QrVersions.auto,
          size: 280,
          gapless: false,
          backgroundColor: Colors.white,
          embeddedImage: icon,
          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(60, 60)),
        ),
        const SizedBox(height: 32),

        Text(
          "Your $network Address",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        Row(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
              child: AutoSizeText(
            "Use this address to receive tokens",
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          )),
        ])
      ],
    );
  }
}
