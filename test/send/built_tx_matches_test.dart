// The last check before a send reaches the signer: the built map must say
// exactly what the form said. Each mutation here is one way a builder bug
// could redirect or resize a transfer without anyone noticing.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_wallet/send/send_cubit.dart';

const _from = '0x1111111111111111111111111111111111111111';
const _to = '0x2222222222222222222222222222222222222222';
const _other = '0x3333333333333333333333333333333333333333';
const _token = '0x4444444444444444444444444444444444444444';

final _fee = SendFee(
  maxFeePerGas: BigInt.from(30000000000),
  maxPriorityFeePerGas: BigInt.from(1000000000),
  gasLimit: BigInt.from(65000),
);
final _amount = BigInt.from(500000);

Map<String, dynamic> _native() =>
    buildSendTx(from: _from, recipient: _to, amount: _amount, fee: _fee);

Map<String, dynamic> _erc20({String recipient = _to, BigInt? amount}) =>
    buildSendTx(
      from: _from,
      recipient: recipient,
      amount: amount ?? _amount,
      fee: _fee,
      tokenContract: _token,
    );

void main() {
  group('native send', () {
    test('the built map matches the form', () {
      expect(
        builtTxMatches(_native(), recipient: _to, amount: _amount),
        isTrue,
      );
    });

    test('a different recipient is refused', () {
      final tx = _native()..['to'] = _other;
      expect(builtTxMatches(tx, recipient: _to, amount: _amount), isFalse);
    });

    test('a different value is refused', () {
      final tx = _native()..['value'] = '0x1';
      expect(builtTxMatches(tx, recipient: _to, amount: _amount), isFalse);
    });

    test('calldata on a native send is refused', () {
      final tx = _native()..['data'] = '0xdeadbeef';
      expect(builtTxMatches(tx, recipient: _to, amount: _amount), isFalse);
    });
  });

  group('ERC-20 send', () {
    test('the decoded transfer matches the form', () {
      expect(
        builtTxMatches(
          _erc20(),
          recipient: _to,
          amount: _amount,
          tokenContract: _token,
        ),
        isTrue,
      );
    });

    test('calldata paying someone else is refused', () {
      expect(
        builtTxMatches(
          _erc20(recipient: _other),
          recipient: _to,
          amount: _amount,
          tokenContract: _token,
        ),
        isFalse,
      );
    });

    test('calldata moving a different amount is refused', () {
      expect(
        builtTxMatches(
          _erc20(amount: _amount + BigInt.one),
          recipient: _to,
          amount: _amount,
          tokenContract: _token,
        ),
        isFalse,
      );
    });

    test('a call to another contract is refused', () {
      final tx = _erc20()..['to'] = _other;
      expect(
        builtTxMatches(
          tx,
          recipient: _to,
          amount: _amount,
          tokenContract: _token,
        ),
        isFalse,
      );
    });

    test('native value attached to a token call is refused', () {
      final tx = _erc20()..['value'] = '0x1';
      expect(
        builtTxMatches(
          tx,
          recipient: _to,
          amount: _amount,
          tokenContract: _token,
        ),
        isFalse,
      );
    });
  });
}
