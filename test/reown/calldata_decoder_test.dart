// What the wallet claims a dApp transaction will do.
//
// `handle_dapp_requests.dart` used to show every `eth_sendTransaction` as an
// ETH amount going to whatever `tx['to']` said -- for an ERC-20 transfer that
// is the token contract, not the recipient, and the amount is not ETH. These
// functions are what replaces that guess with a reading of the calldata, so
// what they return is what a user believes they are signing.
//
// This file goes red if:
//   - a real `transfer(address,uint256)` stops resolving to its true recipient
//     and amount,
//   - the hardcoded selector drifts from the one the ABI actually derives,
//   - an unknown token, an unreadable `decimals`, or a transfer that ALSO
//     moves native value starts being presented as a confident token send,
//   - malformed calldata throws instead of falling back to today's path,
//   - or decoding starts writing into the map that gets signed.
//
// That last one is the only one here that is not merely a display bug: the
// same `Map` instance is handed to the signer by reference, so a byte written
// during decode is a byte the user did not agree to.

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart';
import 'package:web3dart/web3dart.dart';

// From EIP-55's own published test vectors, so the expected checksummed form
// below is an external constant rather than something this suite derived.
const _recipient = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
const _tokenContract = '0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB';

// transfer(address,uint256) -- selector, then two 32-byte words:
//   arg0 = _recipient
//   arg1 = 1500000  (0x16e360; 1.5 at six decimals)
const _transferCalldata =
    '0xa9059cbb'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

// approve(address,uint256) over identical argument words.
const _approveCalldata =
    '0x095ea7b3'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

const _sixDecimalCoin = Coin(
  symbol: 'USDC',
  // Deliberately mixed case, and NOT the case the transaction carries -- the
  // contract match has to be case-insensitive or a real wallet's coin list
  // would never line up with a dApp's calldata.
  address: _tokenContract,
  decimals: '6',
);

Map<String, dynamic> _tx({String? data, String? value, String? to}) => {
  'from': '0x0000000000000000000000000000000000000001',
  'to': to ?? _tokenContract.toLowerCase(),
  'value': value ?? '0x0',
  'gas': '0x5208',
  'maxFeePerGas': '0x3b9aca00',
  'maxPriorityFeePerGas': '0x3b9aca00',
  if (data != null) 'data': data,
};

void main() {
  group('tryDecodeErc20Transfer - reading the two arguments', () {
    test('a real transfer yields its recipient and its raw amount', () {
      final decoded = tryDecodeErc20Transfer(_transferCalldata);
      expect(decoded, isNotNull);
      expect(decoded!.counterparty.eip55With0x, _recipient);
      expect(decoded.amount, BigInt.from(1500000));
    });

    test('an uppercase-hex payload decodes the same', () {
      final decoded = tryDecodeErc20Transfer(
        '0X${_transferCalldata.substring(2).toUpperCase()}',
      );
      expect(decoded?.counterparty.eip55With0x, _recipient);
    });

    group('REJECTED - every malformed shape returns null, never throws', () {
      test('null data', () {
        expect(tryDecodeErc20Transfer(null), isNull);
      });

      test('empty string', () {
        expect(tryDecodeErc20Transfer(''), isNull);
      });

      test('a different selector over valid-looking words', () {
        expect(tryDecodeErc20Transfer(_approveCalldata), isNull);
      });

      test('the right selector but one byte short of two full words', () {
        expect(
          tryDecodeErc20Transfer(
            _transferCalldata.substring(0, _transferCalldata.length - 2),
          ),
          isNull,
        );
      });

      test('selector only', () {
        expect(tryDecodeErc20Transfer('0xa9059cbb'), isNull);
      });

      test('non-hex characters', () {
        expect(tryDecodeErc20Transfer('0xzzzz'), isNull);
      });

      test('odd-length hex', () {
        expect(tryDecodeErc20Transfer('0xa9059cbbf'), isNull);
      });
    });
  });

  group('the hardcoded selector agrees with the ABI', () {
    // The selector is typed by hand for readability. This is what stops a
    // typo in it from silently meaning "decode nothing, ever".
    test('kErc20TransferSelector is transfer()s derived selector', () {
      final fn = Web3.abi.functions.firstWhere((f) => f.name == 'transfer');
      expect(bytesToHex(fn.selector, include0x: true), kErc20TransferSelector);
      expect(fn.encodeName(), 'transfer(address,uint256)');
    });

    test('kErc20ApproveSelector is approve()s derived selector', () {
      final fn = Web3.abi.functions.firstWhere((f) => f.name == 'approve');
      expect(bytesToHex(fn.selector, include0x: true), kErc20ApproveSelector);
      expect(fn.encodeName(), 'approve(address,uint256)');
    });
  });

  group('summarizeTransaction - what the drawer is allowed to claim', () {
    test('a transfer of a coin the wallet knows is a token send', () {
      final summary = summarizeTransaction(
        _tx(data: _transferCalldata),
        coins: const [_sixDecimalCoin],
      );
      expect(summary.kind, DappCallKind.tokenTransfer);
      expect(summary.recipient, _recipient);
      expect(summary.amount, '1.5');
      expect(summary.symbol, 'USDC');
    });

    test(
      'the same transfer for a coin the wallet does not hold is unknown',
      () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [Coin(symbol: 'ETH', address: '0xdead', decimals: '18')],
        );
        expect(summary.kind, DappCallKind.unknownCall);
        expect(summary.symbol, isNull);
        expect(summary.amount, isNull);
      },
    );

    test('a wallet holding no coins at all cannot resolve one', () {
      expect(
        summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [],
        ).kind,
        DappCallKind.unknownCall,
      );
    });

    test('a transfer with no to address resolves to nothing', () {
      final tx = _tx(data: _transferCalldata);
      tx.remove('to');
      expect(
        summarizeTransaction(tx, coins: const [_sixDecimalCoin]).kind,
        DappCallKind.unknownCall,
      );
    });

    group('UNRESOLVED decimals are never assumed to be 18', () {
      // A wrong decimals guess renders a confident wrong number. Eighteen is
      // the commonest value and therefore the most tempting default; each of
      // these cases would show "0.0000000000015 USDC" for 1.5 USDC if it were
      // used.
      test('null decimals', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [Coin(symbol: 'USDC', address: _tokenContract)],
        );
        expect(summary.kind, DappCallKind.unknownCall);
      });

      test('unparseable decimals', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [
            Coin(symbol: 'USDC', address: _tokenContract, decimals: 'six'),
          ],
        );
        expect(summary.kind, DappCallKind.unknownCall);
      });

      test('a negative decimals string', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [
            Coin(symbol: 'USDC', address: _tokenContract, decimals: '-6'),
          ],
        );
        expect(summary.kind, DappCallKind.unknownCall);
      });

      test('an absurd decimals string', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [
            Coin(symbol: 'USDC', address: _tokenContract, decimals: '999'),
          ],
        );
        expect(summary.kind, DappCallKind.unknownCall);
      });

      test('a blank symbol leaves the amount without a unit, so unknown', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [
            Coin(symbol: '  ', address: _tokenContract, decimals: '6'),
          ],
        );
        expect(summary.kind, DappCallKind.unknownCall);
      });
    });

    test('a transfer that ALSO moves native value is unknown', () {
      // Two amounts move but the send rows can only state one. Claiming just
      // the token half would understate what leaves the wallet.
      final summary = summarizeTransaction(
        _tx(data: _transferCalldata, value: '0x2386f26fc10000'),
        coins: const [_sixDecimalCoin],
      );
      expect(summary.kind, DappCallKind.unknownCall);
    });

    group('NATIVE SEND - anything unreadable keeps todays behaviour', () {
      test('no data key at all', () {
        expect(
          summarizeTransaction(_tx(), coins: const [_sixDecimalCoin]).kind,
          DappCallKind.nativeSend,
        );
      });

      test('empty data', () {
        expect(
          summarizeTransaction(
            _tx(data: '0x'),
            coins: const [_sixDecimalCoin],
          ).kind,
          DappCallKind.nativeSend,
        );
      });

      test('an approve is not a transfer, and gets no surface yet', () {
        expect(
          summarizeTransaction(
            _tx(data: _approveCalldata),
            coins: const [_sixDecimalCoin],
          ).kind,
          DappCallKind.nativeSend,
        );
      });

      test('garbage calldata', () {
        expect(
          summarizeTransaction(
            _tx(data: 'not-hex-at-all'),
            coins: const [_sixDecimalCoin],
          ).kind,
          DappCallKind.nativeSend,
        );
      });

      test('a non-string data value', () {
        final tx = _tx();
        tx['data'] = 42;
        expect(
          summarizeTransaction(tx, coins: const [_sixDecimalCoin]).kind,
          DappCallKind.nativeSend,
        );
      });
    });
  });
}
