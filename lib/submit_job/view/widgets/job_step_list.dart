import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// One step in a [JobStepList]: a title always shown, an optional one-line
/// summary shown once the step has collapsed, and a body shown only while the
/// step is current.
///
/// `14-UI-SPEC.md:494-510` - the call site owns every field's content; this
/// class carries no rendering logic of its own.
class JobStep {
  const JobStep({required this.title, this.summary, this.body});

  /// Always shown, at every appearance of the step.
  final String title;

  /// The one-line collapse. Shown only while the step's index is BEFORE
  /// [JobStepList.currentIndex]. Null renders the title alone once collapsed.
  final String? summary;

  /// Shown only while the step's index EQUALS [JobStepList.currentIndex].
  final Widget? body;
}

/// A vertical list of [JobStep]s - the shape of `F1 · Drawer, vertical steps`
/// (`14-CONTEXT.md`, `018-A`).
///
/// **Completed steps stay on screen instead of being replaced, and that is
/// this component's entire argument over a wizard that swaps one pane for the
/// next.** Step 3 (confirm) asks the user to confirm spending money that step
/// 2 (cost) computed - a wizard that has already thrown step 2's figures away
/// cannot let the user check them while they confirm. Rendering the whole
/// list every time, and merely varying each step's appearance by its position
/// relative to [currentIndex], is what keeps every earlier step's content
/// alive rather than torn down and rebuilt from nothing on the way back.
///
/// **Component owns:** the index badge (pending / current / done), the
/// vertical connector between badges, and the collapse rule (`index <
/// currentIndex` -> title + summary only, never the body).
///
/// **Call site owns:** every step's body, the footer CTA, and
/// [currentIndex] itself - see `job_steps.dart`'s `resolveJobStepIndex`.
class JobStepList extends StatelessWidget {
  const JobStepList({
    super.key,
    required this.steps,
    required this.currentIndex,
    this.onTapStep,
  });

  final List<JobStep> steps;
  final int currentIndex;

  /// Null means no step is re-openable. Once the in-flight step begins,
  /// `bridgeOut` has already been dispatched and nothing may be reopened, so
  /// the host passes null from that point on rather than a handler that
  /// happens to reject every tap.
  final ValueChanged<int>? onTapStep;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++)
          _JobStepTile(
            step: steps[i],
            index: i,
            isDone: i < currentIndex,
            isCurrent: i == currentIndex,
            isLast: i == steps.length - 1,
            onTap: onTapStep == null ? null : () => onTapStep!(i),
            gw: gw,
          ),
      ],
    );
  }
}

class _JobStepTile extends StatelessWidget {
  const _JobStepTile({
    required this.step,
    required this.index,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    required this.onTap,
    required this.gw,
  });

  final JobStep step;
  final int index;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  final VoidCallback? onTap;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    final Widget titleAndContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          step.title,
          style: GeniusWalletTypography.titleMd.copyWith(
            color: isDone || isCurrent ? gw.textPrimary : gw.textSecondary,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        if (isDone && step.summary != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          Text(
            step.summary!,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
        if (isCurrent && step.body != null) ...[
          const SizedBox(height: GeniusWalletConsts.space6),
          step.body!,
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : GeniusWalletConsts.space8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _StepBadge(
                  index: index,
                  isDone: isDone,
                  isCurrent: isCurrent,
                  gw: gw,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: GeniusWalletConsts.space2,
                      ),
                      color: gw.borderSubtle,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Expanded(
              // `GestureDetector`, not `InkWell` (2026-07-31 walk): a step
              // row is a progress indicator, not an interactive list row -
              // `InkWell`'s hover/splash paint promised a click target the
              // ACTIVE step does not have (tapping it while it is already
              // current is a no-op in `job_steps.dart`'s `onTapStep`).
              // `GestureDetector` keeps tapping back to a completed step
              // working exactly as before, with no ink paint at all.
              child: onTap == null
                  ? titleAndContent
                  : GestureDetector(onTap: onTap, child: titleAndContent),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.index,
    required this.isDone,
    required this.isCurrent,
    required this.gw,
  });

  final int index;
  final bool isDone;
  final bool isCurrent;
  final GWColors gw;

  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gw.statusSuccess,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: 12, color: gw.textOnBrand),
      );
    }
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent ? gw.textPrimary : gw.borderSubtle,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Text(
        '${index + 1}',
        style: GeniusWalletTypography.labelMd.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCurrent ? gw.textPrimary : gw.textSecondary,
        ),
      ),
    );
  }
}
