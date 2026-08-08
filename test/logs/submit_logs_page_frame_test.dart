import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/logs/submit_logs_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:provider/provider.dart';

/// The `/logs` PAGE FRAME as Phase 20 (sketch 153-B "Focused frame") builds it:
/// the `large` width cap, the title back on the frame's left edge, and the
/// receipt rail beside the composer.
///
/// **This file pumps the REAL screen**, not a hand-copied replica of its tree.
/// A replica cannot fail for the reason this file exists: swapping the frame
/// cap back to `xxl`, or re-wrapping the header in a 560 `Center`, would leave
/// a replica green because no test would ever read `submit_logs_screen.dart`.
///
/// Harness trap, the same one `transactions_page_frame_test.dart` documents:
/// `flutter_test`'s surface is **800x600 logical** and nothing in this repo
/// changes it. This file's whole subject is a 1024 cap and a ~1020 two-column
/// threshold, neither of which is reachable on the default surface — so every
/// pump goes through [_surface], and its teardowns are not optional: a leaked
/// surface changes every file that runs after this one.
///
/// What this file does NOT cover, for the phase walk to judge:
///
///  * **The SDK-running rail rows.** Every pump here has the SDK stopped, so
///    the rail shows its "no logs" reason rather than the two probe rows.
///    Reaching the running state needs a real SDK, a real base path and files
///    on disk.
///  * **The Failed status string.** It needs a live Sentry round-trip. Test 3
///    proves the button/status arrangement in the No-SDK state instead — the
///    arrangement is unconditional, so proving it once proves it for Failed,
///    whose 130-character message is what the fix is really about.
///  * **Light mode**, and the send path itself.

/// The single state reachable without a real SDK, a real base path and a live
/// Sentry — and the page GEOMETRY under test is identical in every state.
///
/// The one override keeps `_probeAttachments` off the disk: it returns early
/// and leaves an empty probe list. `noSuchMethod` forwards to `super` so that
/// if the screen ever starts calling something else, this stub throws loudly
/// instead of handing back a silent null that the assertions would then
/// misread as a layout result.
class _StoppedSdkApi implements GeniusApi {
  @override
  bool get isSdkInitialized => false;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Widget _host() => Provider<GeniusApi>.value(
  value: _StoppedSdkApi(),
  child: MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<dynamic>>[GWColors.dark()]),
    home: const SubmitLogsScreen(),
  ),
);

void _surface(WidgetTester tester, double width, [double height = 900]) {
  tester.view.physicalSize = Size(width * 3, height * 3); // logical x dpr
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Anchored on CONTENT, not on index, so a reorder does not silently retarget
/// the assertions at the wrong card.
Finder _composerCard() => find
    .ancestor(of: find.byType(TextField), matching: find.byType(GWCard))
    .first;

Finder _railCard() => find
    .ancestor(
      of: find.text('Attached automatically'),
      matching: find.byType(GWCard),
    )
    .first;

void main() {
  testWidgets(
    'the frame caps at large, the title sits on its left edge, and the rail '
    'sits beside the composer',
    (tester) async {
      // WIDER than the cap, so the cap actually binds. At the cap itself it
      // would not bind and this would silently measure the viewport.
      _surface(tester, 2000);
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(GWPageHeader)).width,
        closeTo(GeniusBreakpoints.large, 1),
        reason: 'the page frame must cap at large (1024), not xxl (1536)',
      );

      // The title used to share the composer's left EDGE exactly. Since
      // 2026-08-08 `GWPageHeader` insets its left-aligned identity row by
      // `gwPageHeaderContentInset`, so the title sits that far inside the
      // card's edge - heading the page's content column, the change Jakub
      // asked for on every page title.
      //
      // The assertion this case exists for is unchanged in kind: it still
      // fails the moment the 560 `Center` wrapper or `centered: true` comes
      // back, because either would move the title by far more than this inset
      // and in the wrong direction. The inset is READ from the component
      // rather than restated, so the two cannot drift.
      //
      // Named cost: the composer's own text starts at `space12` + 1 = 25
      // inside its card, so the title lands 4px left of it at this width. One
      // inset for every page title beats four insets that each align with one
      // page.
      final BuildContext headerContext = tester.element(
        find.byType(GWPageHeader),
      );
      expect(
        tester.getTopLeft(find.text('Send Feedback')).dx,
        moreOrLessEquals(
          tester.getTopLeft(_composerCard()).dx +
              gwPageHeaderContentInset(headerContext),
          epsilon: 0.5,
        ),
        reason:
            'the title sits one content inset inside the composer\'s left '
            'edge. This is the assertion that fails if the 560 Center wrapper '
            'or centered: true comes back',
      );

      expect(
        tester.getSize(_composerCard()).width,
        closeTo(GeniusBreakpoints.small, 1),
        reason: 'the composer column is small (640)',
      );

      expect(
        tester.getRect(_composerCard()).right,
        lessThan(tester.getRect(_railCard()).left),
        reason: 'the rail sits BESIDE the composer, not under it',
      );

      expect(
        tester.getRect(_railCard()).top,
        moreOrLessEquals(tester.getRect(_composerCard()).top, epsilon: 0.5),
        reason: 'the two cards have level tops',
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('below the two-column width the rail stacks under the composer', (
    tester,
  ) async {
    // Content is 1000 - 24 = 976, under the ~1020 threshold, so the stacked
    // branch binds.
    _surface(tester, 1000);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(
      tester.getRect(_railCard()).left,
      moreOrLessEquals(tester.getRect(_composerCard()).left, epsilon: 0.5),
      reason: 'stacked, the two cards share one left edge',
    );

    expect(
      tester.getRect(_railCard()).top,
      greaterThanOrEqualTo(tester.getRect(_composerCard()).bottom),
      reason: 'the rail is BELOW the composer once stacked',
    );

    expect(
      tester.getSize(_composerCard()).width,
      closeTo(1000 - 24, 1),
      reason: 'viewport minus the two 12px page gutters',
    );

    // Catches a RenderFlex overflow report, which is the real failure mode of
    // a rail row squeezed into a narrow column.
    expect(tester.takeException(), isNull);
  });

  testWidgets('the send action sits below the status line, never beside it', (
    tester,
  ) async {
    _surface(tester, 1000);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // The No-SDK status line the stub puts the screen into: ~78 characters,
    // which wraps in the harness's wide fallback font — exactly the condition
    // that parks the button mid-block today. The arrangement is
    // unconditional, so proving it here proves it for the Failed state's
    // 130-character message, which no test can reach without a live Sentry.
    final status = find.text(
      'Start the SDK first - feedback needs it running to attach logs and send.',
    );

    expect(
      tester.getRect(find.byType(GWButton).first).top,
      greaterThanOrEqualTo(tester.getRect(status).bottom),
      reason: 'the send button sits below the status block, not beside it',
    );
  });

  testWidgets('the type labels are centred in their segments', (tester) async {
    // Regression guard for a Stack trap: a Stack hands its non-positioned
    // children LOOSE constraints, so a Text inside one shrink-wraps and
    // `textAlign: center` centres nothing. Every label sat flush left while
    // the underline — which DOES span the segment — no longer agreed with it.
    //
    // Measured against each label's OWN segment rather than against a computed
    // third: the segment is the box the underline spans, so this asserts the
    // thing that actually has to line up.
    _surface(tester, 1400);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    for (final label in ['Bug', 'Idea', 'Question']) {
      final text = find.text(label);
      final segment = find
          .ancestor(of: text, matching: find.byType(InkWell))
          .first;
      expect(
        tester.getRect(text).center.dx,
        moreOrLessEquals(tester.getRect(segment).center.dx, epsilon: 1.0),
        reason: '"$label" must sit in the middle of its own segment',
      );
    }
  });
}
