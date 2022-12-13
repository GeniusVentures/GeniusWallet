import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/wallet_card.g.dart';

class SupportedExistingWallets extends StatelessWidget {
  const SupportedExistingWallets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// TODO: Fetch these dynamically?
    final supportedWallets = [
      {'name': 'Ethereum', 'image': 'assets/images/ethereum_icon.png'},
      {'name': 'XRP', 'image': 'assets/images/xrp_icon.png'},
      {'name': 'Stellar', 'image': 'assets/images/stellar_icon.png'},
      {'name': 'Tron', 'image': 'assets/images/tron_icon.png'},
    ];
    return ListView.separated(
      itemCount: supportedWallets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MaterialButton(
          onPressed: () {
            context.read<ExistingWalletBloc>().add(
                  ImportWalletSelected(
                    walletName: supportedWallets[index]['name']!,
                  ),
                );
          },
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.8,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return WalletCard(
                  constraints,
                  ovrEllipse1: Image.asset(
                    supportedWallets[index]['image']!,
                  ),
                  ovrEthereum: supportedWallets[index]['name'],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
