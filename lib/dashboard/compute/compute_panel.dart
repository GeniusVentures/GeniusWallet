import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/data/gw_status_dot.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// The dashboard's first card - the twin-tile compute panel
/// (`14-UI-SPEC.md §3.1`, sketch 077's P1). Renders the section kicker, the
/// balance tile, the compute tile and the "New processing job" action, in
/// that order, entirely from [ComputeStatusView] (plan 01's
/// `lib/dashboard/compute/compute_state.dart`).
///
/// **This widget reads NO bloc and NO stream.** Every value it draws
/// arrives as a constructor parameter - the view model, the balance, a
/// pre-formatted fiat string, and two callbacks. That constraint is not a
/// style preference: it is what makes
/// `test/dashboard/compute_panel_height_test.dart` and
/// `test/theme/compute_contrast_test.dart` possible at all with an ordinary
/// `pumpWidget`, without the golden/snapshot/pixel tooling this phase
/// declined twice. A bloc read here would force every height and contrast
/// assertion through a `BlocProvider` harness instead. Do not "simplify"
/// this later by moving a `context.read<AppBloc>()` in - the caller
/// (plan 08's `lib/components/wallet_overview.dart`) owns resolving state
/// and reading the bloc, and hands this widget the finished, plain result.
class ComputePanel extends StatelessWidget {
  const ComputePanel({
    super.key,
    required this.view,
    required this.balance,
    required this.fiatSubline,
    required this.useMinions,
    required this.onUnitChanged,
    required this.onLinkTap,
    required this.onNewJob,
  });

  /// The resolved state's rendering contract - label, sub-line, dot role,
  /// bar, trailing value, CTA-enabled - from `viewForComputeState`.
  final ComputeStatusView view;

  /// The GNUS balance, animated by [GWAnimatedNumber]. Zero renders here
  /// exactly like any other value - there is deliberately no zero
  /// special-case anywhere below. That absence IS the fix for
  /// `14-CONTEXT.md`'s bug 4: `wallet_overview.dart:141-148` paints a zero
  /// balance as `statusError` today, and a wallet with no funds is not a
  /// broken wallet.
  final double balance;

  /// The balance tile's `≈ $` fiat line, fully formatted by the caller
  /// (e.g. `'≈ \$312.40'`, using `NumberFormat.simpleCurrency()`'s symbol
  /// per `14-UI-SPEC.md §3.3`). This widget stays free of `intl`/locale
  /// concerns and only decides WHETHER to show it
  /// ([ComputeStatusView.showBalanceFiatSubline]) - never how to format it.
  /// Ignored whenever that flag is false (including the no-wallet state,
  /// which never shows this line regardless of the flag - see
  /// `_BalanceTile`); pass whatever is available.
  final String fiatSubline;

  /// Whether the balance is currently displayed in minions rather than GNUS.
  /// Drives only the unit label rendered beside the number
  /// (`14-08-PLAN.md` Task 3) - [balance] itself must already be the
  /// caller-selected unit's value; this widget does no unit conversion.
  final bool useMinions;

  /// Fires with the SELECTED unit (not a flip) when either segment of the
  /// balance unit track is tapped - `false` for GNUS, `true` for minions.
  /// Value-based rather than a `VoidCallback` toggle
  /// (`260731-kc5-PLAN.md`'s state-shape decision): a toggle callback lets a
  /// double-tap on the SAME segment flip to the other unit and back, because
  /// each segment's guard (`selected ? null : onToggleUnit`) reads the
  /// last-built frame's `useMinions` and both taps see the pre-tap value. A
  /// value-based callback makes that structurally impossible - setting the
  /// same unit twice is a no-op by construction, not by a guard that can
  /// race. Replaces the deleted 200x36 `ToggleButtons` block that used to
  /// live below the balance in `wallet_overview.dart` (`14-08-PLAN.md`
  /// Task 3, DECIDED 2026-07-29 by Jakub) - the unit track IS the toggle
  /// now.
  final ValueChanged<bool> onUnitChanged;

  /// Fires when a sub-line's inline affordance is tapped - `Choose a wallet
  /// ›`, `Switch wallet ›`, `See node status ›` or `Reconnect ›`. The
  /// identity is [ComputeStatusView.link]; this widget only renders it, the
  /// caller decides what it does (open the account drawer, navigate to
  /// `/network`, re-arm the polling timer via `RetryProcessingStatus`).
  final ValueChanged<ComputeLink> onLinkTap;

  /// Fires when the "New processing job" CTA is pressed. Only reachable
  /// when [ComputeStatusView.ctaEnabled] is true - the button renders
  /// disabled, never absent, in every other state (`14-UI-SPEC.md §3.4`),
  /// closing `submit_job_dashboard_button.dart:25-27`'s `SizedBox.shrink()`
  /// bug, which holds both addresses that would explain the state and
  /// discards them instead.
  final VoidCallback onNewJob;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // `GWSectionTitle`, not a kicker, so this panel reads at the SAME
        // geometry as Assets/Markets/Transactions/Chart: the component
        // reserves a 44px header and owns its `space8` bottom gap, which is
        // what puts Balance on the same baseline as the first Assets coin
        // (Jakub, 2026-07-31 - a deliberate override of sketch 166, whose
        // component inventory assigned `GWKicker` here). The 38px it costs
        // over the old kicker is why `kDashboardPanelSlotHeight` went 300 ->
        // 340. Do NOT add a spacer below - the title owns its own gap, and do
        // not "restore" the kicker.
        const GWSectionTitle(title: 'Compute'),
        _BalanceTile(
          view: view,
          balance: balance,
          fiatSubline: fiatSubline,
          useMinions: useMinions,
          onUnitChanged: onUnitChanged,
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        _ComputeTile(view: view, onLinkTap: onLinkTap),
        const SizedBox(height: GeniusWalletConsts.space6),
        // The one filled CTA on this surface - starting a job spends GNUS
        // irreversibly, so it earns the fill; every other affordance here
        // is an inline text link (`14-UI-SPEC.md §3.4`). `size: sm` (44px,
        // the touch floor) - `md` costs 4 more than the budget has.
        GWButton(
          variant: GWButtonVariant.primary,
          size: GWButtonSize.sm,
          expand: true,
          label: 'New processing job',
          onPressed: view.ctaEnabled ? onNewJob : null,
        ),
      ],
    );
  }
}

/// The 18px-line-box style every sub-line in this panel uses - the balance
/// tile's `≈ $` line, its no-wallet placeholder, and the compute tile's
/// status line alike. `14-UI-SPEC.md §3.3` specifies this exact recipe
/// (`numericBody.copyWith(fontSize: 13, height: 18 / 13,
/// color: gw.textSecondary)`) for the fiat line; reused for every other
/// sub-line here too because each costs the identical `+4 +18` in the
/// per-state height table (`14-UI-SPEC.md §1.4`) - a second, separately
/// hand-tuned sub-line style would only risk drifting from the one metric
/// the budget actually depends on.
TextStyle _sublineStyle(GWColors gw) => GeniusWalletTypography.numericBody
    .copyWith(fontSize: 13, height: 18 / 13, color: gw.textSecondary);

/// Maps [ComputeDotRole] onto a literal colour - the split plan 01's own
/// header comment prescribes: the pure state module owns the semantic
/// role, the call site (here, where `GWColors` is in scope) owns the
/// colour token. Confirmed as-is rather than overridden: plan 01's
/// `notLinked -> warning` choice (flagged as an open decision in its
/// SUMMARY) is accepted here unchanged, since overriding the STATE→role
/// mapping would mean editing `compute_state.dart`, which this plan does
/// not own.
Color _dotColorFor(ComputeDotRole role, GWColors gw) {
  switch (role) {
    case ComputeDotRole.neutral:
      return gw.textSecondary;
    case ComputeDotRole.warning:
      return gw.statusWarningText;
    case ComputeDotRole.success:
      return gw.statusSuccess;
    case ComputeDotRole.brand:
      return gw.brandPrimaryOnSurface;
    case ComputeDotRole.error:
      return gw.statusError;
  }
}

/// The sunken, non-elevated well both tiles share (`14-UI-SPEC.md §1.3`).
/// `elevated: false` + `surfaceSunken` is deliberate - sketch 016 rejected a
/// second elevation nested inside the dashboard's own elevated card, and
/// `GWDetailGrid` already documents this exact recipe as the right
/// treatment for a recessed group inside a card
/// (`gw_detail_grid.dart:36-39`).
class _ComputeCardTile extends StatelessWidget {
  const _ComputeCardTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWCard(
      background: gw.surfaceSunken,
      border: Border.all(color: gw.borderSubtle, width: 1),
      elevated: false,
      radius: GeniusWalletConsts.radiusMd,
      // THE LEVER (`14-UI-SPEC.md §1.3`, `14-07-PLAN.md` Task 1). `space4`
      // (8), not the sibling `space6` (12): with `space6` on both axes the
      // tallest state lands at 284px against the measured 274px budget - a
      // 10px overflow. This 8 is what buys back the ~6px of headroom the
      // worst state has. If a future edit "normalises" this to `space6` to
      // match some other card's padding,
      // `test/dashboard/compute_panel_height_test.dart` fails on the very
      // next run - that test is what keeps this comment true rather than
      // aspirational.
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      child: child,
    );
  }
}

/// The balance tile: a dense kicker over an animated GNUS number, with an
/// optional `≈ $` fiat sub-line (`14-UI-SPEC.md §3.1`).
class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.view,
    required this.balance,
    required this.fiatSubline,
    required this.useMinions,
    required this.onUnitChanged,
  });

  final ComputeStatusView view;
  final double balance;
  final String fiatSubline;
  final bool useMinions;
  final ValueChanged<bool> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // `ComputeLink.chooseWallet` is set by `viewForComputeState` ONLY for
    // `ComputeState.noWallet` (`compute_state.dart`'s switch) - the one
    // reliable signal this pure view model carries for "there is no
    // wallet", without adding a field to a file plans 01/02 own. Used to
    // pick the no-wallet placeholder form the height table prices at 55px
    // rather than the normal 77/99px number+subline form
    // (`14-UI-SPEC.md §1.4`): showing "0.00 GNUS" when there is no wallet
    // at all would misreport an empty WALLET, not an absent one.
    final isNoWallet = view.link == ComputeLink.chooseWallet;

    // No unit toggle in the no-wallet state - there is no balance to
    // switch units on. Everywhere else, the unit label sits beside the
    // number and IS the toggle (`14-08-PLAN.md` Task 3, DECIDED
    // 2026-07-29 by Jakub) - it replaces the deleted 200x36
    // `ToggleButtons` block that used to live below the balance.
    final Widget valueWidget = isNoWallet
        ? Text(
            // Matches the copy `wallet_overview.dart` already shows for
            // this exact case - no new copy invented for a state that
            // already has an established string.
            'No wallet selected',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _sublineStyle(gw),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  // GWAnimatedNumber's own Text carries no maxLines/overflow
                  // guard. An unusually large balance could otherwise wrap
                  // to a second line and silently blow the height budget -
                  // the exact failure mode `14-UI-SPEC.md §1.5.1`'s
                  // single-line rule exists to prevent for every other text
                  // run in this panel. Horizontal SingleChildScrollView
                  // hands the number an unbounded width so it can never
                  // wrap; `_RenderSingleChildViewport.performLayout` sizes
                  // itself to `constraints.constrain(child.size)` - i.e. it
                  // already HUGS the number's own rendered width rather than
                  // always claiming the full `Flexible` allotment (unlike
                  // `ListView`, it does not need `shrinkWrap` - that
                  // parameter does not exist on this widget), which is what
                  // keeps the unit toggle beside the number instead of
                  // shoved to the tile's far edge, while still clamping to
                  // the leftover space when the number genuinely is that
                  // wide. NeverScrollableScrollPhysics turns any residual
                  // scrollability into a hard clip rather than a draggable
                  // control. This is not FittedBox/AutoSizeText: nothing
                  // here searches for a size, so it cannot reintroduce the
                  // drag-resize freeze `test/freeze_rule_test.dart` guards
                  // against.
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: GWAnimatedNumber(
                    value: balance,
                    style: GeniusWalletTypography.numericDisplay.copyWith(
                      color: gw.textPrimary,
                    ),
                  ),
                ),
              ),
              // space4 (8px), not the space2 (4px) a bare word needed
              // (260731-kc5-PLAN.md). Against a bordered hairline pill, 4px
              // reads as the control touching the number - the eye measures
              // to the drawn line, not to the chip's text. 8 is the
              // smallest step that reads as deliberate, and it equals the
              // track's own internal chip padding (space4 horizontal), so
              // the air outside the control matches the air inside it.
              // space6 (12) was rejected: it is optically closer to right
              // against a 32px numeral, but this row's number allotment is
              // already losing ~39px to the wider track and 12 would cost
              // 4 more - one token to reverse if Jakub judges 8 too tight.
              const SizedBox(width: GeniusWalletConsts.space4),
              _UnitTrack(useMinions: useMinions, onUnitChanged: onUnitChanged),
            ],
          );

    return _ComputeCardTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const GWKicker('Balance', dense: true),
          const SizedBox(height: 3),
          valueWidget,
          if (!isNoWallet && view.showBalanceFiatSubline) ...[
            const SizedBox(height: GeniusWalletConsts.space2),
            Text(
              fiatSubline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _sublineStyle(gw),
            ),
          ],
        ],
      ),
    );
  }
}

/// The GNUS segment's visible label. Always the full word - it is short
/// enough to cost nothing.
const String _kGnusLabel = 'GNUS';

/// The minions segment's visible label - the abbreviation, not the full
/// word. `260731-kc5-PLAN.md`'s recorded assumption, one line to reverse:
///
/// - Jakub approved scheme B as drawn, and the sketch (170) draws `MIN`.
/// - The app already ships this exact abbreviation:
///   `genius_balance_display.dart:89` renders `widget.useMinions ? "min" :
///   "gnus"` as this same unit's suffix, so `MIN` is not a coinage invented
///   to fit a pixel budget - it is the existing short form, brought into the
///   new control.
/// - The full word `MINIONS` costs ~28px this row does not have (~126px
///   track vs ~98px), and screen readers hear the full word `Minions`
///   regardless (`_UnitSegment.semanticLabel` below) - the abbreviation
///   costs AT users nothing.
///
/// **If Jakub rejects `MIN`:** the sketch's own recommendation is that B
/// becomes unbuildable at this width and scheme A (a swap glyph) is the
/// right answer instead - that is a different plan, not a wider B.
const String _kMinionsLabel = 'MIN';

/// The balance tile's unit control - a two-segment [GWControlTrack] reading
/// `GNUS` / `MIN`, both always visible, the active one raised. Replaces the
/// single-label `_UnitToggle` (sketch 170: the old control was purely
/// visually indistinguishable from the `Balance` kicker above it, and only a
/// sighted pointer/touch user who hovered it would ever discover it was a
/// button) and the deleted 200x36 `ToggleButtons` block that lived below the
/// balance before that (`14-08-PLAN.md` Task 3, DECIDED 2026-07-29 by
/// Jakub).
///
/// Built on the shared [GWControlTrack] container - this is its FOURTH
/// consumer (`gw_control_track.dart`'s own doc comment names it) - so this
/// panel declares none of the five `CONVENTIONS.md` "control track" values
/// itself.
class _UnitTrack extends StatelessWidget {
  const _UnitTrack({required this.useMinions, required this.onUnitChanged});

  final bool useMinions;

  /// Value-based, not a flip - see [ComputePanel.onUnitChanged]'s doc
  /// comment for why a `VoidCallback` toggle is a bug here, not a style
  /// choice.
  final ValueChanged<bool> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    // `explicitChildNodes: true` is load-bearing: without it, Flutter merges
    // the two child Semantics nodes into this group's single label and a
    // screen reader would lose the second option entirely - which is the
    // whole point of scheme B (sketch 170: "the only scheme where you can
    // learn that the other unit is called Minions without pressing
    // anything"). With it, a screen reader announces "GNUS, selected,
    // button" and "Minions, not selected, button" - the same information
    // scheme B now gives a sighted user, given to an AT user too.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Balance unit',
      child: GWControlTrack(
        children: [
          _UnitSegment(
            label: _kGnusLabel,
            semanticLabel: 'GNUS',
            selected: !useMinions,
            onTap: () => onUnitChanged(false),
          ),
          _UnitSegment(
            label: _kMinionsLabel,
            // Full word as the accessible name even though the visible
            // label is the abbreviation. WCAG 2.5.3 Label in Name is
            // satisfied - the match is case-insensitive substring and "min"
            // is contained in "Minions" - so this is the correct call, not
            // a violation of it.
            semanticLabel: 'Minions',
            selected: useMinions,
            onTap: () => onUnitChanged(true),
          ),
        ],
      ),
    );
  }
}

/// One segment of [_UnitTrack]. Geometry matches `_TimeframeTab`
/// (`gw_timeframe_segment.dart`) exactly - conformance with the app's other
/// control tracks is the entire argument for this change - except colour
/// (no gradient in any state, deliberately) and input handling (`InkWell`,
/// deliberately kept rather than matched to the other tracks' bare
/// `GestureDetector`).
///
/// **Colour deviates from `_TimeframeTab` on purpose.** Selected is
/// `gw.surfaceMenu` fill with `gw.textPrimary`; unselected is transparent
/// with `gw.textSecondary`. No gradient in any state - this follows jx5's
/// `_OrderToneChip` and the sketch's own drawing, and it obeys the CTA
/// weight rule: the Compute panel already has one filled commitment CTA
/// ("New processing job"), and a unit selector must not carry the same
/// visual weight. `_TimeframeTab`/`_FilterChip` still use the brand gradient
/// on their selected chip - that is not drift, it is because those two mark
/// a *filter* selection on a surface with no competing CTA, and this one
/// does.
///
/// **Input handling deviates from the other tracks deliberately, and this
/// must not be "corrected" to match them.** `_TimeframeTab`
/// (`gw_timeframe_segment.dart:118`) and `_FilterChip`
/// (`transactions_slim_view.dart:801`) both wrap a bare `GestureDetector`,
/// which is not keyboard-focusable and does not respond to Enter/Space - a
/// WCAG 2.1.1 Level A failure (filed as a todo, not fixed here - see
/// `.planning/todos/pending/2026-07-31-track-chips-are-not-keyboard-operable.md`).
/// `_UnitToggle`'s own doc comment already recorded that `InkWell` rather
/// than a bare `GestureDetector` is what makes this control
/// keyboard-focusable and operable with Enter/Space; that property carries
/// forward unchanged. `hoverColor: Colors.transparent` because [GWHoverable]
/// already owns the hover paint (double hover washes would composite
/// oddly); `focusColor` is left at its default because that is the visible
/// keyboard-focus indicator (WCAG 2.4.7) - do not null it out while
/// suppressing the hover.
class _UnitSegment extends StatelessWidget {
  const _UnitSegment({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;

  /// Fires unconditionally - no `selected ? null : onTap` guard. That guard
  /// is exactly the bug `260731-kc5-PLAN.md`'s state-shape section
  /// documents: it reads `selected` from the last-built frame, so two taps
  /// on the same segment inside one frame (a double-tap, a stuck touch, a
  /// fast test pump) can both see `selected == false` and both fire,
  /// flipping the unit and flipping it back. `onUnitChanged` being
  /// value-based (not a toggle) is what makes firing unconditionally safe:
  /// setting the same unit twice is a no-op by construction.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      // Without this, the visible `Text` (`GNUS`/`MIN`) contributes its own
      // literal label and merges with this node's - a screen reader would
      // hear "GNUS, GNUS" or "Minions, MIN" instead of the clean
      // `semanticLabel` alone. `excludeSemantics: true` makes this node the
      // sole source of truth for what gets announced, which is also what
      // lets the accessible name stay the full word `Minions` while the
      // visible glyph stays the `MIN` abbreviation.
      excludeSemantics: true,
      child: GWHoverable(
        builder: (hovered) {
          final bool lifted = hovered && !selected;
          final Color foreground = selected
              ? gw.textPrimary
              : (lifted ? gw.textPrimary : gw.textMutedOnSunken);
          final Color? fill = selected
              ? gw.surfaceMenu
              : (lifted ? gw.surfaceElevated : null);

          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              hoverColor: Colors.transparent,
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.radiusPill,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                transformAlignment: Alignment.center,
                transform: lifted
                    ? Matrix4.translationValues(0, -1, 0)
                    : Matrix4.identity(),
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space4,
                  vertical: GeniusWalletConsts.space3,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.radiusPill,
                  ),
                  boxShadow: (selected || lifted)
                      ? GeniusWalletElevation.card
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    // Pins the chip's line box at 24px - without this the
                    // line box grows past the app's default line height and
                    // the row's height budget moves (`_TimeframeTab`'s own
                    // comment records the same constraint).
                    height: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The compute tile: a dense kicker over the status row, an optional
/// sub-line (with at most one inline link) and an optional 4px bar
/// (`14-UI-SPEC.md §3.1`).
class _ComputeTile extends StatelessWidget {
  const _ComputeTile({required this.view, required this.onLinkTap});

  final ComputeStatusView view;
  final ValueChanged<ComputeLink> onLinkTap;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return _ComputeCardTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const GWKicker('Compute node', dense: true),
          const SizedBox(height: 3),
          // GWStatusDot alone keeps this row at its 18px line box - both
          // the label and the trailing value render at `labelMd`; a
          // `bodySm` trailing would silently cost 2px per state
          // (`14-UI-SPEC.md §1.5.4`). No `labelColor` is passed, so the
          // label renders `gw.textPrimary` - only the dot carries hue,
          // which is `14-UI-SPEC.md §2.2`'s rule that no per-state label
          // contrast math is needed.
          GWStatusDot(
            color: _dotColorFor(view.dotRole, gw),
            label: view.label,
            trailingValue: view.trailing,
          ),
          if (view.subline != null) ...[
            const SizedBox(height: GeniusWalletConsts.space2),
            _SublineRow(
              text: view.subline!,
              link: view.link,
              onLinkTap: onLinkTap,
              style: _sublineStyle(gw),
            ),
          ],
          if (view.showBar) ...[
            const SizedBox(height: GeniusWalletConsts.space3),
            // showBar => barValue is non-null by ComputeStatusView's own
            // contract (its doc comment: "Non-null if and only if showBar
            // is true - a percentage without a bar is forbidden, a bar
            // without a percentage is impossible").
            _ComputeProgressBar(value: view.barValue!),
          ],
        ],
      ),
    );
  }
}

/// A sub-line that may carry an inline link. Per `14-UI-SPEC.md §1.5.2`:
/// this is a `Row` of a flexible, truncating reason plus a link that never
/// truncates - never one text run. Truncating the whole line as a unit
/// would risk swallowing the affordance itself under width pressure.
class _SublineRow extends StatelessWidget {
  const _SublineRow({
    required this.text,
    required this.link,
    required this.onLinkTap,
    required this.style,
  });

  final String text;
  final ComputeLink link;
  final ValueChanged<ComputeLink> onLinkTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final reason = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    final linkLabel = link.label;
    if (linkLabel == null) {
      return reason;
    }

    return Row(
      children: [
        Flexible(child: reason),
        const SizedBox(width: GeniusWalletConsts.space3),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onLinkTap(link),
            child: Text(
              linkLabel,
              style: style.copyWith(
                color: context.gw.brandPrimaryOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The 4px determinate fill bar. Private and feature-local - this phase has
/// exactly one consumer (`14-UI-SPEC.md §4.2`); the only other bar-like
/// thing shipped is a 6px MARKER on a track
/// (`token_info_screen.dart:1284-1308`), which cannot migrate to a fill, so
/// this does not clear the Rule of Three. Promote to
/// `lib/components/data/gw_progress_bar.dart` when a second consumer
/// appears.
class _ComputeProgressBar extends StatelessWidget {
  const _ComputeProgressBar({required this.value});

  /// 0.0-1.0, REQUIRED and non-nullable (`14-UI-SPEC.md §2.4`, T-14-25).
  /// There is no indeterminate mode and no null: a caller with no live
  /// reading cannot construct this widget at all, which is the API-level
  /// enforcement of "no live percentage, no ring/bar" - a determinate
  /// indicator on a feed that has stopped is a false statement about a job
  /// the user paid for.
  final double value;

  /// Fixed at 4px (`14-UI-SPEC.md §4.2`) - no caller needs a different
  /// height, so this stays a constant rather than a configurable
  /// parameter nothing passes (YAGNI).
  static const double height = 4;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Track recipe lifted verbatim from the shipped marker
          // (`token_info_screen.dart:1289-1293`) so the app has one track
          // treatment even though the two bars differ in shape. Keyed so
          // `test/theme/compute_contrast_test.dart` can locate this exact
          // node without a brittle type/predicate search through a tree
          // that also contains the CTA's own gradient decoration.
          DecoratedBox(
            key: const ValueKey('computeBarTrack'),
            decoration: BoxDecoration(
              color: gw.surfaceSunken,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: gw.borderSubtle, width: 0.5),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: DecoratedBox(
              key: const ValueKey('computeBarFill'),
              decoration: BoxDecoration(
                // The light-mode degrade is a shipped pattern, not an
                // invention: `brandCtaText` already collapses this exact
                // gradient to a flat, AA-safe token when its appearance
                // proxy is light (`genius_wallet_gradient.dart:44-51`), for
                // the identical reason this bar needs it - the raw
                // gradient measures under the 3:1 graphical floor on a
                // light surface (`14-UI-SPEC.md §5.4`). Reusing the
                // function instead of re-deriving the same ternary keeps
                // the branch in one place.
                gradient: GeniusWalletGradient.brandCtaText(gw.surfaceSunken),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
