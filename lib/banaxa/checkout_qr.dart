import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class CheckoutQrPage extends StatelessWidget {
  final String checkoutUrl;

  const CheckoutQrPage({
    super.key,
    required this.checkoutUrl,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final qrSize = math.max(160.0, math.min(320.0, w - 64));

    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Continue')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Scan this QR on another device to complete checkout.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: QrImageView(
                        data: checkoutUrl,
                        version: QrVersions.auto,
                        size: qrSize,
                        gapless: false,
                        dataModuleStyle: const QrDataModuleStyle(
                          color: Colors.black,
                          dataModuleShape: QrDataModuleShape.square,
                        ),
                        eyeStyle: const QrEyeStyle(
                          color: Colors.black,
                          eyeShape: QrEyeShape.square,
                        ),
                        errorStateBuilder: (c, err) => const SizedBox(
                          width: 200,
                          child: Center(child: Text('Could not generate QR')),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    checkoutUrl,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: checkoutUrl));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link copied')),
                              );
                            }
                          },
                          icon: const Icon(Icons.content_copy),
                          label: const Text('Copy Link'),
                        ),
                      ),
                      const SizedBox(width: 12),
                     
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
