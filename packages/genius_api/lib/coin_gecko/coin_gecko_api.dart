import 'dart:convert';
import 'package:genius_api/src/genius_api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final String apiKey = "CG-2NV8Hic1GvCEf635XKpbzpEp";

/// Use this class to pass a list of balances for the coin ids that are fetched in fetchCoinPrice,
/// This allows the fetch to convert the balances given a list of coin ids and their prices to return an overall balance
class CoinBalance {
  String coinId;
  double balance;

  CoinBalance({required this.coinId, required this.balance});
}

/// Can pass multiple coin ids ex: ethereum,bitcoin
Future<String?> fetchCoinPricesSum(
    {required String coinIds,
    required List<CoinBalance> coinBalances,
    required GeniusApi geniusApi}) async {
  String priceApi =
      'https://api.coingecko.com/api/v3/simple/price?ids=$coinIds&vs_currencies=usd';

  try {
    final response = await http.get(Uri.parse(priceApi));

    if (response.statusCode == 200) {
      final coinPrices = jsonDecode(response.body);

      double sum = coinBalances.fold(0, (sum, element) {
        final coinResponse = coinPrices[element.coinId];
        final coinResponseValue = coinResponse?['usd'] ?? 0;
        return sum += coinResponseValue * element.balance;
      });

      geniusApi.saveAccountBalance(sum);

      return "\$ ${NumberFormat('#,##0.00').format(sum)}";
    } else {
      // update fetch date to rate limit if the call fails
      geniusApi.updateAccountFetchDate();
      print('Failed to load Coin Price' + response.body);
      return null;
    }
    // maybe timed out or no internet
  } catch (e) {
    return "";
  }
}
