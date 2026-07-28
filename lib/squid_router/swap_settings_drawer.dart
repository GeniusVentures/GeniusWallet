import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
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
    // No GWColors read here any more: the only consumer was the footer's top
    // rule, which the shell now draws (kDrawerFooterPadding). GWButton makes
    // its own appearance-aware read.
    return ValueListenableBuilder<String>(
      valueListenable: raw,
      builder: (context, value, _) {
        final state = slippageState(value);
        // Padding and the top rule both moved to the shell
        // (kDrawerFooterPadding) -- this drawer was the only one of the ~19
        // that drew them, which is why every other footer ran edge to edge.
        return GWButton(
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.lg,
          expand: true,
          label: 'Apply',
          // The old Apply was always live and silently did nothing when the
          // value would not parse. Refusing is only honest if the control
          // says so.
          onPressed: state.canApply ? () => onApply(state.value!) : null,
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
      // borderControl, not borderSubtle: on the 156-A panel the field's fill
      // sits 1.11:1 from the panel's, so the edge is the ONLY thing saying
      // "this is an input" and it has to clear 1.4.11 by itself. 12% measured
      // 1.36:1; this is 3.30:1.
      SlippageLevel.ok => gw.borderControl,
    };

    return SingleChildScrollView(
      // Body inset removed: this exact value -- extra air at the top because
      // the header hairline sits directly above, and at a flat space10 the
      // first label read as glued to it -- was promoted to the shell as
      // `kDrawerBodyPadding`. Keeping it here would double it to 40/48.
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sketch 067-A "Kicker only": the section is a label and a gap, no
          // container. A card here measures 1.00:1 against the 156-A panel --
          // the same colour -- so the only 1.4.11-compliant box would need a
          // white-36% border, which makes the section louder than Apply. A gap
          // has no contrast threshold to meet.
          const GWKicker('Slippage tolerance'),
          // 12, not the 4 this had: with no container the gap IS the grouping,
          // so it has to be big enough to read as one.
          const SizedBox(height: GeniusWalletConsts.space6),
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
          // The field's own label. 067-A drew it and the shipped drawer did not
          // have it -- the field carried a `Custom` PLACEHOLDER instead, which
          // is invisible the moment the field has a value, and it always does
          // (a preset is selected on open). A placeholder is not a label.
          // `labelMd`/`textSecondary`, NOT the sketch's 13/w500/ink70.
          //
          // 067's mockup drew a fourth value for this role, and the app has
          // already settled it three times identically: `GWTextField` renders
          // exactly this (label, then `space4`), and `swap_field.dart` ("You
          // Pay") and `submit_logs_screen.dart` ("Message") both hand-copy the
          // same two values because they wrap `GWFocusRing` and cannot use the
          // component. Taking the mockup literally here would have recreated,
          // one sketch later, precisely the drift 065 was written to end.
          Text(
            'Custom value',
            style: GeniusWalletTypography.labelMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          GWFocusRing(
            radius: GeniusWalletConsts.radiusSm,
            // DARKER than the panel, not lighter (Jakub, live, 2026-07-28).
            //
            // 156-A shipped this as `surfaceMenu` -- the lighter object on a
            // darker canvas. On screen it read as a raised tile rather than
            // something you type into. `surfaceSunken` is this app's existing
            // recipe for a recessed control (pin_screen, token_info_screen's
            // fields, the control-track standard), and it is sketch 156's own
            // scheme C, so this is a return to a rule rather than a deviation.
            //
            // The edge is unaffected: GWFocusRing paints its ring as an outer
            // DecoratedBox, so the ring composites over the PANEL, not over the
            // fill. borderControl stays 3.30:1 whatever this value is.
            background: gw.surfaceSunken,
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
                // No hint any more: the label above says `Custom value`, and a
                // placeholder repeating it would be the same word twice for a
                // state (empty field) that lasts one keystroke.
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
    // Three tones now, not two. `ok` used to be unreachable here because the
    // validator returned a null message for the comfortable band; it confirms
    // instead, so this needs a neutral colour rather than falling through to
    // amber and painting reassurance as a warning.
    final color = switch (state.level) {
      SlippageLevel.error => gw.statusError,
      SlippageLevel.warning => GeniusWalletColors.statusWarning,
      SlippageLevel.ok => gw.textSecondary, // 5.97:1 on the 156-A panel
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          state.isError ? Icons.error_outline : Icons.info_outline,
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
