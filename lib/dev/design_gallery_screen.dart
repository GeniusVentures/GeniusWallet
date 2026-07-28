import 'package:flutter/material.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/bottom_drawer/bottom_drawer.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/buttons/gw_swap_fab.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_gradient_border_card.dart';
import 'package:genius_wallet/components/cards/gw_token_row.dart';
import 'package:genius_wallet/components/cards/gw_wallet_card.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/effects/gw_mesh_background.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/feedback/gw_loading_state.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/components/inputs/gw_checkbox.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';
import 'package:genius_wallet/components/inputs/gw_switch.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
// SHADOW IMPORT -- see
// .planning/phases/03-gw-component-library/03-SHADOW-NAMES.md. This gallery
// is the ONLY permitted importer of the `Loading` shadow (this path). Develop's
// canonical `Loading` (lib/components/loading.dart, 19 importers) is what every
// real caller uses; this section exists so a human can see that the duplicate
// is a DIFFERENT widget (Phase 2 tokens vs raw values) -- the evidence that
// makes the shadow hazard concrete rather than theoretical.
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/components/overlays/gw_bottom_sheet.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
// SHADOW IMPORT -- see
// .planning/phases/03-gw-component-library/03-SHADOW-NAMES.md. This gallery
// is the ONLY permitted importer of the `Splash` shadow (this path). Develop's
// canonical `Splash` (lib/screens/splash.dart, routed from router.dart:30) is
// the real boot screen; this shadow is a StatefulWidget Alex's source branch
// tried to present as a completed move -- it is not. This section exists only
// so the duplicate is visibly a different widget, never as a replacement boot
// path.
import 'package:genius_wallet/components/splash.dart';
import 'package:genius_wallet/dev/generated_closure_canary.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Living catalogue of every component in the GW design system. Reach this
/// screen via the `Gallery` button in the `Dev` row inside `DevToolsWidget`
/// (`lib/test/dev_tools_widget.dart`), gated by `kShowDevTools`
/// (`lib/dev/dev_flags.dart`), which routes to `/design_gallery`
/// (`lib/navigation/router.dart`). Unreachable without
/// `--dart-define=GW_DEV_TOOLS=true` on a debug build.
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
  void initState() {
    super.initState();
    // Same mechanism as lib/dev/token_probe_screen.dart -- restores the
    // persisted appearance mode so re-entering the gallery reflects it.
    GWAppearance.instance.load();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder is load-bearing (Phase 2 plan 02-05's trap):
    // without it, GWAppearance.instance.setMode() persists but nothing
    // rebuilds and the toggle looks broken.
    return ValueListenableBuilder<GWAppearanceMode>(
      valueListenable: GWAppearance.instance,
      builder: (context, mode, _) {
        final isLight = GWAppearance.isLight;
        // Fail-soft read: resolves the const GWIcon.material call site's
        // color from the GWColors extension instead of the static getter
        // (pure access-path change; this builder already rebuilds on toggle
        // via ValueListenableBuilder, so this keeps that call site consistent
        // with the migrated components below rather than changing behavior).
        final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
        return Scaffold(
          // This is a standalone route (router.dart /design_gallery) with nothing
          // painting behind it, so the Scaffold must supply its own canvas. 04-01
          // briefly set this to Colors.transparent (matching Alex's reference,
          // whose gallery sits on a root background develop does not have) -- that
          // showed the dark void in light mode instead of flipping. Omitting
          // backgroundColor inherits the now-appearance-aware theme's
          // scaffoldBackgroundColor: surfaceBase, so the canvas flips with the
          // toggle. (D-02 re-walk finding.)
          appBar: AppBar(
            title: const Text('Design Gallery'),
            backgroundColor: GeniusWalletColors.surfaceElevated,
            actions: [
              IconButton(
                tooltip: isLight ? 'Switch to dark' : 'Switch to light',
                icon: Icon(
                  isLight
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                onPressed: () => GWAppearance.instance.setMode(
                  isLight ? GWAppearanceMode.dark : GWAppearanceMode.light,
                ),
              ),
            ],
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
                      Text(
                        'Total balance',
                        style: GeniusWalletTypography.labelMd.copyWith(
                          color: GeniusWalletColors.textSecondary,
                        ),
                      ),
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
                              _balance =
                                  100 +
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
                child: _ColorRow(
                  swatches: const [
                    _Swatch('Primary', GeniusWalletColors.brandPrimary),
                    _Swatch(
                      'Primary strong',
                      GeniusWalletColors.brandPrimaryStrong,
                    ),
                    _Swatch('Secondary', GeniusWalletColors.brandSecondary),
                    _Swatch(
                      'Secondary strong',
                      GeniusWalletColors.brandSecondaryStrong,
                    ),
                    _Swatch(
                      'Secondary bright',
                      GeniusWalletColors.brandSecondaryBright,
                    ),
                    _Swatch('Tertiary', GeniusWalletColors.brandTertiary),
                  ],
                ),
              ),
              _Section(
                title: 'Surfaces',
                child: _ColorRow(
                  swatches: [
                    _Swatch('Base (canvas)', GeniusWalletColors.surfaceBase),
                    _Swatch(
                      'Elevated (card)',
                      GeniusWalletColors.surfaceElevated,
                    ),
                    _Swatch('Menu / sheet', GeniusWalletColors.surfaceMenu),
                    _Swatch('Sunken', GeniusWalletColors.surfaceSunken),
                  ],
                ),
              ),
              const _Section(
                title: 'Status',
                child: _ColorRow(
                  swatches: const [
                    _Swatch('Success', GeniusWalletColors.statusSuccess),
                    _Swatch('Error', GeniusWalletColors.statusError),
                    _Swatch('Warning', GeniusWalletColors.statusWarning),
                    _Swatch('Info', GeniusWalletColors.statusInfo),
                  ],
                ),
              ),
              _Section(
                title: 'Gradients',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _GradientSwatch(
                      label: 'brandCta (CTA, green→blue)',
                      gradient: GeniusWalletGradient.brandCta,
                    ),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    const _GradientSwatch(
                      label: 'brandBorder (cyan→mint, used as outline)',
                      gradient: GeniusWalletGradient.brandBorder,
                    ),
                    const SizedBox(height: GeniusWalletConsts.space4),
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
                    Text(
                      'displayLg — 32/700',
                      style: GeniusWalletTypography.displayLg,
                    ),
                    Text(
                      'displayMd — 28/700',
                      style: GeniusWalletTypography.displayMd,
                    ),
                    Text(
                      'headlineLg — 24/600',
                      style: GeniusWalletTypography.headlineLg,
                    ),
                    Text(
                      'headlineMd — 20/600',
                      style: GeniusWalletTypography.headlineMd,
                    ),
                    Text(
                      'titleLg — 18/600',
                      style: GeniusWalletTypography.titleLg,
                    ),
                    Text(
                      'titleMd — 16/500',
                      style: GeniusWalletTypography.titleMd,
                    ),
                    Text(
                      'bodyLg — 16/400',
                      style: GeniusWalletTypography.bodyLg,
                    ),
                    Text(
                      'bodyMd — 14/400',
                      style: GeniusWalletTypography.bodyMd,
                    ),
                    Text(
                      'bodySm — 13/400 (secondary)',
                      style: GeniusWalletTypography.bodySm,
                    ),
                    Text(
                      'labelMd — 12/500',
                      style: GeniusWalletTypography.labelMd,
                    ),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    Text(
                      '1234.5678 — numericDisplay',
                      style: GeniusWalletTypography.numericDisplay,
                    ),
                    Text(
                      '1234.5678 — numericHeadline',
                      style: GeniusWalletTypography.numericHeadline,
                    ),
                    Text(
                      '1234.5678 — numericBody',
                      style: GeniusWalletTypography.numericBody,
                    ),
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
                      onPressed: () {},
                    ),
                    GWButton(
                      label: 'Secondary',
                      variant: GWButtonVariant.secondary,
                      onPressed: () {},
                    ),
                    GWButton(
                      label: 'Tertiary',
                      variant: GWButtonVariant.tertiary,
                      onPressed: () {},
                    ),
                    GWButton(
                      label: 'Ghost',
                      variant: GWButtonVariant.ghost,
                      onPressed: () {},
                    ),
                    GWButton(
                      label: 'Destructive',
                      variant: GWButtonVariant.destructive,
                      onPressed: () {},
                    ),
                    GWButton(
                      label: 'Gradient (signature)',
                      variant: GWButtonVariant.gradient,
                      onPressed: () {},
                    ),
                    GWButton.icon(
                      icon: const Icon(Icons.favorite_outline),
                      onPressed: () {},
                    ),
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
                        padding: const EdgeInsets.all(
                          GeniusWalletConsts.space4,
                        ),
                        child: Text(
                          'Standard GWCard — uses surfaceElevated and the card elevation shadow.',
                          style: GeniusWalletTypography.bodyMd,
                        ),
                      ),
                    ),
                    const SizedBox(height: GeniusWalletConsts.space6),
                    GWGradientBorderCard(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          GeniusWalletConsts.space4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GWGradientBorderCard',
                              style: GeniusWalletTypography.titleMd,
                            ),
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
                        padding: const EdgeInsets.all(
                          GeniusWalletConsts.space4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GWGradientBorderCard (glow: true)',
                              style: GeniusWalletTypography.titleMd,
                            ),
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
                        padding: const EdgeInsets.all(
                          GeniusWalletConsts.space4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GWGradientBorderCard (glass: true)',
                              style: GeniusWalletTypography.titleMd,
                            ),
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
                      value: 'pol',
                      label: 'Polygon (disabled)',
                      enabled: false,
                    ),
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
                      description:
                          'You can review them at any time in settings.',
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
              _Section(
                title: 'Canvas background (noise texture)',
                child: SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusLg,
                    ),
                    child: GWCanvasBackground(
                      child: Center(
                        child: Text(
                          'GWCanvasBackground — first instantiation in this '
                          'repo. Consumes assets/images/textures/noise.png '
                          '(DS-04). The grain overlay only renders in dark '
                          'mode — toggle appearance to compare.',
                          textAlign: TextAlign.center,
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: GeniusWalletColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Mesh background (procedural, no texture asset)',
                child: SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusLg,
                    ),
                    child: GWMeshBackground(
                      child: Center(
                        child: Text(
                          'GWMeshBackground — animated CustomPaint blobs, no '
                          'asset dependency. Distinct from GWCanvasBackground '
                          'above, which is the actual noise.png consumer.',
                          textAlign: TextAlign.center,
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: GeniusWalletColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Icons',
                child: Wrap(
                  spacing: GeniusWalletConsts.space10,
                  runSpacing: GeniusWalletConsts.space6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GWIcon.material(
                          Icons.account_balance_wallet_outlined,
                          color: gw.textPrimary,
                        ),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          'GWIcon.material',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // packages/genius_wallet/assets/images/shape.svg is
                        // declared in pubspec.yaml -- matches GWIcon.svg's default
                        // package: 'genius_wallet'.
                        const GWIcon.svg('assets/images/shape.svg'),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          'GWIcon.svg',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // packages/genius_wallet/assets/images/mask2.png is
                        // declared in pubspec.yaml -- matches GWIcon.png's default
                        // package: 'genius_wallet'.
                        const GWIcon.png('assets/images/mask2.png'),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          'GWIcon.png',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Token row',
                child: Column(
                  children: [
                    const GWTokenRow(
                      symbol: 'ETH',
                      name: 'Ethereum',
                      iconAsset: 'assets/images/crypto/eth.png',
                      balance: '1.2345',
                      subBalance: '\$3,210.00',
                    ),
                    const SizedBox(height: GeniusWalletConsts.space2),
                    const GWTokenRow(
                      symbol: 'XYZ',
                      name: 'Broken asset path (fallback dot)',
                      iconAsset: 'assets/images/crypto/does_not_exist.png',
                      balance: '0.0000',
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Wallet card',
                child: Column(
                  children: [
                    const GWWalletCard(walletName: 'Ethereum'),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    const GWWalletCard(
                      walletName: 'Bitcoin (no trailing arrow)',
                      showArrow: false,
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Swap FAB',
                child: GWSwapFab(onPressed: () {}),
              ),
              _Section(
                title: 'Empty / Error / Loading states',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const GWEmptyState(title: 'No transactions yet'),
                    const SizedBox(height: GeniusWalletConsts.space8),
                    const GWErrorState(),
                    const SizedBox(height: GeniusWalletConsts.space6),
                    const GWErrorBanner(message: 'Network request failed.'),
                    const SizedBox(height: GeniusWalletConsts.space6),
                    const GWLoadingState(message: 'Loading balances…'),
                  ],
                ),
              ),
              _Section(
                title: 'Screen wrappers',
                // AppScreenView (SafeArea + CustomScrollView body/footer wrapper)
                // overlaps GWScreen (components/scaffold/gw_screen.dart) by design
                // -- UI-SPEC §2.5. Neither is "the" canonical wrapper here; this
                // section only proves AppScreenView instantiates and lays out
                // without swallowing the gallery page, in a constrained box.
                child: SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusLg,
                    ),
                    child: AppScreenView(
                      body: Padding(
                        padding: const EdgeInsets.all(
                          GeniusWalletConsts.space6,
                        ),
                        child: Text(
                          'AppScreenView — SafeArea + CustomScrollView body/'
                          'footer wrapper. GWScreen overlaps this by design '
                          '(UI-SPEC §2.5).',
                          style: GeniusWalletTypography.bodySm,
                        ),
                      ),
                      footer: Padding(
                        padding: const EdgeInsets.all(
                          GeniusWalletConsts.space4,
                        ),
                        child: Text(
                          'Footer slot',
                          style: GeniusWalletTypography.labelMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Dialog / Bottom sheet',
                // Both orphaned/non-canonical -- ResponsiveDrawer (see "Drawer"
                // below) is the canonical modal pattern (UI-SPEC §6.3).
                child: Wrap(
                  spacing: GeniusWalletConsts.space4,
                  runSpacing: GeniusWalletConsts.space4,
                  children: [
                    GWButton(
                      label: 'GWDialog.show() (orphaned)',
                      variant: GWButtonVariant.secondary,
                      onPressed: () => GWDialog.show(
                        context: context,
                        title: 'GWDialog',
                        message:
                            'Orphaned/non-canonical — ResponsiveDrawer is '
                            'the canonical modal pattern.',
                        actions: [
                          GWDialogAction(
                            label: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    GWButton(
                      label: 'GWBottomSheet.show() (orphaned)',
                      variant: GWButtonVariant.secondary,
                      onPressed: () => GWBottomSheet.show(
                        context: context,
                        title: 'GWBottomSheet',
                        child: Padding(
                          padding: const EdgeInsets.all(
                            GeniusWalletConsts.space6,
                          ),
                          child: Text(
                            'Orphaned/non-canonical — ResponsiveDrawer is the '
                            'canonical modal pattern.',
                            style: GeniusWalletTypography.bodyMd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Loading (duplicate)',
                child: const Loading(text: 'Shadow Loading — Phase 2 tokens'),
              ),
              _Section(
                title: 'Splash (duplicate)',
                child: SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusLg,
                    ),
                    // Splash sizes its inner content off MediaQuery.sizeOf(context),
                    // not off its own BoxConstraints -- override the ambient
                    // MediaQuery so it fits this demo box instead of assuming the
                    // full window. Splash.dart itself is untouched.
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(size: const Size(320, 220)),
                      child: const Splash(),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Drawer',
                // Findings 13/25/26 -- opened via develop's existing,
                // unmodified ResponsiveDrawer.show(), never Alex's
                // regressed responsive_drawer.dart. title/actions are
                // deliberately omitted so _ResponsiveDrawerScaffold
                // renders no AppBar competing with BottomDrawer's own
                // header (UI-SPEC §4.1).
                child: GWButton(
                  label: 'Open drawer demo',
                  variant: GWButtonVariant.secondary,
                  onPressed: () => ResponsiveDrawer.show(
                    context: context,
                    child: BottomDrawer(
                      title: 'Drawer demo',
                      children: List.generate(
                        20,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: GeniusWalletConsts.space2,
                          ),
                          child: Text(
                            'Row $i — scroll to confirm the drawer scrolls '
                            'independently.',
                            style: GeniusWalletTypography.bodyMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'QR',
                // Finding 16 -- the quiet zone must stay LIGHT in both
                // appearance modes; develop's crypto_address_qr.dart is
                // theme-invariant and untouched here.
                child: const CryptoAddressQR(
                  address: '0x1234567890abcdef1234567890abcdef12345678',
                  network: 'Ethereum',
                  iconPath: 'assets/images/crypto/eth.png',
                ),
              ),
              _Section(
                title: 'Error state with retry',
                // Finding 15 -- both a custom message AND onRetry are
                // supplied, so the Retry button's presence alongside
                // custom content is observable.
                child: GWErrorState(
                  message:
                      'Could not load your balances. Check your connection '
                      'and try again.',
                  onRetry: () {},
                ),
              ),
              _Section(
                title: 'Generated widget closure canary',
                child: Text(
                  '${generatedClosureClasses.length} generated widgets in '
                  'closure (lib/dev/generated_closure_canary.dart) — compiled '
                  'by the Dart front-end via this import, never mounted.',
                  style: GeniusWalletTypography.bodyMd,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space20),
            ],
          ),
        );
      },
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
        final hex =
            '#${s.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
        return Container(
          width: 132,
          padding: const EdgeInsets.all(GeniusWalletConsts.space4),
          decoration: BoxDecoration(
            gradient: GWDecorations.surfaceSheen,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusBase),
            border: Border.all(color: GeniusWalletColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusXs,
                  ),
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
