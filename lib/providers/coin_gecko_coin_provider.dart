import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:genius_wallet/models/coin_gecko_coin.dart';

class CoinGeckoCoinProvider extends ChangeNotifier {
  List<CoinGeckoCoin> _coins = [];

  List<CoinGeckoCoin> get coins => _coins;

  /// Load coins from JSON (only once)
  Future<void> loadCoins() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/coins_list/coins_list.json');
      final List<dynamic> jsonData = jsonDecode(response);
      _coins = jsonData.map((coin) => CoinGeckoCoin.fromJson(coin)).toList();
      notifyListeners(); // Notify UI of data changes
    } catch (e) {
      print("Error loading coins: $e");
    }
  }
}
