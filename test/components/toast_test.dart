import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_widget.dart';

/// Pumps a host whose button raises a toast, at [size] with [topInset] of
/// safe area — the two inputs the placement is derived from.
Future<BuildContext> _pumpHost(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double topInset = 47,
}) async {
  late BuildContext captured;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: EdgeInsets.only(top: topInset),
      ),
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            captured = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  tearDown(() => ToastManager.instance.disposeAll());

  group('density is chosen by the title, except for errors', () {
    testWidgets('no title gives a compact pill with no dismiss button', (
      tester,
    ) async {
      final context = await _pumpHost(tester);
      showToast(context, 'Link copied');
      await tester.pump();

      expect(find.text('Link copied'), findsOneWidget);
      // The compact density is a receipt: it carries no close affordance,
      // because nothing is lost if it is missed.
      expect(find.byTooltip('Dismiss'), findsNothing);

      final toast = tester.widget<ToastWidget>(find.byType(ToastWidget));
      expect(toast.density, ToastDensity.compact);
    });

    testWidgets('a title gives the card, with a 44pt dismiss target', (
      tester,
    ) async {
      final context = await _pumpHost(tester);
      showToast(
        context,
        'Please try again.',
        title: 'Verification failed',
        type: ToastType.error,
      );
      await tester.pump();

      final toast = tester.widget<ToastWidget>(find.byType(ToastWidget));
      expect(toast.density, ToastDensity.card);

      expect(find.byTooltip('Dismiss'), findsOneWidget);
      final button = tester.getSize(find.byType(IconButton));
      // Phase 25 set 44pt as the floor for a tap target; the toast's close
      // button was ~28 before this.
      expect(button.width, greaterThanOrEqualTo(44));
      expect(button.height, greaterThanOrEqualTo(44));
    });

    testWidgets('an untitled error still gets the card', (tester) async {
      // The migration left several failure paths calling showToast with a
      // type and no title — swap_screen's two, banxa's browser failure. As a
      // compact pill each was ellipsized to one line, carried no dismiss
      // button and vanished in two seconds, taking the half of the sentence
      // that says what to do with it.
      final context = await _pumpHost(tester);
      showToast(
        context,
        'Failed to load tokens. Check your connection and try again.',
        type: ToastType.error,
      );
      await tester.pump();

      final toast = tester.widget<ToastWidget>(find.byType(ToastWidget));
      expect(toast.density, ToastDensity.card);
      expect(toast.title, 'Error');
      expect(find.byTooltip('Dismiss'), findsOneWidget);
    });

    testWidgets('an untitled success is still a receipt', (tester) async {
      final context = await _pumpHost(tester);
      showToast(context, 'Link copied', type: ToastType.success);
      await tester.pump();

      expect(
        tester.widget<ToastWidget>(find.byType(ToastWidget)).density,
        ToastDensity.compact,
      );
    });
  });

  testWidgets('a screen reader is handed both halves of an alert', (
    tester,
  ) async {
    final context = await _pumpHost(tester);
    showToast(
      context,
      'Please try again.',
      title: 'Verification failed',
      type: ToastType.error,
    );
    await tester.pump();

    final toast = tester.widget<ToastWidget>(find.byType(ToastWidget));
    expect(toast.semanticLabel, 'Verification failed. Please try again.');

    final semantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byType(ToastWidget),
            matching: find.byType(Semantics),
          )
          .first,
    );
    // Without liveRegion the toast is never announced at all — which for
    // "Verification failed" is the whole notification going missing.
    expect(semantics.properties.liveRegion, isTrue);
  });

  testWidgets('toast text carries no inherited debug underline', (
    tester,
  ) async {
    final context = await _pumpHost(tester);
    showToast(
      context,
      'Please try again.',
      title: 'Verification failed',
      type: ToastType.error,
    );
    await tester.pump();

    // The overlay has no Material ancestor of its own. Without one, Text
    // inherits Flutter's fallback DefaultTextStyle — reddish, with a yellow
    // double underline — because the typography tokens set colour and size
    // but not `decoration`. It showed up on the first desktop walk.
    for (final text in <String>['Verification failed', 'Please try again.']) {
      final rich = tester.widget<RichText>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      );
      expect(
        rich.text.style?.decoration ?? TextDecoration.none,
        TextDecoration.none,
        reason: '"$text" picked up the no-Material fallback decoration',
      );
    }
  });

  testWidgets('the top offset is derived from the safe area, not a literal', (
    tester,
  ) async {
    // 47 and 20 stand in for a notched and an un-notched phone. The old code
    // hard-coded `top: 100` for both.
    for (final inset in <double>[47, 20]) {
      final context = await _pumpHost(tester, topInset: inset);
      showToast(context, 'Link copied');
      await tester.pump();

      final positioned = tester.widget<Positioned>(
        find
            .ancestor(
              of: find.byType(ToastWidget),
              matching: find.byType(Positioned),
            )
            .first,
      );
      // padding.top + mobile header (60) + space4 (8).
      expect(positioned.top, inset + 68);

      ToastManager.instance.disposeAll();
      await tester.pump(const Duration(milliseconds: 400));
    }
  });

  testWidgets('the stack caps at three and evicts the oldest', (tester) async {
    final context = await _pumpHost(tester);
    for (var i = 1; i <= 5; i++) {
      showToast(context, 'Toast $i');
      await tester.pump();
    }

    // Was uncapped: the sixth used to sit off the bottom of the screen.
    expect(ToastManager.instance.visibleCount, 3);
    expect(find.text('Toast 1'), findsNothing);
    expect(find.text('Toast 5'), findsOneWidget);
  });

  testWidgets('a torn-down tree leaves no timer running', (tester) async {
    final context = await _pumpHost(tester);
    showToast(context, 'Link copied');
    await tester.pump();
    expect(ToastManager.instance.visibleCount, 1);

    // Replacing the tree disposes the overlay. If the auto-dismiss timer were
    // held by the manager rather than the State it would outlive this and the
    // test would fail with a pending timer.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(ToastManager.instance.visibleCount, 0);
  });
}
