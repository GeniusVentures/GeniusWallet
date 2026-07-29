import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';

/// Success criterion 1 expressed as one assertion, without a golden: build
/// the view model for every member of `ComputeState.values`, collect a tuple
/// of the fields a user can actually perceive, and assert they are pairwise
/// distinct. This is a stronger check than a screenshot, because it fails on
/// the REASON two states look alike, not merely on the fact that they do.
///
/// Shape copied from `test/dashboard/bridge/bridge_cta_state_test.dart:223-230`'s
/// exhaustive-enum group.
void main() {
  group('compute state view models — pairwise distinct', () {
    test(
      'every ComputeState.values member renders a distinct '
      '(dotRole, label, subline, trailing, showBar) tuple',
      () {
        // Iterating `values` — rather than a hand-written list of the eight
        // states — means this test fails automatically the moment someone
        // adds a ninth ComputeState member without differentiating it from
        // the existing eight. That includes whoever un-parks the stalled
        // state: the moment it gets a real ComputeState.stalled member, this
        // test starts enforcing that ITS tuple is distinct too, with zero
        // changes needed here.
        final tuples = ComputeState.values.map((state) {
          final view = viewForComputeState(
            state,
            // Plausible mid-flight values so startingUp/processing render a
            // real bar rather than clamping to 0 — the tuple must still be
            // distinct under realistic inputs, not just at the edges.
            initStatusMessage: 'Connecting to the SGNUS network',
            initPercentage: 0.5,
            processingPercentage: 50.0,
          );
          return (
            view.dotRole,
            view.label,
            view.subline,
            view.trailing,
            view.showBar,
          );
        }).toSet();

        expect(tuples.length, ComputeState.values.length);
      },
    );

    test(
      'unavailable and ready differ on the dot role, the label AND the '
      'sub-line — not merely on one of them. Today both render the same '
      'grey word (sgnus_connection_widget.dart:125-127); this is the pair '
      'this phase exists to separate.',
      () {
        final unavailable = viewForComputeState(ComputeState.unavailable);
        final ready = viewForComputeState(ComputeState.ready);

        expect(unavailable.dotRole, isNot(ready.dotRole));
        expect(unavailable.label, isNot(ready.label));
        expect(unavailable.subline, isNot(ready.subline));
      },
    );
  });
}
