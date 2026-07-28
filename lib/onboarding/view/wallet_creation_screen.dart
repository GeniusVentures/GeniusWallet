import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/effects/gw_mesh_background.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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
          // Walk-driven fix (Task 3, Rule 1): maxWidth only constrains when
          // the viewport is WIDER than it -- once the window is narrower
          // than `small * 2/3`, the ConstrainedBox alone is inert and the
          // stretch column runs edge-to-edge with zero gutter. This
          // symmetric Padding, wrapped OUTSIDE the ConstrainedBox, supplies
          // a floor inset that applies in addition to (never instead of)
          // the existing max-width centring -- see 06-01-SUMMARY.md for the
          // full before/after constraint-math justification.
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space8,
            ),
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
      ),
    );
  }
}
