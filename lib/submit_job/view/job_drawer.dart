import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/widgets/job_steps.dart';

/// The job flow's drawer host - `F1 · Drawer, vertical steps`
/// (`14-CONTEXT.md`, `018-A`), `14-UI-SPEC.md` §6.1.
///
/// **Two provider facts with no precedent anywhere in this repo:**
///
/// 1. [SubmitJobCubit] is created per route at `router.dart:299-312`, below
///    the root navigator. [ResponsiveDrawer.show] pushes on the ROOT
///    navigator (`responsive_drawer.dart:99`), so a drawer body sees only
///    providers mounted above `MaterialApp.router` - `GeniusApi` and
///    `WalletDetailsCubit` qualify, this cubit does not. All ~20 existing
///    drawer call sites either read a root-level provider or hold plain local
///    state; not one of them provides a bloc into a drawer, so there is
///    nothing in this codebase to copy. This is why [show] takes the cubit
///    as an explicit parameter rather than reading it from `context` -
///    passing it in is what makes the hazard impossible to get wrong.
/// 2. `ResponsiveDrawer` hands the shell TWO separate subtrees - `child` and
///    `footer` (`responsive_drawer.dart:321, 331`) - so wrapping only one of
///    them in a `BlocProvider.value` leaves the other unable to resolve the
///    cubit, and the footer is exactly where the CTA that spends money
///    lives. Both are wrapped here.
///
/// **This host creates nothing and therefore disposes nothing** (besides its
/// own local step-navigation notifier). The caller owns the cubit's
/// lifetime - `isDismissible`/`enableDrag` are fixed at open time
/// (`responsive_drawer.dart:100-101`) and cannot be flipped mid-flight, so a
/// drawer-OWNED cubit would be destroyed by a barrier tap during the in-flight
/// step, taking the bridge hash with it - exactly the unrecoverable-hash bug
/// this phase exists to close. Do not add a `dispose` call for [cubit] here
/// by analogy with `swap_settings_drawer.dart:66-69` (which disposes what IT
/// creates) - this drawer does not create the cubit, so it must not close it.
class JobDrawer {
  static Future<void> show(
    BuildContext context, {
    required SubmitJobCubit cubit,
  }) {
    // Starts on the cost step when a file is already chosen (e.g. a dismiss
    // and reopen mid-review) rather than re-showing the choose step for a
    // job that has already been picked.
    final manualIndex = ValueNotifier<int>(
      cubit.state.uploadedJson.isEmpty ? 0 : 1,
    );

    return ResponsiveDrawer.show<void>(
      context: context,
      title: 'New processing job',
      child: BlocProvider<SubmitJobCubit>.value(
        value: cubit,
        child: JobFlowBody(manualIndex: manualIndex),
      ),
      footer: BlocProvider<SubmitJobCubit>.value(
        value: cubit,
        child: JobFlowFooter(
          manualIndex: manualIndex,
          // `context` here is the CALLER's, captured when the drawer opened
          // - `rootNavigator: true` matches the push in
          // `ResponsiveDrawer.show` so this resolves to the DRAWER's route,
          // never the caller's own shell route. Missing this popped the
          // wrong navigator once already (`swap_settings_drawer.dart:52-63`);
          // on this flow it would cost a user their burned-token receipt.
          onDismissDrawer: () =>
              Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
    ).whenComplete(manualIndex.dispose);
  }
}
