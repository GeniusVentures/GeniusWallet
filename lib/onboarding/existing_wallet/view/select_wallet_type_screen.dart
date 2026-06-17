import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class SelectWalletTypeScreen extends StatelessWidget {
  const SelectWalletTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// TODO: Support for other networks - fetch these dynamically?
    final List<SupportedWallet> supportedNetworks = [
      SupportedWallet(
        name: 'Ethereum',
        image: 'assets/images/ethereum_icon.png',
        coinType: TWCoinType.TWCoinTypeEthereum,
      ),
      // SupportedWallet(name: 'XRP', image: 'assets/images/xrp_icon.png', coinType: TWCoinType.TWCoinTypeXRP)
      // SupportedWallet(name: 'Stellar', image: 'assets/images/stellar_icon.png', coinType: TWCoinType.TWCoinTypeStellar)
      // SupportedWallet(name: 'Tron', image: 'assets/images/tron_icon.png', coinType: TWCoinType.TWCoinTypeTron)
    ];

    return Center(
      child: SizedBox(
        width: GeniusBreakpoints.small * 2 / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20.0,
          children: [
            Text(
              "Import Wallet",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text('Select the wallet that you would like to import'),
            ListView.separated(
              itemCount: supportedNetworks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final network = supportedNetworks[index];
                return Card(
                  clipBehavior: Clip.hardEdge,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 20.0,
                    ),
                    leading: Image.asset(
                      network.image,
                      package: 'genius_wallet',
                      height: 30.0,
                      width: 30.0,
                      fit: BoxFit.contain,
                    ),
                    title: Text(network.name),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      context.read<ExistingWalletBloc>().add(
                        ImportWalletSelected(
                          walletName: supportedNetworks[index].name,
                          coinType: supportedNetworks[index].coinType,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SupportedWallet {
  final String name;
  final String image;
  final TWCoinType coinType;

  SupportedWallet({
    required this.name,
    required this.image,
    required this.coinType,
  });
}
