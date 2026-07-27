import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/squid_router/slippage_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/formatters.dart';

/// Swap settings — sketch 063 variant A, the "form" drawer archetype.
///
/// Sketches 030-034 gave every other drawer shape an archetype (shell, receipt,
/// list, confirm, receive); the form was the one nobody had designed, which is
/// why this drawer was a bare labelled `TextField` in an otherwise empty panel.
///
/// Variant A's premise: presets are the primary path and the field is the
/// escape hatch. Someone opening this is choosing a posture — "tight" or
/// "loose" — not tuning a number, and the old panel asked them to invent one
/// with no idea what was reasonable.
class SwapSettingsDrawer {
  static void show(
    BuildContext context, {
    required double initialSlippage,
    required ValueChanged<double> onSlippageChanged,
  }) {
    final controller = TextEditingController(text: _trim(initialSlippage));

    // Apply belongs in the shell's footer (030-B1: a footer with a top
    // border), not inline under the field — every other drawer pins its
    // primary action there, and once this form grows past one setting the
    // body scrolls and an inline button scrolls away with it.
    //
    // The footer is a SIBLING of the body, so it cannot read the form's
    // State. That is precisely why the old drawer's Apply was live even when
    // the value would not parse. One notifier, written by the field and read
    // by both halves, is the smallest thing that keeps them agreeing.
    final raw = ValueNotifier<String>(controller.text);
    controller.addListener(() => raw.value = controller.text);

    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Swap Settings',
      child: _SlippageForm(controller: controller),
      footer: _ApplyFooter(
        raw: raw,
        onApply: (value) {
          onSlippageChanged(value);
          // `context` here is the CALLER's — the swap screen's — captured when
          // the drawer was opened. The swap screen lives inside the shell's
          // nested Navigator (`router.dart` ShellRoute), while
          // `ResponsiveDrawer.show` pushes on the ROOT navigator
          // (`useRootNavigator: true`). Without `rootNavigator: true` this pop
          // resolved to the shell's navigator and popped the SWAP ROUTE —
          // Apply dropped the user on the dashboard instead of closing the
          // drawer. The token picker never had this bug because it pops with a
          // context from inside the drawer.
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      // Both are created here, so both are disposed here — when the route is
      // gone, not when either half unmounts.
    ).whenComplete(() {
      controller.dispose();
      raw.dispose();
    });
  }

  /// `0.5` not `0.50`, and `1` not `1.0` — the presets are round numbers and
  /// the field should echo them back the way they were offered.
  static String _trim(double v) =>
      v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}

class _ApplyFooter extends StatelessWidget {
  const _ApplyFooter({required this.raw, required this.onApply});

  final ValueNotifier<String> raw;
  final ValueChanged<double> onApply;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return ValueListenableBuilder<String>(
      valueListenable: raw,
      builder: (context, value, _) {
        final state = slippageState(value);
        return Container(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: gw.borderSubtle, width: 1)),
          ),
          child: GWButton(
            variant: GWButtonVariant.gradient,
            size: GWButtonSize.lg,
            expand: true,
            label: 'Apply',
            // The old Apply was always live and silently did nothing when the
            // value would not parse. Refusing is only honest if the control
            // says so.
            onPressed: state.canApply ? () => onApply(state.value!) : null,
          ),
        );
      },
    );
  }
}

/// Stateful only for its own repaint: the preset selection, the field border
/// and the message all read the same validation on every keystroke. The
/// controller is owned by [SwapSettingsDrawer.show] because the footer needs
/// it too, and whoever creates it disposes it.
class _SlippageForm extends StatefulWidget {
  const _SlippageForm({required this.controller});

  final TextEditingController controller;

  @override
  State<_SlippageForm> createState() => _SlippageFormState();
}

class _SlippageFormState extends State<_SlippageForm> {
  TextEditingController get _controller => widget.controller;

  static String _trim(double v) =>
      v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  void _pick(double preset) {
    setState(() {
      _controller.text = _trim(preset);
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final state = slippageState(_controller.text);
    final active = state.value;

    final Color edge = switch (state.level) {
      SlippageLevel.error => gw.statusError,
      SlippageLevel.warning => GeniusWalletColors.statusWarning,
      SlippageLevel.ok => gw.borderSubtle,
    };

    return SingleChildScrollView(
      // Extra air at the top: the header hairline sits directly above, and at
      // a flat space10 the first label read as glued to it. Bottom padding is
      // light because the footer supplies its own.
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space10,
        GeniusWalletConsts.space12,
        GeniusWalletConsts.space10,
        GeniusWalletConsts.space10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Slippage tolerance',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
          // The old panel said "Slippage Tolerance (%)" and stopped. A unit is
          // not an explanation: nothing told the user what the number governs
          // or which way is safer.
          Text(
            'The most the price may move before your swap is cancelled.',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          Row(
            children: [
              for (final preset in kSlippagePresets) ...[
                Expanded(
                  child: _PresetChip(
                    label: '${_trim(preset)}%',
                    selected: active == preset,
                    onTap: () => _pick(preset),
                  ),
                ),
                if (preset != kSlippagePresets.last)
                  const SizedBox(width: GeniusWalletConsts.space4),
              ],
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          GWFocusRing(
            radius: GeniusWalletConsts.radiusSm,
            background: gw.surfaceMenu,
            // An invalid value keeps the refusal colour even while focused —
            // the gradient says "you are here", the red says "this will not
            // apply", and the second outranks the first.
            restingColor: edge,
            enabled: !state.isError,
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              // Same shared guard the amount fields use. Two decimals is plenty
              // for a percentage — nobody sets slippage to 0.125%.
              inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
              onChanged: (_) => setState(() {}),
              style: GeniusWalletTypography.titleMd.copyWith(
                color: gw.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Custom',
                hintStyle: GeniusWalletTypography.titleMd.copyWith(
                  color: gw.textPrimary38,
                ),
                suffixText: '%',
                suffixStyle: GeniusWalletTypography.titleMd.copyWith(
                  color: gw.textSecondary,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space6,
                  vertical: GeniusWalletConsts.space6,
                ),
                // All four silenced: the ring is the border now, and the
                // theme's app-wide focusedBorder would otherwise paint a
                // second, flat one inside it.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          if (state.message != null) ...[
            const SizedBox(height: GeniusWalletConsts.space4),
            _Message(state: state, gw: gw),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.state, required this.gw});

  final SlippageState state;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    final isError = state.isError;
    final color = isError ? gw.statusError : GeniusWalletColors.statusWarning;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.info_outline,
          size: 16,
          color: color,
        ),
        const SizedBox(width: GeniusWalletConsts.space3),
        Expanded(
          child: Text(
            state.message!,
            style: GeniusWalletTypography.labelMd.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// A preset. Selected takes the real `brandCta` gradient — the app's accent is
/// the gradient, not a flat blue (`drawers-final/README.md`'s global rule).
class _PresetChip extends StatefulWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.selected ? GeniusWalletGradient.brandCta : null,
            // Unselected hover is THE app-wide recipe (sketch 044): brand tint
            // + brand hairline, no geometry.
            color: widget.selected
                ? null
                : (_hovered ? GWDecorations.hoverFill : Colors.transparent),
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
            border: Border.all(
              color: widget.selected
                  ? Colors.transparent
                  : (_hovered ? GWDecorations.hoverEdge : gw.borderSubtle),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: GeniusWalletTypography.titleMd.copyWith(
              color: widget.selected
                  ? GeniusWalletColors.textOnBrand
                  : gw.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
