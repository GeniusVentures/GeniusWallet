import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';

class WalletCreationScreen extends StatelessWidget {
  final bool includeBackButton;
  const WalletCreationScreen({super.key, required this.includeBackButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlue,
      body: Center(
        child: SizedBox(
          width: GeniusBreakpoints.small * 2 / 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.0,
            children: [
              Image.asset(
                'assets/images/logo_and_title.png',
                package: 'genius_wallet',
              ),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.push('/import_existing_wallet'),
                  child: const Text('I already have a wallet'),
                ),
              ),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => context.push('/create_wallet'),
                  child: const Text("Create new wallet"),
                ),
              ),
              if (includeBackButton)
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
