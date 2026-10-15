import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_checkbox.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:url_launcher/url_launcher.dart';

final _termsUri = Uri.parse('https://banxa.com/terms-of-use/');
final _privacyUri = Uri.parse('https://banxa.com/privacy-and-cookies-policy/');

/// Resolves true only when the user ticks the box and taps Continue; Cancel and
/// a dismissed dialog resolve false. [sandboxHost] adds a sandbox note.
Future<bool> showDisclaimerDialog(
  BuildContext context, {
  String? sandboxHost,
}) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierColor: context.gw.surfaceOverlay,
    builder: (_) => _FirstBuyDialog(sandboxHost: sandboxHost),
  );
  return accepted ?? false;
}

class _FirstBuyDialog extends StatefulWidget {
  const _FirstBuyDialog({this.sandboxHost});

  final String? sandboxHost;

  @override
  State<_FirstBuyDialog> createState() => _FirstBuyDialogState();
}

class _FirstBuyDialogState extends State<_FirstBuyDialog> {
  bool _agreed = false;

  void _toggle() => setState(() => _agreed = !_agreed);

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final sandboxHost = widget.sandboxHost;
    return GWDialog(
      title: 'Before your first buy',
      actions: [
        GWDialogAction(
          label: 'Cancel',
          variant: GWButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GWDialogAction(
          label: 'Continue',
          variant: GWButtonVariant.primary,
          onPressed: _agreed ? () => Navigator.of(context).pop(true) : null,
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Banxa, a separate company, handles this purchase.',
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          const _Point(
            icon: Icons.credit_card_outlined,
            text: 'You pay and verify your ID with Banxa.',
          ),
          const _Point(
            icon: Icons.lock_outline,
            text: 'Your card and ID details go to Banxa, not GeniusWallet.',
          ),
          const _Point(
            icon: Icons.open_in_browser_outlined,
            text: 'Checkout opens inside the app.',
          ),
          if (sandboxHost != null) ...[
            const SizedBox(height: GeniusWalletConsts.space4),
            Text(
              'Sandbox · $sandboxHost',
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: GeniusWalletConsts.space6),
          Semantics(
            container: true,
            checked: _agreed,
            onTap: _toggle,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: _toggle,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The checkbox box sits a few px inside its tap area; shift it left so the
                  // visible box lines up with the text column above.
                  SizedBox(
                    width: 26,
                    height: 48,
                    child: Transform.translate(
                      offset: const Offset(-GeniusWalletConsts.space2, 0),
                      child: ExcludeSemantics(
                        child: GWCheckbox(
                          value: _agreed,
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: GeniusWalletConsts.space4,
                      ),
                      child: Text.rich(
                        style: GeniusWalletTypography.bodyMd.copyWith(
                          color: gw.textPrimary,
                        ),
                        TextSpan(
                          children: [
                            const TextSpan(text: "I agree to Banxa's "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: _InlineLink(
                                label: 'Terms of Use',
                                uri: _termsUri,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: _InlineLink(
                                label: 'Privacy Policy',
                                uri: _privacyUri,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.only(bottom: GeniusWalletConsts.space6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: gw.brandPrimaryOnSurface),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: Text(
              text,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineLink extends StatelessWidget {
  const _InlineLink({required this.label, required this.uri});

  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    void open() => launchUrl(uri, mode: LaunchMode.externalApplication);
    return Semantics(
      container: true,
      link: true,
      label: label,
      onTap: open,
      excludeSemantics: true,
      child: InkWell(
        onTap: open,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusXs),
        child: Text(
          label,
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: gw.brandPrimaryOnSurface,
            decoration: TextDecoration.underline,
            decorationColor: gw.brandPrimaryOnSurface,
          ),
        ),
      ),
    );
  }
}
