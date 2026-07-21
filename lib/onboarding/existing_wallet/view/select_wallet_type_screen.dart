import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_wallet/components/cards/gw_wallet_card.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class SelectWalletTypeScreen extends StatelessWidget {
  const SelectWalletTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

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
      child: Padding(
        // Systemic mobile-gutter fix (carried forward from 06-01, commit
        // 67e2821): ConstrainedBox(maxWidth:) only constrains when the
        // incoming viewport is WIDER than it -- below that width the
        // Padding, wrapped OUTSIDE the ConstrainedBox, supplies the floor
        // inset additively so wide-window centring stays byte-identical.
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space8,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: GeniusBreakpoints.small * 2 / 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20.0,
            children: [
              Text(
                "Import Wallet",
                style: GeniusWalletTypography.headlineLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              Text(
                'Select the wallet that you would like to import',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              ListView.separated(
                itemCount: supportedNetworks.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: GeniusWalletConsts.space10,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final network = supportedNetworks[index];
                  return GWWalletCard(
                    walletIcon: network.image,
                    walletName: network.name,
                    onTap: () {
                      context.read<ExistingWalletBloc>().add(
                        ImportWalletSelected(
                          walletName: supportedNetworks[index].name,
                          coinType: supportedNetworks[index].coinType,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
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
