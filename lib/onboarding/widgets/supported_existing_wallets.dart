import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/components/wallet_card.g.dart';

class SupportedExistingWallets extends StatelessWidget {
  const SupportedExistingWallets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// TODO: Support for other networks - fetch these dynamically?
    final List<SupportedWallet> supportedNetworks = [
      SupportedWallet(
          name: 'Ethereum',
          image: 'assets/images/ethereum_icon.png',
          coinType: TWCoinType.TWCoinTypeEthereum),
      // SupportedWallet(name: 'XRP', image: 'assets/images/xrp_icon.png', coinType: TWCoinType.TWCoinTypeXRP)
      // SupportedWallet(name: 'Stellar', image: 'assets/images/stellar_icon.png', coinType: TWCoinType.TWCoinTypeStellar)
      // SupportedWallet(name: 'Tron', image: 'assets/images/tron_icon.png', coinType: TWCoinType.TWCoinTypeTron)
    ];
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      height: GeniusBreakpoints.useDesktopLayout(context)
          ? (70 * supportedNetworks.length).toDouble()
          : null,
      child: ListView.separated(
        itemCount: supportedNetworks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        physics: const NeverScrollableScrollPhysics(),
        //NOTE: This can be made more efficient by making `shrinkWrap` false but implementing a [CustomScrollview]
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WalletCard(
              walletIcon: supportedNetworks[index].image,
              walletName: supportedNetworks[index].name,
              onTap: () {
                context.read<ExistingWalletBloc>().add(
                      ImportWalletSelected(
                          walletName: supportedNetworks[index].name,
                          coinType: supportedNetworks[index].coinType),
                    );
              },
            ),
          );
        },
      ),
    );
  }
}

class SupportedWallet {
  final String name;
  final String image;
  final int coinType;

  SupportedWallet(
      {required this.name, required this.image, required this.coinType});
}
