import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/effects/gw_mesh_background.dart';
import 'package:genius_wallet/dev/mock_mode.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  final bool isIncludeBackButton;
  const LandingScreen({super.key, required this.isIncludeBackButton});

  static const double _maxButtonWidth = 450;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GWMeshBackground(
        intensity: 0.7,
        child: AppScreenView(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space20,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 80,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo_and_title.png',
                    package: 'genius_wallet',
                    semanticLabel: 'GeniusWallet logo',
                  ),
                ),
                if (kDebugMode)
                  Align(
                    alignment: Alignment.topRight,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: GeniusWalletConsts.space2,
                          top: GeniusWalletConsts.space2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GWButton.icon(
                              icon: const Icon(Icons.palette_outlined),
                              tooltip: 'Design gallery (debug)',
                              onPressed: () =>
                                  context.push('/design_gallery'),
                            ),
                            const SizedBox(width: GeniusWalletConsts.space2),
                            GWButton(
                              label: 'Mock',
                              variant: GWButtonVariant.tertiary,
                              size: GWButtonSize.sm,
                              leading: const Icon(Icons.bolt_outlined),
                              tooltip:
                                  'Skip into the dashboard with mock data',
                              onPressed: () => MockMode.enableAndNavigate(
                                context,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: GeniusWalletConsts.space12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _maxButtonWidth,
                          ),
                          child: GWButton(
                            label: 'I already have a wallet',
                            variant: GWButtonVariant.secondary,
                            size: GWButtonSize.lg,
                            expand: true,
                            onPressed: () =>
                                context.push('/import_existing_wallet'),
                          ),
                        ),
                        const SizedBox(height: GeniusWalletConsts.space6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _maxButtonWidth,
                          ),
                          child: GWButton(
                            label: 'Create a new wallet',
                            variant: GWButtonVariant.gradient,
                            size: GWButtonSize.lg,
                            expand: true,
                            onPressed: () => context.push('/create_wallet'),
                          ),
                        ),
                        if (isIncludeBackButton) ...[
                          const SizedBox(height: GeniusWalletConsts.space4),
                          GWButton(
                            label: 'Cancel',
                            variant: GWButtonVariant.ghost,
                            size: GWButtonSize.md,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                        BlocBuilder<AppBloc, AppState>(
                          builder: (context, state) {
                            if (state.ffiString != null) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: GeniusWalletConsts.space4,
                                ),
                                child: Text(
                                  ' ${state.ffiString}',
                                  style: GeniusWalletTypography.bodySm,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
