import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/effects/gw_mesh_background.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';

class WalletCreationScreen extends StatelessWidget {
  final bool includeBackButton;
  const WalletCreationScreen({super.key, required this.includeBackButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GWMeshBackground(
        intensity: 0.7,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: GeniusBreakpoints.small * 2 / 3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16.0,
              children: [
                Image.asset(
                  'assets/images/logo_and_title.png',
                  package: 'genius_wallet',
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: GWButton(
                    label: 'I already have a wallet',
                    variant: GWButtonVariant.secondary,
                    size: GWButtonSize.lg,
                    expand: true,
                    onPressed: () => context.push('/import_existing_wallet'),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: GWButton(
                    label: 'Create new wallet',
                    variant: GWButtonVariant.gradient,
                    size: GWButtonSize.lg,
                    expand: true,
                    onPressed: () => context.push('/create_wallet'),
                  ),
                ),
                if (includeBackButton)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 50),
                    child: GWButton(
                      label: 'Cancel',
                      variant: GWButtonVariant.ghost,
                      size: GWButtonSize.md,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
