// Mobile bottom-sheet coverage for the shell's body inset (21-01).
//
// `responsive_drawer_body_padding_test.dart` already proves the desktop panel
// branch — every one of its cases runs at the default flutter_test surface
// size (800x600 logical px), which is wider than `GeniusBreakpoints.medium`
// (768), so `ResponsiveDrawer.show()` always took the `showDialog` branch
// there. This file is the missing half the plan's Task 1 asked for: the same
// inset, measured on the `showModalBottomSheet` branch, which is a
// structurally different route and was never exercised.
//
// The existing file is left UNMODIFIED per the plan's instruction; this is a
// new, additive file rather than an edit to it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

const _bodyKey = Key('drawer-body-mobile');

const _body = SizedBox.expand(
  child: ColoredBox(color: Color(0xFF00FF00), key: _bodyKey),
);

Future<Rect> _openAndMeasure(
  WidgetTester tester, {
  required EdgeInsetsGeometry bodyPadding,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ResponsiveDrawer.show<void>(
              context: context,
              title: 'Swap Settings',
              bodyPadding: bodyPadding,
              child: _body,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  final rect = tester.getRect(find.byKey(_bodyKey));

  // Dismiss via the root navigator rather than a barrier tap: on the mobile
  // branch the sheet is `isScrollControlled: true` with an expanding body, so
  // there is no dependable barrier-only strip to tap blind (unlike the
  // desktop panel, which is a known 420px-wide right-aligned column). The
  // "open" button's element is still mounted underneath the sheet, so its
  // BuildContext is a valid handle to the same root Navigator `show()` used.
  final rootContext = tester.element(find.text('open'));
  Navigator.of(rootContext, rootNavigator: true).pop();
  await tester.pumpAndSettle();
  return rect;
}

void main() {
  testWidgets(
    'the shell insets the body by kDrawerBodyPadding on the mobile sheet too',
    (tester) async {
      // Below GeniusBreakpoints.medium (768) so ResponsiveDrawer.show() takes
      // the showModalBottomSheet branch, not showDialog.
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final zero = await _openAndMeasure(tester, bodyPadding: EdgeInsets.zero);
      final padded = await _openAndMeasure(
        tester,
        bodyPadding: kDrawerBodyPadding,
      );

      // Same delta arithmetic as the desktop test: 20 on the sides and
      // bottom, 24 on top.
      expect(padded.left - zero.left, GeniusWalletConsts.space10);
      expect(zero.right - padded.right, GeniusWalletConsts.space10);
      expect(padded.top - zero.top, GeniusWalletConsts.space12);
      expect(zero.bottom - padded.bottom, GeniusWalletConsts.space10);
    },
  );

  testWidgets(
    'a mobile-sheet caller that passes nothing still gets the inset',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ResponsiveDrawer.show<void>(
                  context: context,
                  title: 'Swap Settings',
                  child: _body,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final defaulted = tester.getRect(find.byKey(_bodyKey));
      final rootContext = tester.element(find.text('open'));
      Navigator.of(rootContext, rootNavigator: true).pop();
      await tester.pumpAndSettle();

      final zero = await _openAndMeasure(tester, bodyPadding: EdgeInsets.zero);
      expect(defaulted.left - zero.left, GeniusWalletConsts.space10);
    },
  );
}
