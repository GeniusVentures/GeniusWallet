import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/inputs/gw_keyboard_done_bar.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../banxa/gw_pump.dart';

/// `GWKeyboardDoneBar` - the way out of the iOS decimal pad, which has no
/// return key of its own.
///
/// The suite runs on macOS, so the component's real gate
/// (`GeniusBreakpoints.isMobileApp`, i.e. `Platform.isIOS`) answers false here
/// and cannot be overridden the way `defaultTargetPlatform` can. Every test
/// below therefore passes the `@visibleForTesting` seam explicitly, including
/// the one that pins the desktop half.
bool _touch() => true;

bool _notTouch() => false;

/// The confirm control. This was `find.text('Done')` until the iOS 26 pass
/// swapped the word for the glyph Safari's own accessory bar uses; every
/// assertion that used to name the word now names the tick, and nothing else
/// about those assertions changed.
Finder _tick() => find.byIcon(Icons.check);

Finder _previous() => find.byIcon(Icons.keyboard_arrow_up);

Finder _next() => find.byIcon(Icons.keyboard_arrow_down);

/// The tap target behind a glyph, as opposed to the glyph's own 22pt box.
Finder _target(Finder glyph) =>
    find.ancestor(of: glyph, matching: find.byType(InkWell)).first;

/// The island itself: the nearest `Material` above the tick, which is laid
/// out to the floating bar's exact extent (the `Positioned` fixes its width,
/// the `SizedBox` its height).
Finder _island() =>
    find.ancestor(of: _tick(), matching: find.byType(Material)).at(0);

Color _glyphColour(WidgetTester tester, Finder glyph) =>
    tester.widget<Icon>(glyph).color!;

void main() {
  final gw = GWColors.dark();

  Widget amountField({
    required FocusNode node,
    required bool Function() platform,
    bool enabled = true,
  }) => GWKeyboardDoneBar(
    enabled: enabled,
    isTouchPlatform: platform,
    child: TextField(
      focusNode: node,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    ),
  );

  testWidgets(
    'the bar appears on focus, and the tick takes away both the bar and the '
    'focus',
    (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        gwHost(amountField(node: node, platform: _touch)),
      );
      expect(
        _tick(),
        findsNothing,
        reason: 'nothing is focused yet, so there is no keyboard to sit above',
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);
      expect(_tick(), findsOneWidget);

      // Apple's 44pt floor, on the InkWell and not on the glyph: the target is
      // the bar's full height by way of `CrossAxisAlignment.stretch`, which is
      // the line a well-meaning tidy-up would delete. Since the iOS 26 restyle
      // the bar is 44 rather than 48, so the vertical axis sits exactly ON the
      // floor and the horizontal one is carried by the button's own padding.
      final target = tester.getSize(_target(_tick()));
      expect(target.height, 44.0);
      expect(
        target.width,
        96.0,
        reason:
            'the word "Done" measured 97 wide here and about 76 in Inter (the '
            'test font draws every glyph one em wide); the glyph that '
            'replaced it must not cost anyone that target, so the button '
            'carries a FIXED 96 - the 4-pt-grid step that covers both, and '
            'font-independent where the string was not',
      );

      await tester.tap(_tick());
      await tester.pumpAndSettle();
      expect(
        node.hasFocus,
        isFalse,
        reason:
            'the tick exists to dismiss the keyboard, so it must drop '
            'focus',
      );
      expect(
        _tick(),
        findsNothing,
        reason: 'and the bar must not outlive the keyboard it sat on',
      );
    },
  );

  testWidgets('tapping away is the other exit, and it also retires the bar', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(gwHost(amountField(node: node, platform: _touch)));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(_tick(), findsOneWidget);

    // Empty canvas well below the field. Flutter's own `onTapOutside` default
    // is a no-op on iOS, which is half of why this component exists.
    await tester.tapAt(const Offset(400, 400));
    await tester.pumpAndSettle();
    expect(node.hasFocus, isFalse);
    expect(_tick(), findsNothing);
  });

  testWidgets('a field disposed while focused leaves no bar behind', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(gwHost(amountField(node: node, platform: _touch)));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(_tick(), findsOneWidget);

    // Navigating away with the keyboard open: the field goes, and the entry
    // it put in an overlay that OUTLIVES it has to go with it.
    await tester.pumpWidget(gwHost(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(_tick(), findsNothing);
  });

  testWidgets(
    'under a shell navigator the bar anchors to the SCREEN, not the shell body',
    (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: Scaffold(
            body: Column(
              children: [
                // `router.dart`'s ShellRoute navigator: the screens live in a
                // nested Navigator that stops short of the bottom nav bar
                // below it. Its overlay is the NEAREST one, and an entry put
                // there would be positioned inside this box.
                Expanded(
                  child: Navigator(
                    onGenerateRoute: (settings) => MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: amountField(node: node, platform: _touch),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(_island()).bottom,
        // The 800x600 default test surface, less the 8pt clearance the iOS 26
        // restyle put under the island (this assertion read a flush 600.0
        // while the bar was a full-bleed band). The keyboard rises from the
        // bottom of the SCREEN, so that is still the only edge the bar may
        // track; anchored to the shell body it would land near 480 and float
        // above a nav bar instead.
        600.0 - 8.0,
      );
    },
  );

  testWidgets('inside a root-navigator modal sheet the bar renders ON TOP', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                // What `ResponsiveDrawer.show` passes, and the reason the bar
                // hosts itself in the ROOT overlay rather than the nearest.
                useRootNavigator: true,
                builder: (_) => SizedBox(
                  height: 300,
                  child: amountField(node: node, platform: _touch),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(_tick(), findsOneWidget);

    // The sheet occupies the bottom of the screen and so does the bar, so
    // "renders on top" is a hit-test question, not a findsOneWidget one: a
    // bar in the WRONG overlay is still in the tree, just unreachable.
    final barSurface = tester.renderObject(_island());
    final hit = tester.hitTestOnBinding(tester.getCenter(_tick()));
    expect(hit.path.map((entry) => entry.target), contains(barSurface));
  });

  testWidgets('the island rides above the keyboard, never flush against it', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    // 900 physical over the test view's 3.0 device pixel ratio is 300 logical
    // - a plausible decimal pad on the 800x600 surface.
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(gwHost(amountField(node: node, platform: _touch)));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(_island()).bottom,
      600.0 - 300.0 - 8.0,
      reason:
          'iOS 26 gave the keyboard a rounded top margin, so no accessory '
          'view sits flush on it any more: the island clears it by space4 '
          '(8), and that clearance is measured off the LIVE inset so it '
          'rides the keyboard down rather than opening up once it settles',
    );
  });

  testWidgets('the island is inset from both screen edges, and is 44 tall', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(gwHost(amountField(node: node, platform: _touch)));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    final island = tester.getRect(_island());
    // space10 (20) is `GWScreen`'s own horizontal page padding, so the island
    // lines up with the form it floats over instead of cutting across it. The
    // full-bleed band this replaced measured 0 and 800 here.
    expect(island.left, 20.0);
    expect(island.right, 800.0 - 20.0);
    expect(
      island.height,
      44.0,
      reason:
          'the platform toolbar height, down from the 48 (space24) the '
          'pre-iOS-26 band used to buy headroom over the 44pt target floor',
    );
    // Three controls on a 44pt bar, and they are not allowed to grow it: the
    // chevrons take Apple's floor plus the island's own 16pt gutter either
    // side of a 22pt glyph.
    expect(tester.getSize(_target(_previous())), const Size(54.0, 44.0));
    expect(tester.getSize(_target(_next())), const Size(54.0, 44.0));
  });

  testWidgets('off a touch platform the child renders untouched', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    await tester.pumpWidget(
      gwHost(amountField(node: node, platform: _notTouch)),
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(node.hasFocus, isTrue);
    expect(
      _tick(),
      findsNothing,
      reason: 'there is no on-screen keyboard on a desktop to sit above',
    );
  });

  testWidgets('a disabled wrapper never raises a bar', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    // Swap's "You Receive" side: focusable for selection, `readOnly`, so it
    // opens no keyboard.
    await tester.pumpWidget(
      gwHost(amountField(node: node, platform: _touch, enabled: false)),
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(node.hasFocus, isTrue);
    expect(_tick(), findsNothing);
  });

  testWidgets('a lone field gets both chevrons, dead and legibly so', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);

    // Swap, Bridge, Banxa and the slippage drawer are all this shape: one
    // numeric field on the surface, so there is nowhere to step.
    await tester.pumpWidget(gwHost(amountField(node: node, platform: _touch)));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(_previous(), findsOneWidget);
    expect(_next(), findsOneWidget);
    // Not a fade to nothing: the disabled step drops the brand colour for the
    // muted foreground, which still measures 4.60:1 dark / 4.93:1 light on the
    // island's translucent fill - past 1.4.11's 3:1 for a non-text control.
    expect(_glyphColour(tester, _previous()), gw.textSecondary);
    expect(_glyphColour(tester, _next()), gw.textSecondary);
    expect(_glyphColour(tester, _tick()), gw.brandPrimaryOnSurface);

    // And genuinely inert, not merely grey: no callback reaches the InkWell,
    // so the tap changes nothing and the bar stays up.
    await tester.tap(_next());
    await tester.pumpAndSettle();
    expect(node.hasFocus, isTrue);
    expect(_tick(), findsOneWidget);
  });

  testWidgets('the chevrons step between sibling fields in reading order', (
    tester,
  ) async {
    final first = FocusNode();
    final second = FocusNode();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    // `settings_screen.dart`'s shape: numeric rows stacked down one surface.
    await tester.pumpWidget(
      gwHost(
        Column(
          children: [
            amountField(node: first, platform: _touch),
            amountField(node: second, platform: _touch),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    expect(_glyphColour(tester, _previous()), gw.textSecondary);
    expect(
      _glyphColour(tester, _next()),
      gw.brandPrimaryOnSurface,
      reason: 'there is a field below, so down is live',
    );

    await tester.tap(_next());
    await tester.pumpAndSettle();
    expect(second.hasFocus, isTrue);
    expect(first.hasFocus, isFalse);
    expect(
      _tick(),
      findsOneWidget,
      reason:
          'the bar the first field left behind must not linger under the '
          'second one, or the third hop would drive the wrong field',
    );
    expect(_glyphColour(tester, _previous()), gw.brandPrimaryOnSurface);
    expect(_glyphColour(tester, _next()), gw.textSecondary);

    await tester.tap(_previous());
    await tester.pumpAndSettle();
    expect(first.hasFocus, isTrue);
  });

  testWidgets('a wrapper built with enabled: false is not a stop', (
    tester,
  ) async {
    final typed = FocusNode();
    final readOnly = FocusNode();
    addTearDown(typed.dispose);
    addTearDown(readOnly.dispose);

    // Swap exactly: "You Pay" is wrapped live, "You Receive" is wrapped inert
    // because it is `readOnly` and opens no keyboard. Stepping onto it would
    // take the bar away mid-navigation, so it must not be reachable.
    await tester.pumpWidget(
      gwHost(
        Column(
          children: [
            amountField(node: typed, platform: _touch),
            amountField(node: readOnly, platform: _touch, enabled: false),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    expect(_glyphColour(tester, _previous()), gw.textSecondary);
    expect(
      _glyphColour(tester, _next()),
      gw.textSecondary,
      reason: 'the only other field on the surface raises no keyboard',
    );

    await tester.tap(_next());
    await tester.pumpAndSettle();
    expect(typed.hasFocus, isTrue);
    expect(readOnly.hasFocus, isFalse);
  });

  testWidgets('a bar in a sheet cannot step onto the screen underneath it', (
    tester,
  ) async {
    final behind = FocusNode();
    final inSheet = FocusNode();
    addTearDown(behind.dispose);
    addTearDown(inSheet.dispose);

    // Swap's slippage drawer over Swap's amount field. Both are live numeric
    // fields and both are in the registry, but only one of them is on the
    // surface the user can see - `ModalRoute` gives each route its own
    // `FocusScope`, which is what tells them apart.
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                amountField(node: behind, platform: _touch),
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    useRootNavigator: true,
                    builder: (_) => SizedBox(
                      height: 300,
                      child: amountField(node: inSheet, platform: _touch),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();
    expect(inSheet.hasFocus, isTrue);

    expect(_glyphColour(tester, _previous()), gw.textSecondary);
    expect(
      _glyphColour(tester, _next()),
      gw.textSecondary,
      reason:
          'the field on the screen below is real and live, but it is not on '
          'this surface, and stepping to it would type behind the sheet',
    );
  });

  testWidgets('a chevron with nowhere to go is disabled to a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final first = FocusNode();
    final second = FocusNode();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(
      gwHost(
        Column(
          children: [
            amountField(node: first, platform: _touch),
            amountField(node: second, platform: _touch),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    // The glyphs replaced words, so the words have to survive somewhere. The
    // dead chevron carries the enabled FLAG as well, which is what makes
    // VoiceOver say "dimmed" instead of offering a control that does nothing.
    expect(
      tester.getSemantics(_target(_previous())),
      matchesSemantics(
        label: 'Previous field',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        // Not focusable either: an InkWell with no callback registers no
        // gesture, so there is no tap action to offer and nothing to land on.
      ),
    );
    expect(
      tester.getSemantics(_target(_next())),
      matchesSemantics(
        label: 'Next field',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(_target(_tick())),
      matchesSemantics(
        label: 'Done',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });
}
