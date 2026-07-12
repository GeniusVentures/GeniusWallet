import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: GeniusBreakpoints.small * 2 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: GeniusWalletConsts.space6,
          children: [
            Text("Legal", style: Theme.of(context).textTheme.headlineLarge),
            const Text(
              'Please review the privacy policy and terms of service before proceeding.',
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
            CheckboxListTile(
              value: accepted,
              onChanged: (value) => onToggle(),
              title: AutoSizeText(
                'I\'ve read and accept the Terms of Service and Privacy Policy',
              ),
              controlAffinity: ListTileControlAffinity.leading,
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
    );
  }
}
