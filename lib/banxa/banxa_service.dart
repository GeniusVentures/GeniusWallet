import 'dart:convert';
import 'package:genius_wallet/banxa/handle_banxa_redirect.dart';
import 'package:http/http.dart' as http;

class BanxaService {
  /// TODO: wire up the backend call to sign the url
  static Future<String?> getBanxaCheckoutUrl({
    required String walletAddress,
    required String userEmail,
  }) async {
    // TODO: WIRE UP ACTUAL CALL
    // test buy success url callback
    final String banxaUrl =
        "https://www.google.com?orderId=${DateTime.now().millisecondsSinceEpoch}&coinAmount=100&coin=GNUS&fiatAmount=500.00&orderStatus=complete";

    // test buy failed url callback
    // final String banxaUrl =
    //     "https://www.google.com?orderId=${DateTime.now().millisecondsSinceEpoch}&coinAmount=100&coin=GNUS&fiatAmount=500.00&orderStatus=cancelled";

    // FOR TESTING RETURN SUCCESS FLOW URL
    return banxaUrl;
    // final backendEndpoint = Uri.parse(
    //   'https://your-backend.com/api/create-banxa-checkout',
    // );

    // final payload = {
    //   "order_type": "buy",
    //   "fiat_currency": "USD",
    //   "fiat_amount": "10",
    //   "coin":
    //       "GNUS", // May not work if not approved by Banxa ( needs whitelisting )
    //   "wallet_address": walletAddress,
    //   "wallet_type": "external",
    //   "user": {"email": userEmail, "first_name": "GNUS", "last_name": "User"},
    //   "return_url_on_success": "https://yourapp.com/success",
    //   "return_url_on_cancel": "https://yourapp.com/cancel"
    // };

    // try {
    //   final res = await http.post(
    //     backendEndpoint,
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(payload),
    //   );

    //   if (res.statusCode == 200) {
    //     final body = jsonDecode(res.body);
    //     return body['checkout_url'];
    //   } else {
    //     print('Banxa backend error: ${res.body}');
    //   }
    // } catch (e) {
    //   print('Banxa URL fetch failed: $e');
    // }

    // return null;
  }
}
