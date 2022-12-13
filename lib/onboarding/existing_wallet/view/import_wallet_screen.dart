import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/onboarding/widgets/supported_existing_wallets.dart';
import 'package:genius_wallet/widgets/components/wallet_card.g.dart';

class ImportWalletScreen extends StatelessWidget {
  const ImportWalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeader(
        title: 'Import Wallet',
        subtitle: 'Select the wallet that you would like to import',
        bodyWidgets: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 100,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: const SupportedExistingWallets(),
          ),
        ],
      ),
    );
  }
}
