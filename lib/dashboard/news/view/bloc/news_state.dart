import 'package:genius_api/models/news.dart';

class NewsState {
  NewsStatus newsLoadingStatus;

  List<News> news;

  NewsState({
    this.newsLoadingStatus = NewsStatus.initial,
    this.news = const [],
  });

  NewsState copyWith({
    NewsStatus? newsLoadingStatus,
    List<News>? news,
  }) {
    return NewsState(
      newsLoadingStatus: newsLoadingStatus ?? this.newsLoadingStatus,
      news: news ?? this.news,
    );
  }
}

enum NewsStatus { initial, loading, loaded, error }
