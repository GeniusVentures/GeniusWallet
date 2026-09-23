// The send path against a real JSON-RPC endpoint on localhost: what reaches
// the caller when the node answers badly, or not at all.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex, hexToBytes, keccak256;

const _from = '0x1234567890123456789012345678901234567890';

/// Serves [reply]'s answer for each call; a null answer closes the
/// connection without a response, the way a dropped link looks.
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
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({'jsonrpc': '2.0', 'id': body['id'], ...answer}),
    );
    await request.response.close();
  });
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
      expect(broadcast, isNotNull);
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
  });
}
