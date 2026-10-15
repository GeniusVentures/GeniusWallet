import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';

void main() {
  test('the disclaimer names the host of the configured environment', () {
    expect(banxaDisclaimerMessage(sandbox: false), contains('(banxa.com)'));
    expect(
      banxaDisclaimerMessage(sandbox: true),
      contains('(banxa-sandbox.com)'),
    );
  });
}
