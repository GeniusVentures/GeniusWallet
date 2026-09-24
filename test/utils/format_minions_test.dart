import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

void main() {
  test('minion balances read without a stray ".0" and cap at 3 decimals', () {
    expect(WalletUtils.formatMinions(0), '0 minions');
    expect(WalletUtils.formatMinions(1), '1 minion');
    expect(WalletUtils.formatMinions(2.5), '2.5 minions');
    expect(WalletUtils.formatMinions(1.23456), '1.235 minions');
    expect(WalletUtils.formatMinions(1200), '1,200 minions');
    expect(WalletUtils.formatMinions(0.0004), '<0.001 minions');
  });
}
