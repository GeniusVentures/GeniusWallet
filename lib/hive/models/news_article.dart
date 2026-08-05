import 'package:hive_ce/hive.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'news_article.g.dart';

/// Compact relative age — `now`, `12m ago`, `3h ago`, `2d ago`, `4w ago`.
/// Top-level so both the article timestamp ([NewsArticle.relativeTimeShort])
/// and the header's "Updated …" stamp share ONE definition. [now] is injectable
/// for a deterministic test. A future instant (clock skew) clamps to `now`.
String shortTimeAgo(DateTime from, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(from);
  if (d.isNegative || d.inMinutes < 1) {
    return 'now';
  }
  if (d.inMinutes < 60) {
    return '${d.inMinutes}m ago';
  }
  if (d.inHours < 24) {
    return '${d.inHours}h ago';
  }
  if (d.inDays < 7) {
    return '${d.inDays}d ago';
  }
  return '${(d.inDays / 7).floor()}w ago';
}

@HiveType(typeId: 3)
class NewsArticle extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final String description;

  /// An ISO-8601 timestamp (see `coin_telegraph_api.dart`). Historically this
  /// held the `timeago.format()` RESULT computed at fetch time, which froze —
  /// a cached article said "2 hours ago" forever. It now holds the raw instant;
  /// [relativeTime] formats it at read time so the label advances. Field index
  /// unchanged, so the generated Hive adapter needs no regeneration.
  @HiveField(3)
  final String pubDate;

  @HiveField(4)
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
    this.imageUrl,
  });

  /// Relative age ("2 hours ago"), formatted NOW rather than at fetch time.
  /// Falls back to the raw [pubDate] string when it is not a parseable instant
  /// — which also covers pre-migration cache entries still holding a frozen
  /// timeago string, so old cache degrades gracefully instead of crashing.
  String get relativeTime {
    final dt = DateTime.tryParse(pubDate);
    return dt != null ? timeago.format(dt) : pubDate;
  }

  /// A plain-text dek from [description]. The raw RSS field is HTML that begins
  /// with an `<img src=…>` tag (that is how the API scrapes the image), so the
  /// tags MUST be stripped or the card would print markup at the reader.
  String get dek => description.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  /// Compact age for the card timestamp (sketch 031 · T2): `now`, `12m ago`,
  /// `3h ago`, `2d ago`, `4w ago`. Same read-time formatting as [relativeTime]
  /// (never a frozen string); falls back to the raw [pubDate] if it will not
  /// parse, so pre-migration cache degrades instead of crashing.
  String get relativeTimeShort {
    final dt = DateTime.tryParse(pubDate);
    return dt != null ? shortTimeAgo(dt) : pubDate;
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      pubDate: json['pubDate'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'description': description,
      'pubDate': pubDate,
      'imageUrl': imageUrl,
    };
  }
}
