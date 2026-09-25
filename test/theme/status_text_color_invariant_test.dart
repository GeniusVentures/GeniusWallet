// The census the status-text contrast sweep locks behind.
// Every remaining raw gw.statusSuccess/gw.statusError read in lib/ (outside
// lib/theme/, which defines the tokens) must be a wash, fill, border, dot,
// line or standalone icon -- never a foreground Text/Icon that carries the
// status as its only signal. A new raw read, a vanished one, or a count that
// drifts from what was actually audited all fail this instead of shipping
// silently.
//
// A hand-written census and a `dart:io` walk of `lib/`, no widget pumping.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every file still reading a raw status token, written by hand from a
/// measured scan. `count` is its exact number of raw reads; `reason` says
/// why each may stay raw (a wash/fill/border/dot/line only needs 3:1).
const _census = <String, ({int count, String reason})>{
  'lib/chart/crypto_simple_chart.dart': (count: 2, reason: 'sparkline + wash'),
  'lib/chart/crypto_live_chart.dart': (count: 2, reason: 'lines + wash'),
  'lib/components/coins/view/coin_card_row.dart': (count: 2, reason: 'wash'),
  'lib/dashboard/chart/markets_table.dart': (
    count: 2,
    reason: 'wash + sparkline',
  ),
  'lib/dashboard/chart/markets_cards.dart': (count: 2, reason: 'wash'),
  'lib/dashboard/chart/markets_hero_card.dart': (
    count: 4,
    reason: 'wash + chart line',
  ),
  'lib/tokens/token_info_screen.dart': (count: 2, reason: 'wash'),
  'lib/dev/design_gallery_screen.dart': (count: 2, reason: 'swatch'),
  'lib/web/web_view_windows.dart': (count: 1, reason: 'lock icon'),
  'lib/web/web_view_mobile.dart': (count: 1, reason: 'lock icon'),
  'lib/components/custom_future_builder.dart': (count: 1, reason: 'icon'),
  'lib/components/feedback/gw_error_state.dart': (
    count: 4,
    reason: 'wash + border + standalone icon',
  ),
  'lib/components/toast/toast_widget.dart': (count: 2, reason: 'accent icon'),
  'lib/components/incorrect_pin.dart': (count: 1, reason: 'fill'),
  'lib/components/inputs/gw_text_field.dart': (count: 3, reason: 'border'),
  'lib/components/inputs/gw_select.dart': (count: 2, reason: 'border'),
  'lib/banxa/banxa_components/order_status_style.dart': (
    count: 2,
    reason: 'wash',
  ),
  'lib/dashboard/home/widgets/transaction_displays.dart': (
    count: 2,
    reason: 'wash',
  ),
  'lib/dashboard/home/widgets/transaction_badge.dart': (
    count: 3,
    reason: 'fill',
  ),
  'lib/squid_router/swap_settings_drawer.dart': (
    count: 1,
    reason: 'field edge',
  ),
  'lib/squid_router/swap_screen.dart': (count: 2, reason: 'wash'),
  'lib/dashboard/bridge/bridge_screen.dart': (count: 1, reason: 'wash'),
  'lib/dashboard/compute/compute_panel.dart': (count: 2, reason: 'dot'),
  'lib/submit_job/view/widgets/job_step_list.dart': (count: 1, reason: 'dot'),
  'lib/submit_job/view/widgets/job_steps.dart': (count: 3, reason: 'dot'),
};

/// A raw read of the fill-tuned token -- `.statusSuccessText`/
/// `.statusErrorText` do NOT match (no word boundary between `Success`/
/// `Error` and the following `Text`).
final _rawStatusPattern = RegExp(r'\.status(Success|Error)\b');

/// Reads [path] with full-line comments stripped.
String _strippedSource(String path) {
  final lines = File(path).readAsStringSync().split('\n');
  return lines.where((line) => !line.trim().startsWith('//')).join('\n');
}

/// Walks `lib/` (minus `lib/theme/`, which defines the tokens) and maps
/// every file with a raw status-token read to its exact count.
Map<String, int> _discoverRawStatusReads() {
  final discovered = <String, int>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    final relativePath = entity.path.replaceAll('\\', '/');
    if (relativePath.startsWith('lib/theme/')) {
      continue;
    }
    final content = _strippedSource(relativePath);
    final count = _rawStatusPattern.allMatches(content).length;
    if (count > 0) {
      discovered[relativePath] = count;
    }
  }
  return discovered;
}

void main() {
  group('Raw status-token census', () {
    test('every raw gw.statusSuccess/gw.statusError read in lib/ (except '
        'lib/theme/) is in the census -- a new one fails this instead of '
        'shipping an un-reasoned raw text read', () {
      final discovered = _discoverRawStatusReads();
      final unclassified = discovered.keys.toSet().difference(
        _census.keys.toSet(),
      );
      expect(
        unclassified,
        isEmpty,
        reason:
            'Found raw gw.statusSuccess/gw.statusError read(s) not in the '
            'census: $unclassified. A foreground reads '
            'statusSuccessText/statusErrorText; only a wash, fill, '
            'border, dot, line or standalone icon may read the raw '
            'token, and it goes in the census with its reason.',
      );
    });

    test('the census is not stale -- every path it names still has at least '
        'one raw read', () {
      final discovered = _discoverRawStatusReads();
      final stale = _census.keys.toSet().difference(discovered.keys.toSet());
      expect(
        stale,
        isEmpty,
        reason:
            'Census names path(s) with no raw status read left in the '
            'tree: $stale. Remove the stale entry from _census.',
      );
    });

    test('every censused count matches the real scan -- a raw read added or '
        'removed at a censused file fails this', () {
      final discovered = _discoverRawStatusReads();
      final mismatches = <String>[];
      for (final entry in _census.entries) {
        final actual = discovered[entry.key] ?? 0;
        if (actual != entry.value.count) {
          mismatches.add(
            '${entry.key}: census says ${entry.value.count} '
            '(${entry.value.reason}), scan found $actual',
          );
        }
      }
      expect(
        mismatches,
        isEmpty,
        reason:
            'Raw status-token count drifted from the census: '
            '${mismatches.join('; ')}. A foreground reads '
            'statusSuccessText/statusErrorText; only a wash, fill, '
            'border, dot, line or standalone icon may read the raw '
            'token.',
      );
    });

    test('the census sums to the audited total', () {
      final total = _census.values.fold<int>(0, (sum, v) => sum + v.count);
      expect(_census.length, 25);
      expect(total, 50);
    });
  });
}
