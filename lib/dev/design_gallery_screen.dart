import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_gradient_border_card.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/effects/gw_mesh_background.dart';
import 'package:genius_wallet/components/inputs/gw_checkbox.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';
import 'package:genius_wallet/components/inputs/gw_switch.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

/// Living catalogue of every component in the GW design system. Reach this
/// screen via the palette icon on the LandingScreen (debug builds only) or by
/// navigating to the `/design_gallery` route directly.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  bool _checkboxA = true;
  bool _checkboxB = false;
  bool _switchA = true;
  bool _switchB = false;
  String? _selectValue = 'eth';
  double _balance = 1234.56;
  final _textCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Design Gallery'),
        backgroundColor: GeniusWalletColors.surfaceElevated,
      ),
      body: ListView(
        padding: const EdgeInsets.all(GeniusWalletConsts.space8),
        children: [
          _Section(
            title: 'Hero balance (animated counter)',
            child: GWGradientBorderCard(
              glass: true,
              glow: true,
              padding: const EdgeInsets.all(GeniusWalletConsts.space10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total balance',
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: GeniusWalletColors.textSecondary,
                      )),
                  const SizedBox(height: GeniusWalletConsts.space4),
                  GWAnimatedNumber(
                    value: _balance,
                    prefix: '\$',
                    decimals: 2,
                  ),
                  const SizedBox(height: GeniusWalletConsts.space6),
                  Row(
                    children: [
                      GWButton(
                        label: 'Random',
                        variant: GWButtonVariant.secondary,
                        size: GWButtonSize.sm,
                        onPressed: () => setState(() {
                          _balance = 100 +
                              (DateTime.now().millisecondsSinceEpoch % 9000)
                                  .toDouble();
                        }),
                      ),
                      const SizedBox(width: GeniusWalletConsts.space4),
                      GWButton(
                        label: 'Reset',
                        variant: GWButtonVariant.ghost,
                        size: GWButtonSize.sm,
                        onPressed: () => setState(() => _balance = 1234.56),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const _Section(
            title: 'Branded loading spinner',
            child: Row(
              children: [
                GWSpinner(),
                SizedBox(width: GeniusWalletConsts.space8),
                GWSpinner(size: 48, strokeWidth: 4),
                SizedBox(width: GeniusWalletConsts.space8),
                GWSpinner(size: 64, strokeWidth: 5),
              ],
            ),
          ),
          const _Section(
            title: 'Brand colors',
            child: _ColorRow(swatches: const [
              _Swatch('Primary', GeniusWalletColors.brandPrimary),
              _Swatch('Primary strong', GeniusWalletColors.brandPrimaryStrong),
              _Swatch('Secondary', GeniusWalletColors.brandSecondary),
              _Swatch(
                  'Secondary strong', GeniusWalletColors.brandSecondaryStrong),
              _Swatch(
                  'Secondary bright', GeniusWalletColors.brandSecondaryBright),
              _Swatch('Tertiary', GeniusWalletColors.brandTertiary),
            ]),
          ),
          const _Section(
            title: 'Surfaces',
            child: _ColorRow(swatches: const [
              _Swatch('Base (canvas)', GeniusWalletColors.surfaceBase),
              _Swatch('Elevated (card)', GeniusWalletColors.surfaceElevated),
              _Swatch('Menu / sheet', GeniusWalletColors.surfaceMenu),
              _Swatch('Sunken', GeniusWalletColors.surfaceSunken),
            ]),
          ),
          const _Section(
            title: 'Status',
            child: _ColorRow(swatches: const [
              _Swatch('Success', GeniusWalletColors.statusSuccess),
              _Swatch('Error', GeniusWalletColors.statusError),
              _Swatch('Warning', GeniusWalletColors.statusWarning),
              _Swatch('Info', GeniusWalletColors.statusInfo),
            ]),
          ),
          const _Section(
            title: 'Gradients',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _GradientSwatch(
                  label: 'brandCta (CTA, green→blue)',
                  gradient: GeniusWalletGradient.brandCta,
                ),
                SizedBox(height: GeniusWalletConsts.space4),
                _GradientSwatch(
                  label: 'brandBorder (cyan→mint, used as outline)',
                  gradient: GeniusWalletGradient.brandBorder,
                ),
                SizedBox(height: GeniusWalletConsts.space4),
                _GradientSwatch(
                  label: 'heroWash (canvas → card)',
                  gradient: GeniusWalletGradient.heroWash,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Typography (Inter)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('displayLg — 32/700', style: GeniusWalletTypography.displayLg),
                Text('displayMd — 28/700', style: GeniusWalletTypography.displayMd),
                Text('headlineLg — 24/600',
                    style: GeniusWalletTypography.headlineLg),
                Text('headlineMd — 20/600',
                    style: GeniusWalletTypography.headlineMd),
                Text('titleLg — 18/600', style: GeniusWalletTypography.titleLg),
                Text('titleMd — 16/500', style: GeniusWalletTypography.titleMd),
                Text('bodyLg — 16/400', style: GeniusWalletTypography.bodyLg),
                Text('bodyMd — 14/400', style: GeniusWalletTypography.bodyMd),
                Text('bodySm — 13/400 (secondary)',
                    style: GeniusWalletTypography.bodySm),
                Text('labelMd — 12/500', style: GeniusWalletTypography.labelMd),
                const SizedBox(height: GeniusWalletConsts.space4),
                Text('1234.5678 — numericDisplay',
                    style: GeniusWalletTypography.numericDisplay),
                Text('1234.5678 — numericHeadline',
                    style: GeniusWalletTypography.numericHeadline),
                Text('1234.5678 — numericBody',
                    style: GeniusWalletTypography.numericBody),
              ],
            ),
          ),
          _Section(
            title: 'Buttons — variants',
            child: Wrap(
              spacing: GeniusWalletConsts.space4,
              runSpacing: GeniusWalletConsts.space4,
              children: [
                GWButton(
                    label: 'Primary',
                    variant: GWButtonVariant.primary,
                    onPressed: () {}),
                GWButton(
                    label: 'Secondary',
                    variant: GWButtonVariant.secondary,
                    onPressed: () {}),
                GWButton(
                    label: 'Tertiary',
                    variant: GWButtonVariant.tertiary,
                    onPressed: () {}),
                GWButton(
                    label: 'Ghost',
                    variant: GWButtonVariant.ghost,
                    onPressed: () {}),
                GWButton(
                    label: 'Destructive',
                    variant: GWButtonVariant.destructive,
                    onPressed: () {}),
                GWButton(
                    label: 'Gradient (signature)',
                    variant: GWButtonVariant.gradient,
                    onPressed: () {}),
                GWButton.icon(
                    icon: const Icon(Icons.favorite_outline),
                    onPressed: () {}),
              ],
            ),
          ),
          _Section(
            title: 'Buttons — sizes (gradient variant)',
            child: Wrap(
              spacing: GeniusWalletConsts.space4,
              runSpacing: GeniusWalletConsts.space4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GWButton(
                  label: 'Small',
                  variant: GWButtonVariant.gradient,
                  size: GWButtonSize.sm,
                  onPressed: () {},
                ),
                GWButton(
                  label: 'Medium',
                  variant: GWButtonVariant.gradient,
                  size: GWButtonSize.md,
                  onPressed: () {},
                ),
                GWButton(
                  label: 'Large',
                  variant: GWButtonVariant.gradient,
                  size: GWButtonSize.lg,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          _Section(
            title: 'Buttons — states',
            child: Wrap(
              spacing: GeniusWalletConsts.space4,
              runSpacing: GeniusWalletConsts.space4,
              children: [
                GWButton(
                  label: 'Loading',
                  variant: GWButtonVariant.primary,
                  isLoading: true,
                  onPressed: () {},
                ),
                const GWButton(
                  label: 'Disabled (primary)',
                  variant: GWButtonVariant.primary,
                  onPressed: null,
                ),
                const GWButton(
                  label: 'Disabled (gradient)',
                  variant: GWButtonVariant.gradient,
                  onPressed: null,
                ),
                GWButton(
                  label: 'Expand',
                  variant: GWButtonVariant.primary,
                  expand: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          _Section(
            title: 'Cards',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GWCard(
                  child: Padding(
                    padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                    child: Text(
                      'Standard GWCard — uses surfaceElevated and the card elevation shadow.',
                      style: GeniusWalletTypography.bodyMd,
                    ),
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWGradientBorderCard(
                  child: Padding(
                    padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GWGradientBorderCard',
                            style: GeniusWalletTypography.titleMd),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          'Hero card with cyan→mint outline. Use for the single most important card on a screen.',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWGradientBorderCard(
                  glow: true,
                  child: Padding(
                    padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GWGradientBorderCard (glow: true)',
                            style: GeniusWalletTypography.titleMd),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          'Adds the dual cyan + mint glow shadow underneath.',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWGradientBorderCard(
                  glass: true,
                  glow: true,
                  child: Padding(
                    padding: const EdgeInsets.all(GeniusWalletConsts.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GWGradientBorderCard (glass: true)',
                            style: GeniusWalletTypography.titleMd),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          'Frosted-glass surface — the mesh background blurs through. Best on hero / featured cards.',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Inputs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GWTextField(
                  controller: _textCtrl,
                  label: 'Wallet name',
                  hint: 'My main wallet',
                  helper: 'Pick something memorable',
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                GWPasswordField(
                  controller: _passCtrl,
                  label: 'Password',
                  hint: 'At least 8 characters',
                ),
                const SizedBox(height: GeniusWalletConsts.space6),
                const GWSearchField(hint: 'Search tokens'),
                const SizedBox(height: GeniusWalletConsts.space6),
                const GWTextField(
                  label: 'With error',
                  hint: 'Type something',
                  errorText: 'This field is required',
                ),
              ],
            ),
          ),
          _Section(
            title: 'Select',
            child: GWSelect<String>(
              value: _selectValue,
              label: 'Network',
              items: const [
                GWSelectItem(value: 'eth', label: 'Ethereum'),
                GWSelectItem(value: 'btc', label: 'Bitcoin'),
                GWSelectItem(value: 'sol', label: 'Solana'),
                GWSelectItem(
                    value: 'pol', label: 'Polygon (disabled)', enabled: false),
              ],
              onChanged: (v) => setState(() => _selectValue = v),
            ),
          ),
          _Section(
            title: 'Checkbox',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GWCheckbox(
                  value: _checkboxA,
                  label: 'I agree to the terms of service',
                  description: 'You can review them at any time in settings.',
                  onChanged: (v) => setState(() => _checkboxA = v ?? false),
                ),
                const SizedBox(height: GeniusWalletConsts.space2),
                GWCheckbox(
                  value: _checkboxB,
                  label: 'Subscribe to product updates',
                  onChanged: (v) => setState(() => _checkboxB = v ?? false),
                ),
                const SizedBox(height: GeniusWalletConsts.space2),
                const GWCheckbox(
                  value: false,
                  label: 'Disabled checkbox',
                  enabled: false,
                  onChanged: null,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Switch',
            child: Column(
              children: [
                GWSwitch(
                  value: _switchA,
                  label: 'Face ID unlock',
                  description: 'Use biometrics instead of PIN.',
                  onChanged: (v) => setState(() => _switchA = v),
                ),
                const SizedBox(height: GeniusWalletConsts.space2),
                GWSwitch(
                  value: _switchB,
                  label: 'Notifications',
                  onChanged: (v) => setState(() => _switchB = v),
                ),
                const SizedBox(height: GeniusWalletConsts.space2),
                const GWSwitch(
                  value: false,
                  label: 'Disabled switch',
                  enabled: false,
                  onChanged: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space20),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers — only used inside the gallery.
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GeniusWalletConsts.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GeniusWalletTypography.headlineMd),
          const SizedBox(height: GeniusWalletConsts.space6),
          child,
        ],
      ),
    );
  }
}

class _Swatch {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.swatches});
  final List<_Swatch> swatches;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: GeniusWalletConsts.space4,
      runSpacing: GeniusWalletConsts.space4,
      children: swatches.map((s) {
        final hex = '#${s.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        return Container(
          width: 132,
          padding: const EdgeInsets.all(GeniusWalletConsts.space4),
          decoration: BoxDecoration(
            color: GeniusWalletColors.surfaceElevated,
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.radiusBase),
            border: Border.all(color: GeniusWalletColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius:
                      BorderRadius.circular(GeniusWalletConsts.radiusXs),
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space2),
              Text(s.label, style: GeniusWalletTypography.labelMd),
              Text(
                hex,
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: GeniusWalletColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GradientSwatch extends StatelessWidget {
  const _GradientSwatch({required this.label, required this.gradient});
  final String label;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GeniusWalletTypography.labelMd),
        const SizedBox(height: GeniusWalletConsts.space2),
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
          ),
        ),
      ],
    );
  }
}
