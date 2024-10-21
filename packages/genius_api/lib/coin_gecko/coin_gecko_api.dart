import 'dart:convert';
import 'package:http/http.dart' as http;

final String apiKey = "CG-2NV8Hic1GvCEf635XKpbzpEp";

/// Can pass multiple coin ids ethereum,bitcoin
Future<dynamic> fetchCoinPrice({required String coinIds}) async {
  String priceApi =
      'https://api.coingecko.com/api/v3/simple/price?ids=$coinIds&vs_currencies=usd';

  final response = await http.get(Uri.parse(priceApi));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Coin Price' + response.body);
  }
}
