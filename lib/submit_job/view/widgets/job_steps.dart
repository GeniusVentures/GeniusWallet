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
              steps: _buildSteps(state),
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

  List<JobStep> _buildSteps(SubmitJobState state) => [
    JobStep(
      title: 'Choose a file',
      summary: state.uploadedFileName.isEmpty ? null : state.uploadedFileName,
      body: JobChooseFileBody(state: state),
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

/// Step 1's body - `14-UI-SPEC.md:655`. A file error renders inline here,
/// never as a toast; picker progress is a spinner, not the shipped
/// full-screen [Loading] barrier it replaces (`submit_job_screen.dart:201`,
/// superseded).
class JobChooseFileBody extends StatelessWidget {
  const JobChooseFileBody({super.key, required this.state});

  final SubmitJobState state;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    if (state.isFilePickerOpen) {
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

    if (state.fileError.isNotEmpty) {
      return _InlineError(message: state.fileError, gw: gw);
    }

    return const SizedBox.shrink();
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
            _CostRow(label: 'Job cost', value: '${state.jobCost} GNUS', gw: gw),
            _CostRow(label: 'Bridge gas', value: state.jobGasCost, gw: gw),
            _CostRow(
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

/// One label/value row inside step 2's [GWDetailGrid] - `14-UI-SPEC.md:676`:
/// "Row labels `gw.textPrimary70`, values `gw.textPrimary`, both at
/// `bodySm`", mirroring `transaction_displays.dart:566-571`. Not [GWCopyRow]:
/// none of these three values is a clipboard target.
class _CostRow extends StatelessWidget {
  const _CostRow({required this.label, required this.value, required this.gw});

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

/// Step 3's body - one sentence naming irreversibility (`14-UI-SPEC.md:797`).
/// Step 2's grid stays visible above this as its collapsed summary - that is
/// [JobStepList]'s own doing, not this widget's.
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

/// Step 4's body - two separately labelled operations, not one spinner
/// (`14-UI-SPEC.md:698-711`). `bridgeOut()` spends the money;
/// `requestGeniusSDKProcess()` starts the work; only the first is
/// irreversible, and rendering them as a single spinner is precisely what let
/// the middle failure disappear in the shipped screen. The cubit gives no
/// signal distinguishing which of the two is currently running (both happen
/// inside one `isBridgingTokens` window with no intermediate emit - out of
/// this plan's fence, `lib/submit_job/cubit/` is plan 05's file), so both
/// rows spin together for the duration; what matters is that they are named
/// as two operations, not collapsed into one.
class JobInFlightBody extends StatelessWidget {
  const JobInFlightBody({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _InFlightRow(label: 'Bridging GNUS', gw: gw),
        const SizedBox(height: GeniusWalletConsts.space4),
        _InFlightRow(label: 'Starting the job', gw: gw),
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

class _InFlightRow extends StatelessWidget {
  const _InFlightRow({required this.label, required this.gw});

  final String label;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GWSpinner(size: 16),
        const SizedBox(width: GeniusWalletConsts.space4),
        Text(
          label,
          style: GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary),
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
              label: 'Tokens sent, job not started',
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
            const GWWarningNote(
              'Your GNUS was bridged but the job did not start. The '
              'transaction below is your proof that the transfer happened.',
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.gw});

  final String message;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, size: 16, color: gw.statusError),
        const SizedBox(width: GeniusWalletConsts.space4),
        Expanded(
          child: Text(
            message,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.statusError,
            ),
          ),
        ),
      ],
    );
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
                return GWButton(
                  variant: GWButtonVariant.secondary,
                  expand: true,
                  label: 'Choose a JSON file',
                  onPressed: state.isFilePickerOpen
                      ? null
                      : cubit.openFilePicker,
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
                  variant: GWButtonVariant.secondary,
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
      variant: GWButtonVariant.secondary,
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
        // double-spends a bridge is worse than no button. This footer is the
        // design slot for that CTA; when the parked question is answered,
        // it belongs here.
        return closeButton;

      case SubmitOutcome.bridgeFailed:
        // Nothing was spent, so retrying is free - `14-UI-SPEC.md:719`.
        return Row(
          children: [
            Expanded(
              child: GWButton(
                variant: GWButtonVariant.gradient,
                expand: true,
                label: 'Try again',
                onPressed: cubit.bridgeTokens,
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
