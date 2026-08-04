import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/components/data/gw_status_dot.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/submit_job/submit_job_cta_state.dart';
import 'package:genius_wallet/submit_job/view/widgets/job_step_list.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

/// Resolves which of the five job-flow steps is current.
///
/// Steps 0-2 (choose / cost / confirm) are navigable by the user while
/// nothing irreversible has happened yet, so [manualIndex] - written by
/// tapping a step's title or by the step-2 footer's `Continue` - decides
/// among them. Steps 3 (in flight) and 4 (result) are entirely derived from
/// [SubmitJobState] and override [manualIndex] outright: once `bridgeTokens()`
/// has been dispatched there is no "going back", which is also why the host
/// stops passing a tap handler once this returns 3 or higher.
int resolveJobStepIndex(SubmitJobState state, int manualIndex) {
  if (state.outcome != SubmitOutcome.notSubmitted) {
    return 4;
  }
  if (state.isBridgingTokens) {
    return 3;
  }
  return manualIndex.clamp(0, 2);
}

/// The job flow's step list, reactive to both the cubit's state and the
/// caller-supplied [manualIndex] - shared with [JobFlowFooter] exactly the
/// way `swap_settings_drawer.dart`'s `_SlippageForm`/`_ApplyFooter` share a
/// `ValueNotifier`: the footer is a SIBLING subtree in the drawer host (a
/// separate slot the shell hands to `ResponsiveDrawer`), so it cannot read
/// this widget's local state, and one notifier written by either half and
/// read by both is the smallest thing that keeps them agreeing.
///
/// Assumes a [SubmitJobCubit] is already resolvable from [BuildContext] -
/// the host (`job_drawer.dart` / `submit_job_screen.dart`) is responsible for
/// that, since the two hosts provide it two different ways.
class JobFlowBody extends StatelessWidget {
  const JobFlowBody({super.key, required this.manualIndex});

  final ValueNotifier<int> manualIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: manualIndex,
      builder: (context, manual, _) {
        return BlocConsumer<SubmitJobCubit, SubmitJobState>(
          listenWhen: (previous, current) =>
              previous.isFilePickerOpen &&
              !current.isFilePickerOpen &&
              current.uploadedJson.isNotEmpty,
          listener: (context, state) {
            // A file was just accepted (whether this is the first pick or a
            // re-pick from a reopened choose step). Auto-advance to the cost
            // step only when the user is still ON the choose step - if they
            // have already navigated further this cannot happen anyway
            // (openFilePicker's CTA only renders on the choose step).
            if (manualIndex.value == 0) {
              manualIndex.value = 1;
            }
          },
          builder: (context, state) {
            final index = resolveJobStepIndex(state, manual);
            return JobStepList(
              steps: _buildSteps(context, state),
              currentIndex: index,
              onTapStep: index >= 3
                  ? null
                  : (tapped) {
                      if (tapped <= index) {
                        manualIndex.value = tapped;
                      }
                    },
            );
          },
        );
      },
    );
  }

  List<JobStep> _buildSteps(BuildContext context, SubmitJobState state) => [
    JobStep(
      title: 'Choose a file',
      summary: state.uploadedFileName.isEmpty ? null : state.uploadedFileName,
      body: JobChooseFileBody(
        state: state,
        onChooseFile: context.read<SubmitJobCubit>().openFilePicker,
      ),
    ),
    JobStep(
      title: 'Cost',
      summary: state.jobCost == 0
          ? null
          : '${state.jobCost} GNUS · ${state.jobGasCost}',
      body: JobCostBody(state: state),
    ),
    JobStep(
      title: 'Confirm',
      body: JobConfirmBody(state: state),
    ),
    const JobStep(title: 'In flight', body: JobInFlightBody()),
    JobStep(
      title: 'Result',
      body: JobResultBody(state: state),
    ),
  ];
}

/// Step 1's body - sketch 166 screen "2 · Step 1 file" (three renderings:
/// RESTING, PICKER OPEN, FILE REJECTED), reproduced against the real cubit
/// state rather than the sketch's static strings. A file error renders
/// inline here, never as a toast; picker progress is a spinner, not the
/// shipped full-screen [Loading] barrier it replaces
/// (`submit_job_screen.dart:201`, superseded).
///
/// **The tail of `build` (everything after the picker-open early return) is
/// one `Column`, not three exclusive branches (2026-07-31 restructure).**
/// Sketch 166's FILE REJECTED rendering draws its warning note and a
/// disabled `Continue` with no choose control anywhere - reproduced verbatim
/// here for a while, it was a dead end: `fileError` outlives the drawer
/// (`wallet_overview.dart:60`), so once it was set the only path back to
/// RESTING or FILE HELD was an app restart. This is a deliberate,
/// recorded DEVIATION from sketch 166, not a restoration of something the
/// port dropped - the sketch itself never draws an escape out of this
/// state, so there is nothing here to be "faithful" back to. The other
/// reason a single column is required rather than a fourth exclusive branch:
/// a rejection landing on a file already held must show BOTH the file and
/// the warning (D-03) - `JobFlowFooter` case 0 gates `Continue` on
/// `uploadedJson`, not on `fileError`, on purpose, so a fresh rejection
/// cannot un-continue an already-accepted file. An exclusive branch that
/// erased the file to show the warning would make the body lie about what
/// the footer still thinks the user holds.
///
/// **The choose-file action lives in the body, not the footer** - sketch
/// 166's own `drawer()` calls draw a `Choose file` control inside the step
/// body and a `Continue` verb in the footer for all three renderings (see
/// [JobFlowFooter]'s case 0), not the `Choose a JSON file` footer button
/// `14-UI-SPEC.md:655` originally specified. The label text is kept
/// byte-identical to what shipped (`Choose a JSON file`) - only its
/// location and the footer's verb change - so this remains the same
/// [SubmitJobCubit.openFilePicker] call the tests already exercise.
class JobChooseFileBody extends StatelessWidget {
  const JobChooseFileBody({super.key, required this.state, this.onChooseFile});

  final SubmitJobState state;

  /// `SubmitJobCubit.openFilePicker` - passed down rather than read from
  /// context here, so this widget stays a plain state-in-props renderer like
  /// every other step body in this file.
  final VoidCallback? onChooseFile;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    if (state.isFilePickerOpen) {
      // Sketch 166 s1 "PICKER OPEN".
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GWSpinner(size: 20),
          const SizedBox(width: GeniusWalletConsts.space4),
          Text(
            'Preparing your job',
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      );
    }

    // Everything below is one Column, not a chain of exclusive returns - see
    // the class doc for why. `hasFile` decides the leading element; the
    // warning is additive on top of it, not a replacement for it.
    final hasFile = state.uploadedFileName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasFile) ...[
          // Not one of the sketch's three renderings - reachable by tapping
          // back to a completed step 1 (`JobStepList.onTapStep` allows
          // re-opening any step at or before the current index), or by a
          // rejection landing on top of an already-held file (D-03). Left
          // blank this would show nothing at all for a step the user can
          // genuinely revisit, so it states the real field the cubit already
          // carries (`uploadedFileName`) and reuses the shared button below
          // as the way to replace it, exactly as `GWDetailGrid` +
          // `GWStatusDot` already state "what happened" elsewhere in this
          // same file (step 5's terminals).
          GWStatusDot(color: gw.statusSuccess, label: 'File selected'),
          const SizedBox(height: GeniusWalletConsts.space6),
          GWDetailGrid(
            rows: [
              _DetailRow(label: 'File', value: state.uploadedFileName, gw: gw),
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
        ] else if (state.fileError.isEmpty) ...[
          // Sketch 166 s1 "RESTING". The sketch draws a bare `Choose file`
          // button with no type hint; the one-line caption above it is not
          // in the sketch - added because `openFilePicker` hard-codes
          // `allowedExtensions: ['json']` (`submit_job_cubit.dart:80`), a
          // real constraint a first-time visitor to this step has no other
          // way to learn before the OS picker opens and silently limits
          // their choices. This `else if` is load-bearing: the file-held
          // branch above does not also render this caption.
          Text(
            'Upload a JSON file describing the job you want to run.',
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
        ],
        if (state.fileError.isNotEmpty) ...[
          // Sketch 166 s1 "FILE REJECTED". Shared `GWWarningNote`, not the
          // feature-local, now-deleted inline error widget this used to
          // render (`14-09-PLAN.md` Task 3d) - the sketch's own note names
          // this exact choice. 8 render call sites across 5 files vs. 1 for
          // the deleted widget; a rejected file is recoverable (pick another
          // one, nothing is spent) - the same register `GWWarningNote`'s own
          // doc comment describes, and the one step 2 already renders twice
          // for `costError`/`insufficientFunds` in this same drawer. It is
          // true here specifically because of the button below: this
          // Column, unlike sketch 166's own FILE REJECTED drawing, always
          // renders a `Choose a JSON file` control alongside the warning, so
          // "pick another one" is something the user can actually do rather
          // than a promise the render tree does not keep.
          GWWarningNote(state.fileError),
          const SizedBox(height: GeniusWalletConsts.space6),
        ],
        GWButton(
          variant: GWButtonVariant.gradientOutline,
          label: 'Choose a JSON file',
          onPressed: onChooseFile,
        ),
      ],
    );
  }
}

/// Step 2's body - the cost table (`14-UI-SPEC.md:665-676`) plus its two
/// blocked variants (`:679-696`). Both the blocked-variant choice here and
/// [JobFlowFooter]'s `Continue` enablement read the SAME
/// [resolveSubmitJobCtaState] call, rather than each re-deriving the
/// condition independently - that duplication is exactly how
/// `submit_job_screen.dart:65`'s off-by-one and zero-cost bugs happened in
/// the first place.
class JobCostBody extends StatelessWidget {
  const JobCostBody({super.key, required this.state});

  final SubmitJobState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final ctaState = resolveSubmitJobCtaState(
      isSubmitting: state.isBridgingTokens,
      hasFileChosen: state.uploadedJson.isNotEmpty,
      jobCost: state.jobCost,
      gnusBalance: state.gnusBalance,
      costError: state.costError,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GWDetailGrid(
          rows: [
            _DetailRow(
              label: 'Job cost',
              value: '${state.jobCost} GNUS',
              gw: gw,
            ),
            _DetailRow(label: 'Bridge gas', value: state.jobGasCost, gw: gw),
            _DetailRow(
              label: 'Your balance',
              value: '${state.gnusBalance} GNUS',
              gw: gw,
            ),
          ],
        ),
        if (ctaState == SubmitJobCtaState.costUnknown) ...[
          const SizedBox(height: GeniusWalletConsts.space6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GWSpinner(size: 16),
              const SizedBox(width: GeniusWalletConsts.space4),
              Text(
                'Working out what this job costs',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ],
          ),
        ] else if (ctaState == SubmitJobCtaState.costError) ...[
          const SizedBox(height: GeniusWalletConsts.space6),
          GWWarningNote(state.costError),
        ] else if (ctaState == SubmitJobCtaState.insufficientFunds) ...[
          const SizedBox(height: GeniusWalletConsts.space6),
          GWWarningNote(
            'You need ${submitJobShortfall(jobCost: state.jobCost, gnusBalance: state.gnusBalance).toStringAsFixed(2)} '
            'more GNUS to start this job.',
          ),
        ],
      ],
    );
  }
}

/// One label/value row inside a [GWDetailGrid] - `14-UI-SPEC.md:676`: "Row
/// labels `gw.textPrimary70`, values `gw.textPrimary`, both at `bodySm`",
/// mirroring `transaction_displays.dart:566-571`. Not [GWCopyRow]: none of
/// these values is a clipboard target. Originally step 2's cost table only
/// (`_CostRow`); renamed on its fourth call site (step 1's file-selected
/// grid) since "cost" stopped describing what it renders.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.gw,
  });

  final String label;
  final String value;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kGWDetailRowPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textPrimary70,
            ),
          ),
          Text(
            value,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 3's body - one sentence naming irreversibility (`14-UI-SPEC.md:797`,
/// sketch 166 screen "4 · Step 3": "Nothing new... the sentence is the whole
/// design"). Step 2's grid stays visible above this as its collapsed
/// summary - that is [JobStepList]'s own doing, not this widget's.
class JobConfirmBody extends StatelessWidget {
  const JobConfirmBody({super.key, required this.state});

  final SubmitJobState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Text(
      'This spends ${state.jobCost} GNUS. Bridging cannot be undone.',
      style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
    );
  }
}

/// Step 4's body - one spinner over a quiet, numbered list of the two
/// operations (`14-UI-SPEC.md:698-711` superseded by sketch 166 board F
/// option B, `14-09-PLAN.md` Task 3a). `bridgeOut()` spends the money;
/// `requestGeniusSDKProcess()` starts the work; only the first is
/// irreversible. The cubit gives no signal distinguishing which of the two is
/// currently running - both happen inside one `isBridgingTokens` window with
/// no intermediate emit (out of this plan's fence, `lib/submit_job/cubit/` is
/// plan 05's file, and option D - one `emit` after `bridgeOut()` resolves -
/// is a deliberately separate follow-up plan, not this one).
///
/// **This is why the list is quiet and static, not two independent
/// spinners.** Two spinners read as two operations running in parallel,
/// which is not what happens - there is exactly one thing happening at a
/// time, the cubit just cannot say which. Naming both operations as a
/// numbered list (rather than collapsing them into one anonymous "working on
/// it") is what makes the `bridgedNotProcessed` terminal legible three steps
/// later: that terminal has to say "step 1 succeeded, step 2 did not," and
/// it can only refer back to a vocabulary this step actually named. The two
/// operation strings (`Bridging GNUS`, `Starting the job`) are therefore
/// byte-identical to what that terminal implies - do not reword either one
/// independently of the other.
class JobInFlightBody extends StatelessWidget {
  const JobInFlightBody({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GWSpinner(size: 16),
            const SizedBox(width: GeniusWalletConsts.space4),
            Text(
              'Starting your job',
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        Padding(
          // Indented under the spinner label, not flush with it - this is a
          // subordinate detail list, not a second top-level row.
          padding: const EdgeInsets.only(left: GeniusWalletConsts.space10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InFlightRow(index: 0, label: 'Bridging GNUS', gw: gw),
              const SizedBox(height: GeniusWalletConsts.space3),
              _InFlightRow(index: 1, label: 'Starting the job', gw: gw),
            ],
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        Text(
          'This can take a minute. Your GNUS is spent once the bridge '
          'completes.',
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// One row of the quiet numbered list under [JobInFlightBody]'s spinner - a
/// small numbered marker plus its label, never its own spinner (the spinner
/// moved up to the single row above). The marker echoes
/// `job_step_list.dart`'s `_StepBadge` recipe (20px circle, `borderSubtle`
/// hairline, `labelMd` at `fontSize: 11`, `w600`) without promoting it to a
/// shared component - this is its second consumer, and `AGENTS.md`'s Rule of
/// Three is not met by two.
class _InFlightRow extends StatelessWidget {
  const _InFlightRow({
    required this.index,
    required this.label,
    required this.gw,
  });

  final int index;
  final String label;
  final GWColors gw;

  static const double _markerSize = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _markerSize,
          height: _markerSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: gw.borderSubtle, width: 1),
          ),
          child: Text(
            '${index + 1}',
            style: GeniusWalletTypography.labelMd.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: gw.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space4),
        Text(
          label,
          style: GeniusWalletTypography.bodySm.copyWith(
            fontSize: 13,
            color: gw.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Step 5's body - the three terminals, mapped one to one onto
/// `SubmitJobCubit.bridgeTokens()`'s three branches via [SubmitOutcome]
/// (`14-UI-SPEC.md:713-737`). The outcome is read from state, never inferred
/// from whether a hash string happens to be non-empty.
///
/// Neither [SubmitOutcome.done] nor [SubmitOutcome.bridgedNotProcessed] shows
/// a balance figure - both burn tokens before the delayed 5s refetch lands
/// (`submit_job_cubit.dart:262, 277`), so both say the balance is updating
/// until it does, never a number that has not arrived.
class JobResultBody extends StatelessWidget {
  const JobResultBody({super.key, required this.state});

  final SubmitJobState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    switch (state.outcome) {
      case SubmitOutcome.done:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GWStatusDot(color: gw.statusSuccess, label: 'Job started'),
            const SizedBox(height: GeniusWalletConsts.space6),
            GWDetailGrid(
              rows: [GWCopyRow(label: 'Transaction', value: state.txHash)],
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            Text(
              'Your balance is updating',
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ],
        );

      case SubmitOutcome.bridgedNotProcessed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GWStatusDot(
              color: gw.statusWarningText,
              label: 'Bridged · job not started yet',
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
            // Tone version 2 (sketch 166 board F, `14-09-PLAN.md` Task 3b):
            // a plain sentence, no bordered `GWWarningNote` box. The alarm
            // version said the same thing three times - a warning dot, a
            // warning-bordered box, and this sentence - and `GWStatusDot`
            // above already carries the warning colour, so the box was
            // repeating the colour, not adding information. "Keep the
            // transaction below" is an instruction the user can act on;
            // the old "your proof that the transfer happened" was a
            // legal-sounding noun with nothing to do next.
            Text(
              'Your GNUS was bridged, but the job has not started. Keep '
              'the transaction below.',
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
            GWDetailGrid(
              rows: [
                GWCopyRow(label: 'Bridge transaction', value: state.bridgeHash),
              ],
            ),
            if (state.submitError.isNotEmpty) ...[
              const SizedBox(height: GeniusWalletConsts.space4),
              Text(
                state.submitError,
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: GeniusWalletConsts.space4),
            Text(
              'Your balance is updating',
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ],
        );

      case SubmitOutcome.bridgeFailed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GWStatusDot(color: gw.statusError, label: 'Nothing was sent'),
            const SizedBox(height: GeniusWalletConsts.space6),
            Text(
              'The bridge transaction did not go through. No GNUS left '
              'your wallet.',
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ],
        );

      case SubmitOutcome.notSubmitted:
        // Defensive only - the host never renders step 5's body unless
        // resolveJobStepIndex has already returned 4, which requires a
        // non-notSubmitted outcome.
        return const SizedBox.shrink();
    }
  }
}

/// The per-step footer CTA row - the sibling half of [JobFlowBody], sharing
/// the same [manualIndex] notifier (see [JobFlowBody]'s doc comment).
class JobFlowFooter extends StatelessWidget {
  const JobFlowFooter({
    super.key,
    required this.manualIndex,
    this.onDismissDrawer,
  });

  final ValueNotifier<int> manualIndex;

  /// Called after a terminal's `Close` action, in ADDITION to resetting the
  /// cubit. Null for the full-screen host (nothing to dismiss); the drawer
  /// host passes a root-navigator pop.
  final VoidCallback? onDismissDrawer;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: manualIndex,
      builder: (context, manual, _) {
        return BlocBuilder<SubmitJobCubit, SubmitJobState>(
          builder: (context, state) {
            final cubit = context.read<SubmitJobCubit>();
            final index = resolveJobStepIndex(state, manual);

            switch (index) {
              case 0:
                // Sketch 166 s1: `Continue`, disabled in all three
                // renderings except once a file is actually held - the
                // choose-file action itself moved into the body
                // (`JobChooseFileBody`). Gated on `uploadedJson`, the same
                // field `hasFileChosen` reads one case below, not on
                // `fileError`: a fresh rejection from re-opening the picker
                // must not un-continue a file that was already accepted.
                return GWButton(
                  variant: GWButtonVariant.gradientOutline,
                  expand: true,
                  label: 'Continue',
                  onPressed:
                      state.uploadedJson.isNotEmpty && !state.isFilePickerOpen
                      ? () => manualIndex.value = 1
                      : null,
                );
              case 1:
                final ctaState = resolveSubmitJobCtaState(
                  isSubmitting: state.isBridgingTokens,
                  hasFileChosen: state.uploadedJson.isNotEmpty,
                  jobCost: state.jobCost,
                  gnusBalance: state.gnusBalance,
                  costError: state.costError,
                );
                return GWButton(
                  variant: GWButtonVariant.gradientOutline,
                  expand: true,
                  label: 'Continue',
                  onPressed: submitJobCtaEnabled(ctaState)
                      ? () => manualIndex.value = 2
                      : null,
                );
              case 2:
                return GWButton(
                  variant: GWButtonVariant.gradient,
                  expand: true,
                  label: 'Confirm and pay',
                  onPressed: state.isBridgingTokens ? null : cubit.bridgeTokens,
                );
              case 3:
                // No footer CTA while in flight - `14-UI-SPEC.md:658`.
                return const SizedBox.shrink();
              default:
                return _ResultFooter(
                  state: state,
                  cubit: cubit,
                  manualIndex: manualIndex,
                  onDismissDrawer: onDismissDrawer,
                );
            }
          },
        );
      },
    );
  }
}

/// Builds the `Get help` prefill for the `bridgedNotProcessed` terminal
/// (`14-09-PLAN.md` Task 3c). Carries only the bridge transaction hash and
/// `state.submitError` when non-empty - both are already rendered on-screen
/// in a `GWCopyRow` (T-14-36's mitigation: no address, key, mnemonic or
/// balance figure is interpolated here, only a public chain artefact the
/// same screen already shows). No em dashes, per this repo's copy rule.
String _bridgedNotProcessedHelpMessage(SubmitJobState state) {
  final buffer = StringBuffer(
    'Bridged but the job did not start. Bridge transaction: '
    '${state.bridgeHash}.',
  );
  if (state.submitError.isNotEmpty) {
    buffer.write(' ${state.submitError}');
  }
  return buffer.toString();
}

class _ResultFooter extends StatelessWidget {
  const _ResultFooter({
    required this.state,
    required this.cubit,
    required this.manualIndex,
    required this.onDismissDrawer,
  });

  final SubmitJobState state;
  final SubmitJobCubit cubit;
  final ValueNotifier<int> manualIndex;
  final VoidCallback? onDismissDrawer;

  void _close() {
    // The reset moves to the moment of dismissal, not before the result is
    // shown - `submit_job_screen.dart:48-56`'s bug was resetting BEFORE
    // raising the (now-deleted) toast, which emptied the screen before the
    // hash was ever visible.
    cubit.resetState();
    manualIndex.value = 0;
    onDismissDrawer?.call();
  }

  @override
  Widget build(BuildContext context) {
    final closeButton = GWButton(
      variant: GWButtonVariant.gradientOutline,
      expand: true,
      label: 'Close',
      onPressed: _close,
    );

    switch (state.outcome) {
      case SubmitOutcome.done:
        return closeButton;

      case SubmitOutcome.bridgedNotProcessed:
        // DELIBERATE: no retry action here, overriding `14-UI-SPEC.md:718`'s
        // "Try starting the job again" button. Whether
        // `requestGeniusSDKProcess` can safely be re-called after a
        // successful bridge is parked in native SuperGenius territory
        // (`.planning/todos/pending/2026-07-29-can-requestgeniussdkprocess-
        // be-recalled-after-a-successful-bridge.md`) - a retry that
        // double-spends a bridge is worse than no button. `Get help` fills
        // that slot instead (`14-09-PLAN.md` Task 3c, DECIDED by Jakub:
        // routes to the Feedback tab with the failure prefilled).
        // `gradientOutline` on both (2026-07-31 census fix, was the app's
        // only `secondary`/flat-blue CTA) - neither is a commitment, and
        // this surface must not gain a filled CTA that would compete with
        // the deliberate absence of `Try again`.
        return Row(
          children: [
            Expanded(
              child: GWButton(
                variant: GWButtonVariant.gradientOutline,
                expand: true,
                label: 'Get help',
                onPressed: () {
                  // Capture the router handle BEFORE `_close()` pops.
                  // `_ResultFooter` sits inside the drawer's route, which
                  // `ResponsiveDrawer.show` pushed on the ROOT navigator
                  // (`job_drawer.dart:49`, `responsive_drawer.dart:99`),
                  // while `/logs` lives under the `ShellRoute`. Reading
                  // `GoRouter.of(context)` AFTER `_close()` runs would
                  // resolve it against a context that is being unmounted -
                  // exactly how `swap_settings_drawer.dart:52-63` popped
                  // the wrong navigator once already, and this flow's cost
                  // for that mistake would be a user's burned-token
                  // receipt.
                  final router = GoRouter.of(context);
                  final message = _bridgedNotProcessedHelpMessage(state);
                  _close();
                  router.push('/logs', extra: message);
                },
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space4),
            Expanded(child: closeButton),
          ],
        );

      case SubmitOutcome.bridgeFailed:
        // Nothing was spent, so retrying is free - `14-UI-SPEC.md:719`.
        return Row(
          children: [
            Expanded(
              child: GWButton(
                variant: GWButtonVariant.gradient,
                expand: true,
                label: 'Try again',
                // Same in-flight guard as the `Confirm and pay` CTA at the
                // step-2 footer above. `bridgeTokens()` now clears `outcome`
                // on entry, so this footer unmounts on the first tap anyway -
                // this is the belt to that braces, and it keeps the two
                // entry points into the same cubit method written the same
                // way.
                onPressed: state.isBridgingTokens ? null : cubit.bridgeTokens,
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space4),
            Expanded(child: closeButton),
          ],
        );

      case SubmitOutcome.notSubmitted:
        return const SizedBox.shrink();
    }
  }
}
