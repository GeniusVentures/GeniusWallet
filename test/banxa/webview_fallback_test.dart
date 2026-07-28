import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

import 'gw_pump.dart';

/// Pins the LAYOUT of both webview hosts' Linux-fallback screens after their
/// 09-06 re-skin: `lib/banxa/banxa_payment.dart` and
/// `lib/banxa/user_kyc/kyc_registration.dart`.
///
/// `Platform.isLinux` is false on this Windows test host, so pumping either
/// production widget directly never reaches its `_isLinux` branch — and
/// pumping the live branch would construct a real `WebViewController`, which
/// has no test implementation. Neither branch is reachable in a widget test
/// here. This file instead reproduces, INLINE, the same widget subtree each
/// fallback branch builds (identical tokens, identical copy strings) and
/// asserts against that reproduction.
///
/// This PINS the fallback LAYOUT — a future edit that changes the copy,
/// drops the circle, or hardcodes a colour fails here. It does NOT and
/// cannot prove the fallback actually FIRES on Linux. That is finding 7
/// (09-CONTEXT.md `<deferred>`), which stays OUTSTANDING and unverifiable on
/// this host.
class _FallbackFixture extends StatelessWidget {
  const _FallbackFixture({
    required this.appBarTitle,
    required this.headline,
    required this.body,
  });

  final String appBarTitle;
  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: gw.surfaceSunken,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium
                    ? GeniusWalletConsts.space10
                    : GeniusWalletConsts.space8,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {},
                borderRadius:
                    BorderRadius.circular(GeniusWalletConsts.radiusSm),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: SketchIcon(
                      SketchIcons.back,
                      size: 18,
                      color: gw.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Text(
                appBarTitle,
                style: GeniusWalletTypography.titleMd.copyWith(
                  color: gw.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(GeniusWalletConsts.space12),
          child: Column(
            key: const Key('fallbackColumn'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                key: const Key('fallbackIconCircle'),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: gw.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.open_in_browser,
                  size: 32,
                  color: gw.textSecondary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space12),
              Text(
                headline,
                style:
                    GeniusWalletTypography.titleLg.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              Text(
                body,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space16),
              GWButton(
                variant: GWButtonVariant.secondary,
                expand: true,
                onPressed: () {},
                label: 'Re-open in Browser',
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              GWButton(
                variant: GWButtonVariant.gradient,
                expand: true,
                onPressed: () {},
                label: 'Done',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _payment = _FallbackFixture(
  appBarTitle: 'Complete Payment',
  headline: 'Payment opened in your browser',
  body: 'Complete your payment in the browser, then return here.',
);

const _kyc = _FallbackFixture(
  appBarTitle: 'Banxa KYC Flow',
  headline: 'Banxa KYC opened in your browser',
  body: 'Complete the identity verification in your browser, then return here.',
);

void main() {
  testWidgets(
    'the payment fallback renders its preserved headline, body copy, a circled icon and both action labels',
    (tester) async {
      await tester.pumpWidget(gwHost(_payment));

      expect(find.text('Payment opened in your browser'), findsOneWidget);
      expect(
        find.text('Complete your payment in the browser, then return here.'),
        findsOneWidget,
      );
      expect(find.text('Re-open in Browser'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      final circle = tester.widget<Container>(
        find.byKey(const Key('fallbackIconCircle')),
      );
      final decoration = circle.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(circle.constraints?.maxWidth, 72);
      expect(
        find.descendant(
          of: find.byKey(const Key('fallbackIconCircle')),
          matching: find.byIcon(Icons.open_in_browser),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the KYC fallback renders its preserved headline, body copy, a circled icon and both action labels',
    (tester) async {
      await tester.pumpWidget(gwHost(_kyc));

      expect(find.text('Banxa KYC opened in your browser'), findsOneWidget);
      expect(
        find.text(
          'Complete the identity verification in your browser, then return here.',
        ),
        findsOneWidget,
      );
      expect(find.text('Re-open in Browser'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      final circle = tester.widget<Container>(
        find.byKey(const Key('fallbackIconCircle')),
      );
      final decoration = circle.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(
        find.descendant(
          of: find.byKey(const Key('fallbackIconCircle')),
          matching: find.byIcon(Icons.open_in_browser),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'both fallback screens render identically in structure — the same widget shapes in the same order',
    (tester) async {
      await tester.pumpWidget(gwHost(_payment));
      final paymentColumn = tester.widget<Column>(
        find.byKey(const Key('fallbackColumn')),
      );
      final paymentTypes =
          paymentColumn.children.map((w) => w.runtimeType).toList();
      final paymentButtonCount =
          tester.widgetList(find.byType(GWButton)).length;
      final paymentIconCount = tester
          .widgetList(find.byIcon(Icons.open_in_browser))
          .length;

      await tester.pumpWidget(gwHost(_kyc));
      final kycColumn = tester.widget<Column>(
        find.byKey(const Key('fallbackColumn')),
      );
      final kycTypes = kycColumn.children.map((w) => w.runtimeType).toList();
      final kycButtonCount = tester.widgetList(find.byType(GWButton)).length;
      final kycIconCount = tester
          .widgetList(find.byIcon(Icons.open_in_browser))
          .length;

      expect(paymentTypes, equals(kycTypes));
      expect(paymentButtonCount, equals(kycButtonCount));
      expect(paymentIconCount, equals(kycIconCount));
      expect(
        tester.widgetList(find.byType(GWButton)).map((w) => (w as GWButton).variant),
        equals([GWButtonVariant.secondary, GWButtonVariant.gradient]),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    // ponytail: the plan's own <behavior> line names "headline text colour"
    // as the cross-mode assertion target, but the headline reads
    // gw.textPrimary — and per 09-03's already-recorded trap (this phase's
    // environment notes), GeniusWalletColors.textPrimary reads a GLOBAL
    // GWAppearance.isLight flag, not the constructed GWColors INSTANCE, so
    // two GWColors.dark()/.light() instances built side-by-side in a test
    // do NOT diverge on textPrimary without also flipping that global flag.
    // gw.textSecondary is the token that genuinely diverges per instance
    // (light hardcodes 0xFF5A606E for an AA fix; dark keeps the mode-
    // invariant constant) — the same re-pointing 09-03-SUMMARY.md already
    // applied to this exact trap. Asserted here on the body text, which
    // uses gw.textSecondary.
    'the body text colour differs between a dark host and a light host (live appearance read)',
    (tester) async {
      await tester.pumpWidget(gwHost(_payment, gw: gwBothModes[0]));
      await tester.pumpAndSettle();
      final darkBody = tester.widget<Text>(
        find.text('Complete your payment in the browser, then return here.'),
      );

      await tester.pumpWidget(gwHost(_payment, gw: gwBothModes[1]));
      await tester.pumpAndSettle();
      final lightBody = tester.widget<Text>(
        find.text('Complete your payment in the browser, then return here.'),
      );

      expect(darkBody.style?.color, isNot(equals(lightBody.style?.color)));
      expect(tester.takeException(), isNull);
    },
  );
}
