import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/news/view/bloc/news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  GeniusApi api;
  NewsCubit({
    required this.api,
  }) : super(NewsState());

  Future<void> loadNews() async {
    emit(state.copyWith(newsLoadingStatus: NewsStatus.loading));

    try {
      final news = await api.getNews();

      emit(state.copyWith(
        news: news,
        newsLoadingStatus: NewsStatus.loaded,
      ));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(newsLoadingStatus: NewsStatus.error));
      }
    }
  }
}
