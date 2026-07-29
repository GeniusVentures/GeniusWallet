import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/data/gw_status_dot.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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

  /// Fires when a sub-line's inline affordance is tapped - `Choose a wallet
  /// ›`, `Switch wallet ›`, `See node status ›` or `Retry ›`. The identity
  /// is [ComputeStatusView.link]; this widget only renders it, the caller
  /// decides what it does (open the account drawer, navigate to `/network`,
  /// re-arm the polling timer via `RetryProcessingStatus`).
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
        const GWKicker('Compute'),
        const SizedBox(height: GeniusWalletConsts.space3),
        _BalanceTile(view: view, balance: balance, fiatSubline: fiatSubline),
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
  });

  final ComputeStatusView view;
  final double balance;
  final String fiatSubline;

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
        : SingleChildScrollView(
            // GWAnimatedNumber's own Text carries no maxLines/overflow
            // guard. An unusually large balance could otherwise wrap to a
            // second line and silently blow the height budget - the exact
            // failure mode `14-UI-SPEC.md §1.5.1`'s single-line rule exists
            // to prevent for every other text run in this panel.
            // Horizontal SingleChildScrollView hands the number an
            // unbounded width so it can never wrap, reports only the
            // tile's own bounded width upward, and
            // NeverScrollableScrollPhysics turns the residual
            // scrollability into a hard clip rather than a draggable
            // control. This is not FittedBox/AutoSizeText: nothing here
            // searches for a size, so it cannot reintroduce the
            // drag-resize freeze `test/freeze_rule_test.dart` guards
            // against.
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: GWAnimatedNumber(
              value: balance,
              suffix: ' GNUS',
              style: GeniusWalletTypography.numericDisplay.copyWith(
                color: gw.textPrimary,
              ),
            ),
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
