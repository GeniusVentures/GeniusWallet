import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 9 closeout (09-07): the standing gate over the ten Banxa surfaces
/// this phase re-skinned. See `.planning/phases/09-banxa/09-CONTEXT.md`
/// D-04 + D-07 and `09-UI-SPEC.md`'s addendum (order_details_page.dart) for
/// how this exact ten-file list was derived — a glob over `lib/banxa/` would
/// silently pick up the four Phase-21 drawers D-05 fences out of this phase.
///
/// This is a Dart test, not a shell script (Phase 6's
/// `tool/check_onboarding_seed_safety.sh` pattern), so it runs inside
/// `flutter test` — part of the same sampling loop `09-VALIDATION.md`
/// defines — and behaves identically on this project's Windows host.
///
/// What this gate pins (09-VALIDATION's first two automatable bullets):
///   1. No pre-redesign colour literal reappears in any of the ten files,
///      outside the two named, count-pinned exceptions.
///   2. Every one of the ten files still takes a live, appearance-aware
///      `GWColors` read (the const-widget-does-not-re-skin defect class).
/// Plus two companion checks named in the plan: no raw Material button
/// widget survives (except one named, reasoned exemption), and the file
/// list itself never drifts onto a fenced Phase-21/cubit/service path.
// `quote_card.dart` was removed from this list (and from `lib/`) by 09-08
// Task 4: it was dead code with zero callers (its own header comment said
// so), and the quote grid `banxa_buy_screen.dart` now renders is what it
// existed to become. Nine files, not ten, from here on.
const _inScopeFiles = <String>[
  'lib/screens/banxa_buy_screen.dart',
  'lib/banxa/banxa_orders_history.dart',
  'lib/banxa/banxa_payment.dart',
  'lib/banxa/checkout_qr.dart',
  'lib/banxa/user_kyc/kyc_registration.dart',
  'lib/banxa/banxa_components/order_card.dart',
  'lib/banxa/banxa_components/order_details_card.dart',
  'lib/banxa/handle_banxa_drawer.dart',
  'lib/screens/order_details_page.dart',
];

/// The two literals this phase deliberately preserved. Each count is
/// asserted EQUAL to this value — not "at least" — so the gate fails just as
/// hard if the allowlisted occurrence is deleted as it does if a new one is
/// introduced. Deleting the QR's white backing (or the boot scrim) must
/// never be a way to make this gate greener.
const _allowedColorLiteralCount = <String, int>{
  // checkout_qr.dart's QR quiet-zone backing — mode-invariant by design,
  // matching the shipped drawers-final convention (09-05-SUMMARY.md).
  'lib/banxa/checkout_qr.dart': 1,
  // banxa_buy_screen.dart's boot overlay scrim — a temporary full-screen
  // block, mode-invariant by construction (09-03-SUMMARY.md).
  'lib/screens/banxa_buy_screen.dart': 1,
};

/// banxa_orders_history.dart's date-range `OutlinedButton` is explicitly NOT
/// a re-skin target: 09-UI-SPEC.md's component inventory says the
/// `DropdownMenu<String>`/date-range `OutlinedButton` pair "inherit theme
/// styling already" (already wired to the app-wide ButtonTheme) and needs no
/// structural change — it is a filter control, not a CTA. Every other raw
/// Material button across these ten files was swapped to `GWButton` by
/// 09-02 through 09-06. This is a recorded decision, not a way to silence
/// the check: it is named by file and count, same as the colour allowlist.
const _rawButtonExemptionCount = <String, int>{
  'lib/banxa/banxa_orders_history.dart': 1,
};

/// Paths that must never appear in the in-scope list — the four Phase-21
/// drawers (D-05), and the cubit/service layer (D-06) a re-skin has no
/// business touching.
const _fencedPathSubstrings = <String>[
  'buy_success_drawer',
  'buy_cancelled_drawer',
  'banxa_order/',
  'banxa_helpers',
  'banxa_api_services',
  'banxa_model',
];

/// Matches a reference to Flutter's `Colors` class — e.g. `Colors.white`,
/// `Colors.black45` — but NOT `GWColors.dark()`/`GeniusWalletColors.foo`,
/// because `\b` requires a transition between a word and a non-word
/// character, and there is no such transition where "Colors" is immediately
/// preceded by another word character ("W" in "GWColors", "t" in
/// "GeniusWalletColors") — both are letters, so no boundary exists there.
///
/// `Colors.transparent` is excluded (09-08), matching `tool/check_raw_colors.sh`'s
/// own documented, unconditional exemption: it carries no hue and is
/// appearance-neutral by definition (0 alpha reads identically in every
/// mode). Without this exclusion this gate would be STRICTER than the
/// project's authoritative colour rule for no reason — `Material(color:
/// Colors.transparent)` is the standard idiom this app's own `GWCard`/
/// `GWButton` already use to let an `InkWell`'s ripple show through.
final _forbiddenColorPattern = RegExp(r'\bColors\.(?!transparent\b)');

/// The two named pre-redesign semantic-token literals this phase replaced
/// with the 4-bucket ladder / typography tokens.
final _forbiddenTokenPatterns = <RegExp>[
  RegExp(r'GeniusWalletColors\.deepBlue\b'),
  RegExp(r'GeniusWalletColors\.lightGreenSecondary\b'),
];

/// The app-wide fail-soft live-read idiom every re-skinned widget in this
/// phase uses.
final _liveReadPattern = RegExp(
  r'Theme\.of\(context\)\.extension<GWColors>\(\)',
);

/// A raw (unwrapped) Material button constructor call.
final _rawButtonPattern = RegExp(
  r'\b(ElevatedButton|OutlinedButton|TextButton|FilledButton)\(',
);

/// Reads [path], splits to lines, and drops any line whose trimmed form
/// starts with a comment marker — so a file's own explanatory header (or an
/// inline reasoning comment) cannot trip the gate it documents. This is not
/// optional: an unfiltered scan lets a file's own doc comment about
/// "Colors.foo" self-invalidate the check.
List<String> _codeLines(String relativePath) {
  final lines = File(relativePath).readAsStringSync().split('\n');
  return lines.where((line) => !line.trim().startsWith('//')).toList();
}

void main() {
  group('Banxa re-skin literal gate (09-07)', () {
    test(
      'names all ten in-scope files and none of the fenced Phase-21/cubit/service paths',
      () {
        expect(_inScopeFiles.length, equals(9));
        for (final path in _inScopeFiles) {
          expect(
            File(path).existsSync(),
            isTrue,
            reason: 'in-scope file $path does not exist on disk',
          );
          for (final needle in _fencedPathSubstrings) {
            expect(
              path.contains(needle),
              isFalse,
              reason: '$path matches the fenced pattern "$needle"',
            );
          }
        }
      },
    );

    for (final path in _inScopeFiles) {
      test('$path carries no forbidden colour literal outside the allowlist', () {
        final lines = _codeLines(path);
        final allowedCount = _allowedColorLiteralCount[path] ?? 0;

        final colorMatches = lines
            .where((line) => _forbiddenColorPattern.hasMatch(line))
            .length;
        expect(
          colorMatches,
          equals(allowedCount),
          reason:
              '$path: expected exactly $allowedCount raw Colors.* occurrence(s) '
              '(the allowlist), found $colorMatches',
        );

        for (final tokenPattern in _forbiddenTokenPatterns) {
          final tokenMatches = lines
              .where((line) => tokenPattern.hasMatch(line))
              .length;
          expect(
            tokenMatches,
            equals(0),
            reason:
                '$path: found a forbidden pre-redesign token literal matching '
                '${tokenPattern.pattern}',
          );
        }
      });

      test('$path takes a live appearance-aware GWColors read', () {
        final lines = _codeLines(path);
        final hasLiveRead = lines.any(
          (line) => _liveReadPattern.hasMatch(line),
        );
        expect(
          hasLiveRead,
          isTrue,
          reason:
              '$path has no live Theme.of(context).extension<GWColors>() read',
        );
      });

      test('$path contains no un-exempted raw Material button widget', () {
        final lines = _codeLines(path);
        final rawButtonMatches = lines
            .where((line) => _rawButtonPattern.hasMatch(line))
            .length;
        final exempted = _rawButtonExemptionCount[path] ?? 0;
        expect(
          rawButtonMatches,
          equals(exempted),
          reason:
              '$path: expected $exempted named-exempt raw Material button(s), '
              'found $rawButtonMatches',
        );
      });
    }
  });
}
