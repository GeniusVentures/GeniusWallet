import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/scaffold/gw_screen.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/widgets/job_steps.dart';

/// `/submit_job` - the full-screen host for deep links and narrow viewports,
/// kept per `018-A`. Renders the IDENTICAL [JobFlowBody]/[JobFlowFooter] pair
/// the drawer host (`job_drawer.dart`) renders - one flow, two hosts
/// (`14-UI-SPEC.md` §6.7).
///
/// Unlike the drawer, this host's [SubmitJobCubit] stays route-scoped
/// (`router.dart:299-312`, unchanged by this plan) - the cubit already lives
/// directly above this widget in the same nested Navigator, so none of
/// `job_drawer.dart`'s root-navigator/dual-subtree hazards apply here.
///
/// Replaces the hand-rolled frame this file used to build (a `ConstrainedBox`
/// at `GeniusBreakpoints.large` wrapped in a `SingleChildScrollView` inside an
/// `Align`) with [GWScreen] - not a new layout import, a deletion of an
/// equivalent one already built by hand. The content cap narrows to 640
/// because a five-step vertical list at 1200px is a very long line
/// (`14-UI-SPEC.md:756`).
///
/// The two toast listeners this file used to carry are gone. Every error now
/// renders inline at the step that produced it, and a result is a step that
/// stays on screen, not a toast that fades - see `job_steps.dart`'s
/// `JobResultBody`/`JobChooseFileBody`/`JobCostBody`.
class SubmitJobScreen extends StatefulWidget {
  const SubmitJobScreen({super.key});

  @override
  State<SubmitJobScreen> createState() => _SubmitJobScreenState();
}

class _SubmitJobScreenState extends State<SubmitJobScreen> {
  late final ValueNotifier<int> _manualIndex;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SubmitJobCubit>();
    _manualIndex = ValueNotifier<int>(cubit.state.uploadedJson.isEmpty ? 0 : 1);
  }

  @override
  void dispose() {
    _manualIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GWScreen(
      maxContentWidth: 640,
      bottomNavigationBar: JobFlowFooter(manualIndex: _manualIndex),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GWPageHeader(title: 'New processing job'),
          JobFlowBody(manualIndex: _manualIndex),
        ],
      ),
    );
  }
}
