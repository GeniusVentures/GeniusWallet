import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/wallet_card.g.dart';

class SupportedExistingWallets extends StatelessWidget {
  const SupportedExistingWallets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// TODO: Fetch these dynamically?
    final supportedWallets = [
      {'name': 'Ethereum', 'image': 'assets/images/ellipse1.png'},
      {'name': 'XRP', 'image': 'assets/images/ellipse1.png'},
      {'name': 'Stellar', 'image': 'assets/images/ellipse1.png'},
      {'name': 'Tron', 'image': 'assets/images/ellipse1.png'},
    ];
    return ListView.separated(
      itemCount: supportedWallets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.8,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return WalletCard(
                constraints,
                ovrEllipse1: Image.asset(
                  supportedWallets[index]['image']!,
                  package: 'genius_wallet',
                ),
                ovrEthereum: supportedWallets[index]['name'],
              );
            },
          ),
        );
      },
    );
  }
}
