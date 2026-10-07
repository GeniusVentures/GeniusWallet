import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('/buy lives inside the app shell (router.dart)', () {
    // A static source check, not a widget/navigation test: the real
    // `geniusWalletRouter` needs `AppBloc`/`WalletDetailsCubit`/`GeniusApi`
    // and the rest of `main.dart`'s provider tree to construct, which is out
    // of proportion for pinning one route's PLACEMENT. `ShellRoute`'s own
    // paren-depth span is walked instead of hardcoding a "next sibling route"
    // line number, so this survives the shell gaining or losing routes
    // around `/buy` without going stale.
    test("the '/buy' GoRoute sits inside the ShellRoute, not beside it", () {
      final source = File('lib/navigation/router.dart').readAsStringSync();

      final shellStart = source.indexOf('ShellRoute(');
      expect(
        shellStart,
        greaterThanOrEqualTo(0),
        reason: 'router.dart no longer declares a ShellRoute at all',
      );

      // Walk paren depth from the `(` right after `ShellRoute` to find where
      // that single call closes, so this test does not depend on which
      // routes flank it.
      var depth = 0;
      var shellEnd = -1;
      for (var i = shellStart + 'ShellRoute'.length; i < source.length; i++) {
        final ch = source[i];
        if (ch == '(') {
          depth++;
        } else if (ch == ')') {
          depth--;
          if (depth == 0) {
            shellEnd = i;
            break;
          }
        }
      }
      expect(
        shellEnd,
        greaterThan(shellStart),
        reason: "ShellRoute(...)'s closing paren was not found",
      );

      // The exact-quote form so `'/buy'` never matches a longer path.
      const buyRouteLiteral = "path: '/buy'";
      final buyIndex = source.indexOf(buyRouteLiteral);
      expect(
        buyIndex,
        greaterThanOrEqualTo(0),
        reason: "router.dart no longer declares a '/buy' route",
      );
      expect(
        buyIndex,
        greaterThan(shellStart),
        reason: "'/buy' must be declared INSIDE the ShellRoute, not before it",
      );
      expect(
        buyIndex,
        lessThan(shellEnd),
        reason:
            "'/buy' must be declared INSIDE the ShellRoute's routes list, "
            'not after it closes',
      );
    });
  });
}
