import 'package:genius_api/genius_api.dart';

class MarketsState {
  MarketsStatus marketLoadingStatus;

  List<Currency> markets;

  MarketsState({
    this.marketLoadingStatus = MarketsStatus.initial,
    this.markets = const [],
  });

  MarketsState copyWith({
    MarketsStatus? marketLoadingStatus,
    List<Currency>? markets,
  }) {
    return MarketsState(
      marketLoadingStatus: marketLoadingStatus ?? this.marketLoadingStatus,
      markets: markets ?? this.markets,
    );
  }
}

enum MarketsStatus { initial, loading, loaded, error }
