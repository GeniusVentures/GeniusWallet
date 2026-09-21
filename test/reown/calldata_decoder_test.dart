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
//   - an unknown token or an unreadable `decimals` starts being presented as
//     a confident token send, or a call that ALSO moves native value drops
//     either figure,
//   - malformed calldata throws instead of falling back to today's path,
//   - or decoding starts writing into the map that gets signed.
//
// That last one is the only one here that is not merely a display bug: the
// same `Map` instance is handed to the signer by reference, so a byte written
// during decode is a byte the user did not agree to.

import 'dart:convert';
import 'dart:io';

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

// approve(_recipient, 0): the allowance is being taken away, not granted.
const _revokeCalldata =
    '0x095ea7b3'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '0000000000000000000000000000000000000000000000000000000000000000';

// A well-formed call to a function this wallet has no ABI for: the shape a
// real router or NFT marketplace sends, not malformed input.
const _unknownSelectorCalldata =
    '0xdeadbeef'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '000000000000000000000000000000000000000000000000000000000016e360';

/// The same approve with `arg1` set to the allowance word named in the suffix.
String _approveOf(String allowanceWord) =>
    '0x095ea7b3'
    '0000000000000000000000005aaeb6053f3e94c9b9a09f33669435e7ef1beaed'
    '$allowanceWord';

// 2^256 - 1, the sentinel every "infinite approval" in the wild actually
// sends.
final _maxUintApprove = _approveOf('f' * 64);

// Exactly 2^255, and one below it: the two sides of the single comparison
// that decides whether the drawer shouts.
final _thresholdApprove = _approveOf('8${'0' * 63}');
final _belowThresholdApprove = _approveOf('7${'f' * 63}');

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
  'data': ?data,
};

// -- The recorded Squid route.
//
// Captured from this repo's own live-API fixture, which lives on another
// branch and is read with:
//   git show refs/heads/phase-29-integrator-fee:test/squid_router/fixtures/route_response_executable.json
// Trimmed to the fields asserted below and read from disk rather than pasted,
// because 2.3 KB of calldata transcribed by hand proves nothing.
//
// Squid states `transactionRequest.value` as a decimal string; a dApp hands
// the wallet the hex form an `eth_sendTransaction` actually carries, which is
// what the transactions built here use.
const _squidFixturePath =
    'test/reown/fixtures/squid_route_transaction_request.json';

Map<String, dynamic> _squidFixture() =>
    jsonDecode(File(_squidFixturePath).readAsStringSync())
        as Map<String, dynamic>;

// The destination of that recorded route. Its address IS inside the payload,
// nested at a route-dependent position -- finding it there would be a guess a
// hostile payload could seed, so nothing this wallet shows may contain it.
const _recordedDestinationToken = '833589fcd6edb6e08f4c7c32d4f71b54bda02913';

void main() {
  group('tryDecodeErc20Transfer - reading the two arguments', () {
    test('a real transfer yields its recipient and its raw amount', () {
      final decoded = tryDecodeErc20Transfer(_transferCalldata);
      expect(decoded, isNotNull);
      expect(decoded!.counterparty.eip55With0x, _recipient);
      expect(decoded.amount, BigInt.from(1500000));
    });

    test('uppercase hex digits decode the same', () {
      final decoded = tryDecodeErc20Transfer(
        '0x${_transferCalldata.substring(2).toUpperCase()}',
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

  group('tryDecodeErc20Approve - reading the two arguments', () {
    test('a real approve yields its spender and its raw allowance', () {
      final decoded = tryDecodeErc20Approve(_approveCalldata);
      expect(decoded, isNotNull);
      expect(decoded!.counterparty.eip55With0x, _recipient);
      expect(decoded.amount, BigInt.from(1500000));
    });

    test('the max-uint256 sentinel decodes rather than overflowing', () {
      final decoded = tryDecodeErc20Approve(_maxUintApprove);
      expect(decoded?.amount, BigInt.two.pow(256) - BigInt.one);
    });

    group('REJECTED - every malformed shape returns null, never throws', () {
      test('a transfer is not an approve', () {
        expect(tryDecodeErc20Approve(_transferCalldata), isNull);
      });

      test('null data', () {
        expect(tryDecodeErc20Approve(null), isNull);
      });

      test('the right selector but one byte short of two full words', () {
        expect(
          tryDecodeErc20Approve(
            _approveCalldata.substring(0, _approveCalldata.length - 2),
          ),
          isNull,
        );
      });

      test('non-hex characters', () {
        expect(tryDecodeErc20Approve('0xzzzz'), isNull);
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
      'the same transfer for a coin the wallet does not hold is unverified',
      () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [Coin(symbol: 'ETH', address: '0xdead', decimals: '18')],
        );
        expect(summary.kind, DappCallKind.unverifiedToken);
        expect(summary.recipient, _recipient);
        // Raw base units and no unit at all: the only two things still true
        // once the token cannot be identified.
        expect(summary.amount, '1500000');
        expect(summary.symbol, isNull);
        // The contract is what the user has to check, so it travels with the
        // summary rather than being looked up again downstream.
        expect(summary.tokenContract, _tokenContract.toLowerCase());
      },
    );

    test('a wallet holding no coins at all cannot resolve one', () {
      expect(
        summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: const [],
        ).kind,
        DappCallKind.unverifiedToken,
      );
    });

    test('an unknown token approve is unverified and still an approve', () {
      final summary = summarizeTransaction(
        _tx(data: _approveCalldata),
        coins: const [],
      );
      expect(summary.kind, DappCallKind.unverifiedToken);
      expect(summary.spender, _recipient);
      expect(summary.allowance, '1500000');
      expect(summary.recipient, isNull);
      expect(summary.amount, isNull);
    });

    test('a transfer with no to address resolves to nothing', () {
      final tx = _tx(data: _transferCalldata);
      tx.remove('to');
      expect(
        summarizeTransaction(tx, coins: const [_sixDecimalCoin]).kind,
        DappCallKind.unknownCall,
      );
    });

    test('a value that cannot be read at all is not a zero value', () {
      // Nothing honest can be said about how much native currency moves, so
      // there is no second figure to put beside the token one.
      expect(
        summarizeTransaction(
          _tx(data: _transferCalldata, value: 'not-hex'),
          coins: const [_sixDecimalCoin],
        ).kind,
        DappCallKind.unknownCall,
      );
    });

    group('UNRESOLVED decimals are never assumed to be eighteen', () {
      // A wrong decimals guess renders a confident wrong number. Eighteen is
      // the commonest value and therefore the most tempting default; each of
      // these cases would show "0.0000000000015 USDC" for 1.5 USDC if it were
      // used. This group is what fails if a convenience default is ever
      // added.
      void expectRawBaseUnits(Coin coin) {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata),
          coins: [coin],
        );
        expect(summary.kind, DappCallKind.unverifiedToken);
        expect(summary.amount, '1500000');
        expect(
          summary.amount,
          isNot(contains('.')),
          reason: 'base units carry no decimal point',
        );
        expect(summary.symbol, isNull);
      }

      test('null decimals', () {
        expectRawBaseUnits(const Coin(symbol: 'USDC', address: _tokenContract));
      });

      test('empty decimals', () {
        expectRawBaseUnits(
          const Coin(symbol: 'USDC', address: _tokenContract, decimals: ''),
        );
      });

      test('unparseable decimals', () {
        expectRawBaseUnits(
          const Coin(symbol: 'USDC', address: _tokenContract, decimals: 'abc'),
        );
      });

      test('a negative decimals string', () {
        expectRawBaseUnits(
          const Coin(symbol: 'USDC', address: _tokenContract, decimals: '-6'),
        );
      });

      test('an absurd decimals string', () {
        expectRawBaseUnits(
          const Coin(symbol: 'USDC', address: _tokenContract, decimals: '999'),
        );
      });

      test('a blank symbol leaves the amount without a unit', () {
        expectRawBaseUnits(
          const Coin(symbol: '  ', address: _tokenContract, decimals: '6'),
        );
      });
    });

    group('an approve is its own thing -- nothing moves', () {
      test('an approve of a coin the wallet knows names its spender', () {
        final summary = summarizeTransaction(
          _tx(data: _approveCalldata),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.kind, DappCallKind.tokenApprove);
        expect(summary.spender, _recipient);
        expect(summary.allowance, '1.5');
        expect(summary.symbol, 'USDC');
        expect(summary.tokenContract, _tokenContract.toLowerCase());
      });

      test('an approve is never described as a transfer', () {
        // The send body reads `recipient`/`amount`. Leaving them null is what
        // structurally stops an approval being rendered as money leaving.
        final summary = summarizeTransaction(
          _tx(data: _approveCalldata),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.recipient, isNull);
        expect(summary.amount, isNull);
      });

      group('UNLIMITED - one comparison at 2^255', () {
        test('the max-uint256 sentinel is flagged', () {
          expect(
            summarizeTransaction(
              _tx(data: _maxUintApprove),
              coins: const [_sixDecimalCoin],
            ).isUnlimitedAllowance,
            isTrue,
          );
        });

        test('exactly 2^255 is flagged -- the comparison is inclusive', () {
          expect(
            summarizeTransaction(
              _tx(data: _thresholdApprove),
              coins: const [_sixDecimalCoin],
            ).isUnlimitedAllowance,
            isTrue,
          );
        });

        test('one wei below the threshold is not', () {
          expect(
            summarizeTransaction(
              _tx(data: _belowThresholdApprove),
              coins: const [_sixDecimalCoin],
            ).isUnlimitedAllowance,
            isFalse,
          );
        });

        test('an ordinary allowance is not', () {
          expect(
            summarizeTransaction(
              _tx(data: _approveCalldata),
              coins: const [_sixDecimalCoin],
            ).isUnlimitedAllowance,
            isFalse,
          );
        });

        test('the threshold constant is 2^255, not 2^256 - 1', () {
          // Pinned because the tempting value is the sentinel itself, which
          // would miss every off-by-a-little variant dApp SDKs emit.
          expect(kUnlimitedApprovalThreshold, BigInt.two.pow(255));
        });
      });
    });

    group('a token call that ALSO moves native value shows both figures', () {
      // Two amounts move. The native one is kept beside the token one, and a
      // token the wallet resolved stays resolved: the extra value is not a
      // reason to forget its symbol and decimals.
      test('a transfer carries the token figure and the native one', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata, value: '0x2386f26fc10000'),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.kind, DappCallKind.tokenTransfer);
        expect(summary.amount, '1.5');
        expect(summary.symbol, _sixDecimalCoin.symbol);
        expect(summary.nativeAmount, contains('0.01'));
      });

      test('an approve does too, and stays an approve', () {
        final summary = summarizeTransaction(
          _tx(data: _approveCalldata, value: '0x2386f26fc10000'),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.kind, DappCallKind.tokenApprove);
        expect(summary.spender, _recipient);
        expect(summary.allowance, '1.5');
        expect(summary.symbol, _sixDecimalCoin.symbol);
        expect(summary.nativeAmount, contains('0.01'));
      });

      test('a zero allowance is a revocation, known token or not', () {
        final known = summarizeTransaction(
          _tx(data: _revokeCalldata, value: '0x0'),
          coins: const [_sixDecimalCoin],
        );
        expect(known.kind, DappCallKind.tokenApprove);
        expect(known.allowance, '0');
        expect(known.isRevocation, isTrue);
        expect(known.isUnlimitedAllowance, isFalse);

        final unknown = summarizeTransaction(
          _tx(data: _revokeCalldata, value: '0x0'),
          coins: const [],
        );
        expect(unknown.kind, DappCallKind.unverifiedToken);
        expect(unknown.isRevocation, isTrue);

        // A live allowance is not one, however small.
        expect(
          summarizeTransaction(
            _tx(data: _approveCalldata, value: '0x0'),
            coins: const [_sixDecimalCoin],
          ).isRevocation,
          isFalse,
        );
      });

      test('an unknown token with native value keeps both, in base units', () {
        final summary = summarizeTransaction(
          _tx(data: _transferCalldata, value: '0x2386f26fc10000'),
          coins: const [],
        );
        expect(summary.kind, DappCallKind.unverifiedToken);
        expect(summary.amount, '1500000');
        expect(summary.nativeAmount, contains('0.01'));
      });

      test('a zero value leaves no native figure to show', () {
        expect(
          summarizeTransaction(
            _tx(data: _transferCalldata),
            coins: const [_sixDecimalCoin],
          ).nativeAmount,
          isNull,
        );
      });
    });

    group('NATIVE SEND - only a transaction carrying no calldata at all', () {
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
    });

    group('UNKNOWN CALL - calldata that is present but unreadable', () {
      // The whole point of this group. A payload the wallet cannot decode is
      // certainly not a plain send of the native value: the calldata is what
      // the contract will act on, and none of it is shown by a send body.
      test('a selector this wallet does not know', () {
        final summary = summarizeTransaction(
          _tx(data: _unknownSelectorCalldata),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.kind, DappCallKind.unknownCall);
        expect(summary.selector, '0xdeadbeef');
      });

      test('garbage calldata', () {
        expect(
          summarizeTransaction(
            _tx(data: 'not-hex-at-all'),
            coins: const [_sixDecimalCoin],
          ).kind,
          DappCallKind.unknownCall,
        );
      });

      test('a non-string data value', () {
        final tx = _tx();
        tx['data'] = 42;
        expect(
          summarizeTransaction(tx, coins: const [_sixDecimalCoin]).kind,
          DappCallKind.unknownCall,
        );
      });

      test('calldata too short to hold a selector names no method', () {
        final summary = summarizeTransaction(
          _tx(data: '0xabcd'),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.kind, DappCallKind.unknownCall);
        expect(summary.selector, isNull);
      });

      test('a known selector on too short a payload is still unreadable', () {
        // Four bytes of `transfer` and nothing to transfer. Reading the
        // arguments out of this would read past the end of the payload.
        final summary = summarizeTransaction(
          _tx(data: kErc20TransferSelector),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.kind, DappCallKind.unknownCall);
        expect(summary.selector, kErc20TransferSelector);
      });

      test('what it can still state: the contract and the native value', () {
        final summary = summarizeTransaction(
          _tx(data: _unknownSelectorCalldata, value: '0x2386f26fc10000'),
          coins: const [_sixDecimalCoin],
        );
        expect(summary.tokenContract, _tokenContract.toLowerCase());
        expect(summary.nativeAmount, contains('0.01'));
        // Nothing about a counterparty or an amount was read, so nothing
        // about one may be claimed.
        expect(summary.recipient, isNull);
        expect(summary.spender, isNull);
        expect(summary.amount, isNull);
        expect(summary.symbol, isNull);
      });

      test('a zero value still has a value to state', () {
        // Unlike a token call, where a missing native figure means "no native
        // moves", an unreadable call has only this one figure to offer.
        expect(
          summarizeTransaction(
            _tx(data: _unknownSelectorCalldata),
            coins: const [_sixDecimalCoin],
          ).nativeAmount,
          isNotNull,
        );
      });

      test('no payload length or encoding makes it throw', () {
        for (final data in <String>[
          '0x',
          '0x0',
          '0xa',
          'zz',
          '0x${'f' * 4096}',
          _unknownSelectorCalldata,
        ]) {
          expect(
            () => summarizeTransaction(
              _tx(data: data),
              coins: const [_sixDecimalCoin],
            ),
            returnsNormally,
            reason: 'summarising "$data" must not throw',
          );
        }
      });
    });
  });

  group('the map that gets signed comes back untouched', () {
    // This is the only assertion in this file that is not about what is
    // displayed. The same `Map` instance travels on to the signer, which
    // re-reads `data`, `to` and `value` out of it -- so a key written, removed
    // or normalised during decoding is a difference between what was shown and
    // what was signed. Reading needs a lowercased `to` to match the coin list;
    // that has to happen on a copy.
    //
    // `to` is deliberately mixed case here. Lowercased in place, every
    // displayed value would still be right and only this test would notice.
    Map<String, dynamic> signableTx() => <String, dynamic>{
      'from': '0x00000000000000000000000000000000000000A1',
      'to': _tokenContract,
      'value': '0x0',
      'gas': '0x5208',
      'maxFeePerGas': '0x3B9ACA00',
      'maxPriorityFeePerGas': '0x3B9ACA00',
      'data': _transferCalldata,
    };

    test('a mixed-case contract address still resolves its coin', () {
      // Without this, the test below could pass by never reaching the code
      // that lowercases anything.
      final summary = summarizeTransaction(
        signableTx(),
        coins: const [_sixDecimalCoin],
      );
      expect(summary.kind, DappCallKind.tokenTransfer);
      expect(summary.symbol, 'USDC');
    });

    test('every key and value survives a decode unchanged', () {
      final tx = signableTx();
      final before = Map<String, dynamic>.of(tx);

      summarizeTransaction(tx, coins: const [_sixDecimalCoin]);

      expect(
        tx.keys.toList(),
        before.keys.toList(),
        reason: 'decoding must neither add nor remove a key',
      );
      for (final key in before.keys) {
        expect(
          tx[key],
          before[key],
          reason: '"$key" was rewritten during decoding',
        );
      }
      expect(tx, equals(before));
    });

    test('an undecodable transaction is left alone too', () {
      final tx = signableTx();
      tx['data'] = 'not-hex-at-all';
      final before = Map<String, dynamic>.of(tx);

      summarizeTransaction(tx, coins: const [_sixDecimalCoin]);

      expect(tx, equals(before));
    });
  });
  group('a recorded Squid route, read on its input side only', () {
    final fixture = _squidFixture();
    final request = fixture['transactionRequest'] as Map<String, dynamic>;
    final estimate = fixture['estimate'] as Map<String, dynamic>;
    final fromToken = estimate['fromToken'] as Map<String, dynamic>;

    final swapData = request['data'] as String;
    final router = request['target'] as String;
    final tokenIn = fromToken['address'] as String;
    final amountIn = BigInt.parse(estimate['fromAmount'] as String);
    final gnus = Coin(
      symbol: fromToken['symbol'] as String,
      address: tokenIn,
      decimals: (fromToken['decimals'] as int).toString(),
    );

    /// The selector and its first two words, and nothing else: 68 bytes.
    final twoWordsOnly = swapData.substring(0, 2 + 8 + 128);

    /// One byte short of two whole words, so reading them would run off the
    /// end of the payload.
    final sixtySevenBytes = swapData.substring(0, 2 + 67 * 2);

    Map<String, dynamic> swapTx({String? data, String? to, String? value}) =>
        <String, dynamic>{
          'from': '0x0000000000000000000000000000000000000001',
          'to': to ?? router,
          'value': value ?? '0x0',
          'data': data ?? swapData,
        };

    test('the fixture is the payload that was recorded', () {
      expect(hexToBytes(swapData).length, 2324);
      expect(swapData.substring(0, 10), kSquidSwapSelector);
      expect(hexToBytes(sixtySevenBytes).length, 67);
    });

    group('tryDecodeSwapInput - word 0 and word 1, and no further', () {
      test('the two words are the token in and the amount in', () {
        final decoded = tryDecodeSwapInput(swapData);
        expect(decoded, isNotNull);
        expect(decoded!.counterparty.eip55With0x.toLowerCase(), tokenIn);
        expect(decoded.amount, amountIn);
      });

      test('truncating to exactly those two words changes nothing', () {
        // Which is the proof that nothing past them was ever consulted.
        final decoded = tryDecodeSwapInput(twoWordsOnly);
        expect(decoded!.counterparty.eip55With0x.toLowerCase(), tokenIn);
        expect(decoded.amount, amountIn);
      });

      group('REJECTED - nothing is read at offsets a payload did not earn', () {
        test('the same 2.3 KB under a different selector', () {
          expect(
            tryDecodeSwapInput('0xdeadbeef${swapData.substring(10)}'),
            isNull,
          );
        });

        test('the right selector on 67 bytes -- one short of two words', () {
          expect(tryDecodeSwapInput(sixtySevenBytes), isNull);
        });

        test('the selector on its own', () {
          expect(tryDecodeSwapInput(kSquidSwapSelector), isNull);
        });

        test('null, empty, and non-hex', () {
          expect(tryDecodeSwapInput(null), isNull);
          expect(tryDecodeSwapInput(''), isNull);
          expect(tryDecodeSwapInput('0xzzzz'), isNull);
        });

        test('an ERC-20 transfer is not a swap', () {
          expect(tryDecodeSwapInput(_transferCalldata), isNull);
        });

        test('a swap is not an ERC-20 transfer or approve either', () {
          expect(tryDecodeErc20Transfer(swapData), isNull);
          expect(tryDecodeErc20Approve(swapData), isNull);
        });
      });
    });

    group('the allow-list is a claim, so it ships one chain', () {
      test('the recorded target on Base is named', () {
        expect(knownRouterName(8453, router), 'Squid');
      });

      test('the case the transaction happens to use is not part of it', () {
        expect(knownRouterName(8453, router.toLowerCase()), 'Squid');
        expect(knownRouterName(8453, router.toUpperCase()), 'Squid');
      });

      test('the same address on any other chain is not named', () {
        // Only 8453 is evidenced by the recorded response. An entry for
        // another chain would be a claim with nothing behind it.
        expect(knownRouterName(1, router), isNull);
        expect(knownRouterName(137, router), isNull);
        expect(knownRouterName(42161, router), isNull);
      });

      test('a null chain or a null address names nothing', () {
        expect(knownRouterName(null, router), isNull);
        expect(knownRouterName(8453, null), isNull);
        expect(knownRouterName(null, null), isNull);
      });

      test('some other contract on Base is not a router', () {
        expect(knownRouterName(8453, _tokenContract), isNull);
      });

      test('exactly one chain, carrying exactly one router', () {
        expect(kKnownRouters.keys.toList(), [8453]);
        expect(kKnownRouters[8453]!.length, 1);
      });

      test('every listed address is lowercased, so the lookup can match', () {
        for (final byChain in kKnownRouters.values) {
          for (final address in byChain.keys) {
            expect(address, address.toLowerCase());
          }
        }
      });
    });

    group('summarizeTransaction - what a swap may be said to do', () {
      test('a known router and a known token name what goes in', () {
        final summary = summarizeTransaction(
          swapTx(),
          coins: [gnus],
          chainId: 8453,
        );
        expect(summary.kind, DappCallKind.routerSwap);
        expect(summary.routerName, 'Squid');
        expect(summary.tokenContract, router);
        expect(summary.tokenIn!.toLowerCase(), tokenIn);
        expect(summary.symbol, 'GNUS');
        // The repo's own formatter trims trailing zeros, so one whole token
        // at eighteen decimals renders as "1", not "1.0".
        expect(summary.amount, '1');
      });

      test('the destination is nowhere in what it claims', () {
        final summary = summarizeTransaction(
          swapTx(),
          coins: [gnus],
          chainId: 8453,
        );
        expect(summary.recipient, isNull);
        expect(summary.spender, isNull);
        expect(summary.allowance, isNull);
        expect(summary.symbol, isNot('USDC'));
        for (final field in <String?>[
          summary.symbol,
          summary.amount,
          summary.tokenIn,
          summary.tokenContract,
          summary.routerName,
        ]) {
          expect(
            field?.toLowerCase() ?? '',
            isNot(contains(_recordedDestinationToken)),
            reason: 'the destination token was found by scanning the payload',
          );
        }
      });

      test('an input token the wallet cannot name stays in base units', () {
        final summary = summarizeTransaction(
          swapTx(),
          coins: const [],
          chainId: 8453,
        );
        expect(summary.kind, DappCallKind.routerSwap);
        expect(summary.symbol, isNull);
        expect(summary.amount, amountIn.toString());
        expect(
          summary.amount,
          isNot(contains('.')),
          reason: 'base units carry no decimal point',
        );
      });

      test('the same payload to the same address off Base is unreadable', () {
        final summary = summarizeTransaction(
          swapTx(),
          coins: [gnus],
          chainId: 1,
        );
        expect(summary.kind, DappCallKind.unknownCall);
        expect(summary.routerName, isNull);
        expect(summary.selector, kSquidSwapSelector);
        expect(summary.amount, isNull);
      });

      test('no chain selected reads nothing either', () {
        expect(
          summarizeTransaction(swapTx(), coins: [gnus]).kind,
          DappCallKind.unknownCall,
        );
      });

      test('a known router carrying a selector nobody knows is unreadable', () {
        final summary = summarizeTransaction(
          swapTx(data: _unknownSelectorCalldata),
          coins: [gnus],
          chainId: 8453,
        );
        expect(summary.kind, DappCallKind.unknownCall);
        // Still named: the user is not told an allow-listed router is an
        // unknown contract. Nothing about the call itself is claimed.
        expect(summary.routerName, 'Squid');
        expect(summary.selector, '0xdeadbeef');
        expect(summary.amount, isNull);
        expect(summary.symbol, isNull);
        expect(summary.tokenIn, isNull);
      });

      test('a known router carrying a truncated swap is unreadable too', () {
        final summary = summarizeTransaction(
          swapTx(data: sixtySevenBytes),
          coins: [gnus],
          chainId: 8453,
        );
        expect(summary.kind, DappCallKind.unknownCall);
        expect(summary.routerName, 'Squid');
        expect(summary.selector, kSquidSwapSelector);
        expect(summary.tokenIn, isNull);
      });

      test('a value that cannot be read is not a readable swap', () {
        expect(
          summarizeTransaction(
            swapTx(value: 'not-hex'),
            coins: [gnus],
            chainId: 8453,
          ).kind,
          DappCallKind.unknownCall,
        );
      });

      test('a swap that also moves native value keeps that figure', () {
        final summary = summarizeTransaction(
          swapTx(value: '0x2386f26fc10000'),
          coins: [gnus],
          chainId: 8453,
        );
        expect(summary.kind, DappCallKind.routerSwap);
        expect(summary.nativeAmount, contains('0.01'));
      });

      test('a plain send to a known router is still a plain send', () {
        expect(
          summarizeTransaction(
            swapTx(data: '0x'),
            coins: [gnus],
            chainId: 8453,
          ).kind,
          DappCallKind.nativeSend,
        );
      });

      test('an ERC-20 approve of the router is still an approve', () {
        // The transaction that precedes a swap, and it must not be swallowed
        // by the router branch.
        final summary = summarizeTransaction(
          swapTx(data: _approveCalldata, to: _tokenContract),
          coins: const [_sixDecimalCoin],
          chainId: 8453,
        );
        expect(summary.kind, DappCallKind.tokenApprove);
        expect(summary.spender, _recipient);
      });

      test('the swap is filed under the token it spends', () {
        expect(
          receiptSymbol(
            summarizeTransaction(swapTx(), coins: [gnus], chainId: 8453),
            nativeSymbol: 'ETH',
          ),
          'GNUS',
        );
      });

      test('an unnameable input token is filed under its address', () {
        expect(
          receiptSymbol(
            summarizeTransaction(swapTx(), coins: const [], chainId: 8453),
            nativeSymbol: 'ETH',
          ).toLowerCase(),
          tokenIn,
        );
      });

      test('the recorded route leaves the signed map untouched', () {
        final tx = swapTx();
        final before = Map<String, dynamic>.of(tx);
        summarizeTransaction(tx, coins: [gnus], chainId: 8453);
        expect(tx, equals(before));
      });
    });
  });
}
