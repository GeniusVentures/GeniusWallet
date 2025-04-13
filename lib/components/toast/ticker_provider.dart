import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class ToastTickerProvider extends ChangeNotifier implements TickerProvider {
  final List<Ticker> _tickers = [];

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick, debugLabel: 'created by $this');
    _tickers.add(ticker);
    return ticker;
  }

  @override
  void dispose() {
    for (final ticker in _tickers) {
      ticker.dispose();
    }
    _tickers.clear();
    super.dispose();
  }
}
