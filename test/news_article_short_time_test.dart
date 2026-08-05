import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/hive/models/news_article.dart';

/// The one check `shortTimeAgo` owes — it drives both the card timestamp
/// (sketch 031 · T2) and the header "Updated …" stamp (R3), and it is pure and
/// boundary-heavy, so it is exactly the thing to pin. `now` is injected so the
/// test does not read the wall clock.
void main() {
  final now = DateTime(2026, 7, 23, 12, 0, 0);
  String ago(Duration d) => shortTimeAgo(now.subtract(d), now: now);

  test('each unit boundary reads as expected', () {
    expect(ago(const Duration(seconds: 20)), 'now');
    expect(ago(const Duration(minutes: 1)), '1m ago');
    expect(ago(const Duration(minutes: 59)), '59m ago');
    expect(ago(const Duration(hours: 1)), '1h ago');
    expect(ago(const Duration(hours: 23)), '23h ago');
    expect(ago(const Duration(days: 1)), '1d ago');
    expect(ago(const Duration(days: 6)), '6d ago');
    expect(ago(const Duration(days: 7)), '1w ago');
    expect(ago(const Duration(days: 20)), '2w ago');
  });

  test('a future instant (clock skew) clamps to now', () {
    expect(shortTimeAgo(now.add(const Duration(hours: 3)), now: now), 'now');
  });
}
