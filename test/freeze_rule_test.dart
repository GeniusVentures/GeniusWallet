import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the macOS drag-resize freeze at the level it actually occurs.
///
/// TWO commits have now chased this bug. `37639d5` found it: the chart derived
/// its price font size from the available height, so a drag handed skia's
/// fixed-size `ParagraphCache` a distinct `TextStyle` — a distinct cache key —
/// every frame. The cache then missed on every lookup and evicted on every
/// insert, layout never settled, the frame was never committed, and the macOS
/// embedder blocked forever in `ResizeSynchronizer.beginResize`: 100% of one
/// core, isolate past any safepoint, window dead until killed.
///
/// It did not stay fixed. `test/chart/compact_price_font_size_test.dart` tests
/// `compactPriceFontSize`, a PURE FUNCTION — and stayed green while the app
/// froze again the same day, on the same screen, with the same
/// `SkLRUCache<ParagraphCacheKey>::remove` at the top of the stack. The reason
/// is that quantising the height-derived input never mattered on its own:
/// `AutoSizeText` ran its OWN search to fit the available WIDTH, which a drag
/// varies just as continuously. The first test tested the fix. This one tests
/// the bug.
///
/// The banned widgets are banned because their entire purpose is to choose a
/// size from the space available, which on a resizable desktop window means
/// "emit a new paragraph cache key per frame":
///
///   * `AutoSizeText` — searches font sizes to fit its box.
///   * `FittedBox(fit: scaleDown)` — derives a continuous scale from the box.
///
/// The fix in every case is a FIXED style plus `overflow: TextOverflow.ellipsis`.
/// If text truly must shrink, pick from a bounded set of named sizes by width
/// band — few keys, visible steps — never a continuum.
///
/// ponytail: this scans only the surfaces the freeze has actually been measured
/// on — the dashboard and everything it mounts. The rest of the app is equally
/// resizable on desktop and equally capable of this hang; onboarding and the
/// generated `*.g.dart` components still carry ~20 `AutoSizeText` uses. The
/// upgrade path is to widen [_scannedDirs] to `lib/` once those are converted,
/// which is a mechanical change with one real decision per call site (what to
/// do when the text no longer fits).
void main() {
  const bannedPatterns = <String, String>{
    'AutoSizeText(':
        'searches font sizes to fit its box, so a drag-resize emits a new '
        'TextStyle per frame',
    'FittedBox(':
        'derives a continuous scale from the available space (scaleDown is '
        'the same defect as AutoSizeText)',
  };

  // Everything the dashboard mounts, directly or through a shared component.
  const scannedDirs = <String>[
    'lib/dashboard',
    'lib/chart',
    'lib/components/coins',
    'lib/components/cards',
    'lib/components/feedback',
  ];

  test('no continuously-sized text widget is reachable from the dashboard', () {
    final offenders = <String>[];

    for (final dir in scannedDirs) {
      final directory = Directory(dir);
      expect(
        directory.existsSync(),
        isTrue,
        reason:
            'scanned directory $dir has moved — fix this list rather than '
            'letting the guard silently scan nothing',
      );

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // A comment naming the banned widget is how this rule is DOCUMENTED
          // at each site it was removed from; only real uses count.
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
          for (final entry in bannedPatterns.entries) {
            if (line.contains(entry.key)) {
              offenders.add('${entity.path}:${i + 1} — ${entry.key} '
                  '${entry.value}');
            }
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These widgets size themselves from the space available, which on a '
          'resizable desktop window thrashes skia\'s ParagraphCache and hangs '
          'the app permanently on a drag-resize (see 37639d5 and the doc '
          'comment above). Use a fixed style with '
          'overflow: TextOverflow.ellipsis.\n  ${offenders.join('\n  ')}',
    );
  });
}
