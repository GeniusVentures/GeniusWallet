// Check for the canvas background reaching shipping UI.
//
// The failure this guards against is the one PR #221 review caught: an asset
// (`assets/images/textures/noise.png`) shipped in the bundle while its only
// consumer, `GWCanvasBackground`, was instantiated nowhere but the dev design
// gallery. Asserting the widget exists proves nothing — the review's question
// was whether anything a USER reaches renders it. So these assertions walk the
// tree from `GWScreen`, the sanctioned page wrapper, down to the AssetImage.
//
// The `background:`-was-named case is the other half: a caller that picked its
// own fill must keep it, or adopting the canvas silently repaints screens that
// had already settled on a colour.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/scaffold/gw_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
  home: child,
);

/// The grain layer, found by the asset it names rather than by widget type —
/// this is the assertion that ties the test to the file on disk.
final Finder _noiseGrain = find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == 'assets/images/textures/noise.png',
);

void main() {
  testWidgets('GWScreen wraps its body in the canvas by default', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const GWScreen(child: Text('body'))));

    expect(find.byType(GWCanvasBackground), findsOneWidget);
    // Default appearance is dark, and the grain is the dark-mode-only layer.
    expect(_noiseGrain, findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('a caller-named background opts out of the canvas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        GWScreen(
          background: GWColors.dark().surfaceElevated,
          child: const Text('body'),
        ),
      ),
    );

    expect(find.byType(GWCanvasBackground), findsNothing);
    expect(_noiseGrain, findsNothing);
    expect(find.text('body'), findsOneWidget);
  });
}
