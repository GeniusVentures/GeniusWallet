// The send path against a real JSON-RPC endpoint on localhost: what reaches
// the caller when the node answers badly, or not at all.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex, hexToBytes, keccak256;

const _from = '0x1234567890123456789012345678901234567890';

/// Serves [reply]'s answer for each call; a null answer closes the
/// connection without a response, the way a dropped link looks. [_stall]
/// never answers, and [_html] answers the way a rate limiter's page does.
Future<String> _serve(
  Map<String, dynamic>? Function(String method, List<dynamic> params) reply,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((request) async {
    final body =
        jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>;
    final answer = reply(
      body['method'] as String,
      body['params'] as List<dynamic>,
    );
    if (answer == null) {
      final socket = await request.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    if (identical(answer, _stall)) {
      return;
    }
    if (identical(answer, _html)) {
      request.response.statusCode = 502;
      request.response.headers.contentType = ContentType.html;
      request.response.write('<html><body>502 Bad Gateway</body></html>');
      await request.response.close();
      return;
    }
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({'jsonrpc': '2.0', 'id': body['id'], ...answer}),
    );
    await request.response.close();
  });
  return 'http://127.0.0.1:${server.port}';
}

const Map<String, dynamic> _stall = {};
const Map<String, dynamic> _html = {'html': true};

/// Accepts every call and never answers it -- a stalled RPC.
Future<String> _serveNothing() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((_) {});
  return 'http://127.0.0.1:${server.port}';
}

Map<String, dynamic> _tx() => {
  'from': _from,
  'to': _from,
  'value': '0x1',
  'gas': '0x5208',
  'maxFeePerGas': '0x3b9aca00',
  'maxPriorityFeePerGas': '0x3b9aca00',
};

void main() {
  group('a stalled RPC', () {
    setUp(() => rpcReadTimeout = const Duration(milliseconds: 200));
    tearDown(() => rpcReadTimeout = const Duration(seconds: 15));

    test('fails a balance read instead of waiting forever', () async {
      final rpcUrl = await _serveNothing();

      await expectLater(
        Web3().readNativeBalance(address: _from, rpcUrl: rpcUrl),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('fails a fee read with SendFeeUnavailable', () async {
      final rpcUrl = await _serveNothing();

      await expectLater(
        Web3().readSendFee(rpcUrl: rpcUrl, sender: _from, recipient: _from),
        throwsA(isA<SendFeeUnavailable>()),
      );
    });

    test('fails a receipt read, which a poll counts as "not yet"', () async {
      final rpcUrl = await _serveNothing();

      await expectLater(
        Web3().readReceipt(hash: '0x${'ab' * 32}', rpcUrl: rpcUrl),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('fails the token balance read a send relies on', () async {
      final rpcUrl = await _serveNothing();

      await expectLater(
        Web3().readTokenBalance(
          address: _from,
          contractAddress: _from,
          rpcUrl: rpcUrl,
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('ends a token balance read', () async {
      final rpcUrl = await _serveNothing();

      final balance = await Web3().rawBalanceOf(
        address: _from,
        contractAddress: _from,
        rpcUrl: rpcUrl,
      );

      expect(balance, BigInt.zero);
    });
  });

  group('readSendFee', () {
    test('a native send is simulated with its value attached', () async {
      Map<String, dynamic>? estimated;
      final rpcUrl = await _serve((method, params) {
        if (method == 'eth_gasPrice') {
          return {'result': '0x3b9aca00'};
        }
        if (method == 'eth_estimateGas') {
          estimated = params.first as Map<String, dynamic>;
          return {'result': '0x5208'};
        }
        return {
          'error': {'code': -32601, 'message': 'unexpected $method'},
        };
      });

      await Web3().readSendFee(
        rpcUrl: rpcUrl,
        sender: _from,
        recipient: _from,
        value: BigInt.from(1000),
      );

      expect(estimated?['value'], '0x3e8');
    });

    Future<String> serveBase(List<String> calls) => _serve((method, params) {
      calls.add(method);
      if (method == 'eth_gasPrice') {
        return {'result': '0x3b9aca00'};
      }
      if (method == 'eth_estimateGas') {
        return {'result': '0x5208'};
      }
      if (method == 'eth_call') {
        final to = (params.first as Map<String, dynamic>)['to'] as String;
        if (to.toLowerCase() == '0x420000000000000000000000000000000000000f') {
          return {'result': '0x${'0' * 58}0f4240'}; // 1,000,000 wei
        }
      }
      return {
        'error': {'code': -32601, 'message': 'unexpected $method'},
      };
    });

    test('an OP-Stack chain adds the L1 data fee to the max cost', () async {
      final rpcUrl = await serveBase([]);

      final fee = await Web3().readSendFee(
        rpcUrl: rpcUrl,
        sender: _from,
        recipient: _from,
        chainId: 8453,
      );

      expect(fee.l1Fee, BigInt.from(1000000));
      expect(
        fee.maxCost,
        BigInt.from(1000000000) * BigInt.from(21000) + BigInt.from(1000000),
      );
    });

    test('any other chain reads no L1 fee', () async {
      final calls = <String>[];
      final rpcUrl = await serveBase(calls);

      final fee = await Web3().readSendFee(
        rpcUrl: rpcUrl,
        sender: _from,
        recipient: _from,
        chainId: 137,
      );

      expect(fee.l1Fee, BigInt.zero);
      expect(calls, isNot(contains('eth_call')));
    });
  });

  group('signAndSendTransaction', () {
    test('a broadcast the node never answers hands back its hash', () async {
      String? broadcast;
      final rpcUrl = await _serve((method, params) {
        if (method == 'eth_getTransactionCount') {
          return {'result': '0x0'};
        }
        if (method == 'eth_sendRawTransaction') {
          broadcast = params.first as String;
          return null;
        }
        return {
          'error': {'code': -32601, 'message': 'unexpected $method'},
        };
      });

      final result = await Web3().signAndSendTransaction(
        tx: _tx(),
        rpcUrl: rpcUrl,
        privateKey: '11' * 32,
        chainId: 80002,
      );

      expect(result.isSuccess, isFalse);
      expect(broadcast, startsWith('0x02'));
      expect(
        result.data,
        bytesToHex(keccak256(hexToBytes(broadcast!)), include0x: true),
      );
    });

    test('an accepted broadcast is a typed EIP-1559 envelope', () async {
      String? broadcast;
      final rpcUrl = await _serve((method, params) {
        if (method == 'eth_getTransactionCount') {
          return {'result': '0x0'};
        }
        if (method == 'eth_sendRawTransaction') {
          broadcast = params.first as String;
          return {
            'result': bytesToHex(
              keccak256(hexToBytes(broadcast!)),
              include0x: true,
            ),
          };
        }
        if (method == 'eth_getTransactionReceipt') {
          return {'result': null};
        }
        return {
          'error': {'code': -32601, 'message': 'unexpected $method'},
        };
      });

      final result = await Web3().signAndSendTransaction(
        tx: _tx(),
        rpcUrl: rpcUrl,
        privateKey: '11' * 32,
        chainId: 80002,
      );

      expect(result.isSuccess, isTrue);
      expect(broadcast, startsWith('0x02'));
      expect(
        result.data,
        bytesToHex(keccak256(hexToBytes(broadcast!)), include0x: true),
      );
    });

    test('a broadcast the node refuses hands back no hash', () async {
      final rpcUrl = await _serve((method, params) {
        if (method == 'eth_getTransactionCount') {
          return {'result': '0x0'};
        }
        return {
          'error': {'code': -32000, 'message': 'insufficient funds'},
        };
      });

      final result = await Web3().signAndSendTransaction(
        tx: _tx(),
        rpcUrl: rpcUrl,
        privateKey: '11' * 32,
        chainId: 80002,
      );

      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
    });

    group('against a stalled or garbled node', () {
      setUp(() => rpcReadTimeout = const Duration(milliseconds: 200));
      tearDown(() => rpcReadTimeout = const Duration(seconds: 15));

      Future<ApiResponse<String>> send(String rpcUrl) =>
          Web3().signAndSendTransaction(
            tx: _tx(),
            rpcUrl: rpcUrl,
            privateKey: '11' * 32,
            chainId: 80002,
          );

      test('a stalled nonce read fails, with nothing broadcast', () async {
        final rpcUrl = await _serveNothing();

        final result = await send(rpcUrl);

        expect(result.isSuccess, isFalse);
        expect(result.data, isNull);
      });

      test('a stalled broadcast hands back its hash', () async {
        String? broadcast;
        final rpcUrl = await _serve((method, params) {
          if (method == 'eth_getTransactionCount') {
            return {'result': '0x0'};
          }
          if (method == 'eth_sendRawTransaction') {
            broadcast = params.first as String;
            return _stall;
          }
          return {
            'error': {'code': -32601, 'message': 'unexpected $method'},
          };
        });

        final result = await send(rpcUrl);

        expect(result.isSuccess, isFalse);
        expect(
          result.data,
          bytesToHex(keccak256(hexToBytes(broadcast!)), include0x: true),
        );
      });

      test('an HTML error page is a refusal, not a maybe', () async {
        final rpcUrl = await _serve((method, params) {
          if (method == 'eth_getTransactionCount') {
            return {'result': '0x0'};
          }
          return _html;
        });

        final result = await send(rpcUrl);

        expect(result.isSuccess, isFalse);
        expect(result.data, isNull);
      });

      test(
        'a stalled receipt read after an accepted send still returns',
        () async {
          final rpcUrl = await _serve((method, params) {
            if (method == 'eth_getTransactionCount') {
              return {'result': '0x0'};
            }
            if (method == 'eth_sendRawTransaction') {
              return {
                'result': bytesToHex(
                  keccak256(hexToBytes(params.first as String)),
                  include0x: true,
                ),
              };
            }
            return _stall;
          });

          final result = await send(rpcUrl);

          expect(result.isSuccess, isTrue);
        },
      );
    });
  });
}
