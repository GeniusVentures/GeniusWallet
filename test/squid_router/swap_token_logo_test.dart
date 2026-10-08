import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/swap_token_logo.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Widget _app(Widget child) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Center(child: child),
);

/// Builds the logo without mounting it, so no SVG fetch starts: the test
/// binding answers every request with a 400 and flutter_svg reports that as an
/// uncaught error.
Future<(BuildContext, Widget)> _build(WidgetTester tester, String url) async {
  late BuildContext context;
  late Widget built;
  await tester.pumpWidget(
    _app(
      Builder(
        builder: (c) {
          context = c;
          built = SwapTokenLogo(url: url, size: 36).build(c);
          return const SizedBox();
        },
      ),
    ),
  );
  return (context, (built as ClipOval).child!);
}

bool _isBrokenDisc(Widget w) =>
    w is Container && (w.child as Icon?)?.icon == Icons.broken_image;

bool _isBlankDisc(Widget w) => w is Container && w.child == null;

void main() {
  testWidgets('an SVG logo builds SvgPicture with the disc fallbacks', (
    tester,
  ) async {
    final (context, logo) = await _build(
      tester,
      'https://example.com/tokens/eth.svg?v=2',
    );

    expect(logo, isA<SvgPicture>());
    final svg = logo as SvgPicture;
    expect(_isBlankDisc(svg.placeholderBuilder!(context)), isTrue);
    expect(
      _isBrokenDisc(
        svg.errorBuilder!(context, Exception('bad'), StackTrace.empty),
      ),
      isTrue,
    );
  });

  testWidgets('a PNG logo builds Image.network with the disc fallbacks', (
    tester,
  ) async {
    final (context, logo) = await _build(
      tester,
      'https://example.com/tokens/usdc.png',
    );

    expect(logo, isA<Image>());
    final image = logo as Image;
    expect(image.image, isA<NetworkImage>());
    expect(
      _isBlankDisc(
        image.loadingBuilder!(
          context,
          const SizedBox(),
          const ImageChunkEvent(
            cumulativeBytesLoaded: 1,
            expectedTotalBytes: 2,
          ),
        ),
      ),
      isTrue,
    );
    expect(
      _isBrokenDisc(image.errorBuilder!(context, Exception('bad'), null)),
      isTrue,
    );
  });

  testWidgets('a PNG that fails to load shows the broken disc', (tester) async {
    await tester.pumpWidget(
      _app(
        const SwapTokenLogo(
          url: 'https://example.com/tokens/usdc.png',
          size: 36,
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('no logo is a plain disc of the same size', (tester) async {
    await tester.pumpWidget(_app(const SwapTokenLogo(url: null, size: 36)));

    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(tester.getSize(find.byType(SwapTokenLogo)), const Size(36, 36));
  });
}
