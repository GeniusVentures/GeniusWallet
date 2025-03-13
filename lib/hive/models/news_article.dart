import 'package:hive/hive.dart';

part 'news_article.g.dart';

@HiveType(typeId: 3)
class NewsArticle extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final String description;

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
