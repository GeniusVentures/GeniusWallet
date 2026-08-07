// Phase 21 closeout (21-06): the standing gate over the invariant this whole
// phase promised -- every ResponsiveDrawer.show call site in lib/ either
// takes the shared body inset (the default, "shellInset" below) or
// explicitly opts out because it owns a scrolling viewport
// ("ownsScrollingViewport", bodyPadding: EdgeInsets.zero) -- and EVERY call
// site is accounted for, not just the ones a plan happened to touch.
//
// What this file deliberately does NOT do:
//   - It does not re-assert the desktop/mobile inset GEOMETRY itself --
//     that is `responsive_drawer_body_padding_test.dart` (desktop) and
//     `drawer_body_padding_test.dart` (mobile)'s job.
//   - It asserts nothing visual. No widget is pumped anywhere in this file.
// It asserts COMPLETENESS: that 07-06's "every caller remembers" rule --
// which measurably failed once (`transaction_displays.dart` shipped padded
// vertically only, labels touching the panel's left edge) -- is now
// impossible to repeat silently, because a new, unclassified call site
// fails Test 1 below instead of shipping unpadded.
//
// Modelled STRUCTURALLY on `test/banxa/banxa_reskin_literals_test.dart`:
// dart:io reads, const/final collections, no widget pumping, no fixture
// directory, no golden. The comment-stripping helper is reused verbatim
// rather than a third one invented for this file.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

enum _Inset { shellInset, ownsScrollingViewport }

/// The census. Written BY HAND from a measured scan of `lib/` at the end of
/// Phase 21's wave 2 (21-06) -- NOT a glob. A glob over `lib/` would
/// silently absorb the next drawer someone adds, which is the exact
/// failure this file exists to catch: Test 1 below fails loudly instead of
/// the gate silently widening its own coverage.
///
/// One entry per FILE. A file may hold more than one call site --
/// `wallet_information.dart` holds two (Receive, More Options) -- and both
/// share this file's one classification; Test 3/4 below check every call
/// site the file contains, not just the first.
const _census = <String, _Inset>{
  // -- ownsScrollingViewport: the inset lives on the ListView itself so it
  // scrolls with the content and the rows still reach the panel edge. This
  // is the half of 07-06's prohibition that was right.
  'lib/account/account_drawer.dart': _Inset.ownsScrollingViewport,
  'lib/account/sdk_account_manager.dart': _Inset.ownsScrollingViewport,
  'lib/network/network_dropdown_selector.dart': _Inset.ownsScrollingViewport,
  'lib/squid_router/token_selector_drawer.dart': _Inset.ownsScrollingViewport,
  // 21-02: the bridge's destination-network picker, the fifth GWSelectRow
  // call site.
  'lib/dashboard/bridge/bridge_screen.dart': _Inset.ownsScrollingViewport,
  // 21-06 Task 1: the legacy BottomDrawer shell is deleted; the gallery's
  // demo is now a plain scrolling ListView, same shape as the five pickers
  // above.
  'lib/dev/design_gallery_screen.dart': _Inset.ownsScrollingViewport,

  // -- shellInset (the default): no bodyPadding argument at all -- the
  // shell's own kDrawerBodyPadding is the whole inset.
  'lib/dashboard/home/widgets/transaction_displays.dart': _Inset.shellInset,
  'lib/reown/swap_result_drawer.dart': _Inset.shellInset,
  'lib/reown/approve_transaction_drawer.dart': _Inset.shellInset,
  'lib/reown/approve_dapp_connection_drawer.dart': _Inset.shellInset,
  'lib/banxa/banxa_components/buy_success_drawer.dart': _Inset.shellInset,
  'lib/banxa/banxa_components/buy_cancelled_drawer.dart': _Inset.shellInset,
  'lib/components/coins/view/coins_screen.dart': _Inset.shellInset,
  // The /assets page's Receive drawer (phase 25-02). Same call shape as the
  // coins_screen.dart entry directly above: no bodyPadding, so shellInset.
  'lib/dashboard/assets/assets_screen.dart': _Inset.shellInset,
  'lib/tokens/token_info_screen.dart': _Inset.shellInset,
  // Two call sites in this one file: Receive (21-05) and More Options.
  'lib/components/wallet_information.dart': _Inset.shellInset,
  // D-09: fits none of the four decided patterns, gets the shared inset and
  // nothing else -- measured, not assumed (21-05/21-06).
  'lib/squid_router/swap_settings_drawer.dart': _Inset.shellInset,
  'lib/submit_job/view/job_drawer.dart': _Inset.shellInset,
};

/// A call to `ResponsiveDrawer.show`, with or without a generic type
/// argument (`show<void>(`, `show<bool>(`, `show(`).
final _showCallPattern = RegExp(r'ResponsiveDrawer\.show(<[^>]*>)?\(');

/// The opt-out this shell actually ships: default-padded, `EdgeInsets.zero`
/// to opt out. See `responsive_drawer.dart`'s own `kDrawerBodyPadding` doc.
final _zeroBodyPaddingPattern = RegExp(r'bodyPadding\s*:\s*EdgeInsets\.zero');

/// Any `bodyPadding:` argument at all, regardless of value -- a shellInset
/// call site may not pass this argument, full stop; the shell's default
/// is the entire point.
final _bodyPaddingArgPattern = RegExp(r'\bbodyPadding\s*:');

/// A call site's `child:` argument opening directly on a `Padding(` or
/// `Container(` -- the exact double-padding shape 07-06's honour-system
/// rule failed to prevent once already (the transaction receipt's own
/// vertical-only pad, pre-21-01).
final _duplicatingWrapperPattern = RegExp(r'child:\s*(Padding|Container)\(');

/// Reads [path] and strips full-line comments -- the same approach
/// `banxa_reskin_literals_test.dart`'s `_codeLines` uses, reused
/// deliberately rather than a second stripping pass invented for this
/// file. Returns the remaining source as ONE string (not a list of lines)
/// so a multi-line `show(...)` call can still be matched as a whole and its
/// parens balanced across line breaks.
String _strippedSource(String path) {
  final lines = File(path).readAsStringSync().split('\n');
  return lines.where((line) => !line.trim().startsWith('//')).join('\n');
}

/// Every `ResponsiveDrawer.show(...)` call region in [content], each as its
/// own substring from `ResponsiveDrawer.show` to the matching closing
/// paren -- so a per-call-site check (Test 3/4) never accidentally looks
/// inside a DIFFERENT call site in the same file (e.g.
/// `wallet_information.dart`'s two).
List<String> _showCallRegions(String content) {
  final regions = <String>[];
  for (final match in _showCallPattern.allMatches(content)) {
    final openParenIndex = match.end - 1;
    var depth = 1;
    var i = openParenIndex + 1;
    while (i < content.length && depth > 0) {
      if (content[i] == '(') {
        depth++;
      } else if (content[i] == ')') {
        depth--;
      }
      i++;
    }
    regions.add(content.substring(match.start, i));
  }
  return regions;
}

/// Walks `lib/` for every `.dart` file and returns the relative,
/// forward-slash path of each one that contains at least one real (not
/// commented-out) `ResponsiveDrawer.show(...)` call -- the DISCOVERED set
/// Test 1/2 diff the hand-written census against. This is the one place
/// this file walks the tree; the census itself stays hand-written.
Set<String> _discoverCallSitePaths() {
  final discovered = <String>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    final relativePath = entity.path.replaceAll('\\', '/');
    final content = _strippedSource(relativePath);
    if (_showCallPattern.hasMatch(content)) {
      discovered.add(relativePath);
    }
  }
  return discovered;
}

void main() {
  group('Drawer body-padding invariant census (21-06)', () {
    test('every ResponsiveDrawer.show call site in lib/ is in the census -- a '
        'new, unclassified drawer fails this instead of shipping unpadded', () {
      final discovered = _discoverCallSitePaths();
      final censused = _census.keys.toSet();

      final unclassified = discovered.difference(censused);
      expect(
        unclassified,
        isEmpty,
        reason:
            'Found ResponsiveDrawer.show call site(s) not in the census: '
            '$unclassified. Classify each as shellInset (default, no '
            'bodyPadding argument) or ownsScrollingViewport (bodyPadding: '
            'EdgeInsets.zero) and add it to _census in this file.',
      );
    });

    test('the census is not stale in the other direction -- every path it '
        'names still contains at least one real call site', () {
      final discovered = _discoverCallSitePaths();
      final censused = _census.keys.toSet();

      final stale = censused.difference(discovered);
      expect(
        stale,
        isEmpty,
        reason:
            'Census names path(s) with no ResponsiveDrawer.show call site '
            'left in the tree (file deleted, or its last drawer call '
            'removed): $stale. Remove the stale entry from _census.',
      );
    });

    for (final entry in _census.entries) {
      final path = entry.key;
      final classification = entry.value;

      test('$path -- every call site matches its census classification '
          '(${classification.name})', () {
        expect(
          File(path).existsSync(),
          isTrue,
          reason: 'censused file $path does not exist',
        );

        final content = _strippedSource(path);
        final regions = _showCallRegions(content);
        expect(
          regions,
          isNotEmpty,
          reason: '$path: no ResponsiveDrawer.show(...) call site found',
        );

        for (final region in regions) {
          if (classification == _Inset.shellInset) {
            expect(
              _bodyPaddingArgPattern.hasMatch(region),
              isFalse,
              reason:
                  '$path: a call site classified shellInset must not '
                  'pass a bodyPadding argument at all -- the shell\'s '
                  'default IS the inset',
            );
          } else {
            expect(
              _zeroBodyPaddingPattern.hasMatch(region),
              isTrue,
              reason:
                  '$path: a call site classified ownsScrollingViewport '
                  'must pass bodyPadding: EdgeInsets.zero explicitly',
            );
          }
        }
      });

      if (classification == _Inset.shellInset) {
        test('$path -- a shellInset call site does not wrap its child in a '
            'duplicating Padding/Container', () {
          final content = _strippedSource(path);
          final regions = _showCallRegions(content);
          for (final region in regions) {
            expect(
              _duplicatingWrapperPattern.hasMatch(region),
              isFalse,
              reason:
                  '$path: a shellInset call site\'s child wraps itself '
                  'in a Padding/Container as its outermost widget -- this '
                  'duplicates the shell\'s own kDrawerBodyPadding. Delete '
                  'the wrapper; the shell already insets the body.',
            );
          }
        });
      }
    }
  });
}
