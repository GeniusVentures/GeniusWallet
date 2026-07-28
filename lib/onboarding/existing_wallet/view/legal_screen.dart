import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_checkbox.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';

class LegalScreen extends StatelessWidget {
  final bool accepted;
  final VoidCallback onToggle;
  final VoidCallback onContinue;

  const LegalScreen({
    super.key,
    required this.accepted,
    required this.onToggle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
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
          constraints: const BoxConstraints(
            maxWidth: GeniusBreakpoints.small * 2 / 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20.0,
            children: [
              Text(
                "Legal",
                style: GeniusWalletTypography.headlineLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              Text(
                'Please review the privacy policy and terms of service before proceeding.',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              GWButton(
                label: 'Privacy Policy',
                variant: GWButtonVariant.secondary,
                size: GWButtonSize.lg,
                expand: true,
                onPressed: () => launchWebSite(
                  context,
                  'https://www.gnus.ai/privacypolicy.html',
                ),
              ),
              GWButton(
                label: 'Terms of Service',
                variant: GWButtonVariant.secondary,
                size: GWButtonSize.lg,
                expand: true,
                onPressed: () =>
                    launchWebSite(context, 'https://www.gnus.ai/tos.html'),
              ),
              GWCheckbox(
                value: accepted,
                onChanged: (_) => onToggle(),
                label:
                    "I've read and accept the Terms of Service and Privacy Policy",
              ),
              GWButton(
                label: 'Continue',
                variant: GWButtonVariant.gradient,
                size: GWButtonSize.lg,
                expand: true,
                onPressed: accepted ? onContinue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
