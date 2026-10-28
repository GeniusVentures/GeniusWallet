// The bridge burn's send step against a JSON-RPC endpoint on localhost.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

final _key = EthPrivateKey.fromHex('0x${'11' * 32}');

/// Answers like a node: nonce and gas price, then the raw transaction's hash computed
/// from the bytes it received. [dropSend] closes the send unanswered and
/// [refuseSend] answers it with a JSON-RPC error. [log] records each method.
Future<String> _node(
  List<String> log, {
  bool dropSend = false,
  bool refuseSend = false,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  addTearDown(() => server.close(force: true));
  server.listen((request) async {
    final body =
        jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>;
    final method = body['method'] as String;
    log.add(method);
    if (method == 'eth_sendRawTransaction') {
      final raw = hexToBytes((body['params'] as List).first as String);
      // A legacy transaction is a bare RLP list; a typed one starts below it.
      log.add(raw.first >= 0xc0 ? 'legacy' : 'typed');
    }
    if (method == 'eth_sendRawTransaction' && dropSend) {
      final socket = await request.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    final Map<String, Object?> answer = switch (method) {
      'eth_getTransactionCount' => {'result': '0x0'},
      'eth_gasPrice' => {'result': '0x3b9aca00'},
      'eth_sendRawTransaction' when refuseSend => {
        'error': {'code': -32000, 'message': 'nonce too low'},
      },
      'eth_sendRawTransaction' => {
        'result': bytesToHex(
          keccak256(hexToBytes((body['params'] as List).first as String)),
          include0x: true,
        ),
      },
      _ => {
        'error': {'code': -32601, 'message': 'unexpected $method'},
      },
    };
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({'jsonrpc': '2.0', 'id': body['id'], ...answer}),
    );
    await request.response.close();
  });
  return 'http://127.0.0.1:${server.port}';
}

Transaction _burn() => Transaction(
  from: _key.address,
  to: _key.address,
  maxGas: 100000,
  data: Uint8List.fromList([1, 2, 3]),
);

void main() {
  Future<(ApiResponse<String>, String?)> send(
    String url,
    List<String> log, {
    bool failHook = false,
  }) async {
    final client = Web3Client(url, Client());
    addTearDown(client.dispose);
    String? seen;
    final resp = await Web3.broadcastSigned(
      client,
      _key,
      _burn(),
      chainId: 80002,
      beforeBroadcast: (hash) async {
        seen = hash;
        log.add('beforeBroadcast');
        if (failHook) {
          throw const FileSystemException('disk full');
        }
      },
    );
    return (resp, seen);
  }

  test(
    'the hash handed out before the send is the one the node returns',
    () async {
      final log = <String>[];
      final (resp, seen) = await send(await _node(log), log);

      expect(resp.isSuccess, isTrue);
      expect(resp.data, seen);
      expect(log.sublist(log.length - 3), [
        'beforeBroadcast',
        'eth_sendRawTransaction',
        'legacy',
      ]);
    },
  );

  test('a send with no answer is unconfirmed under the same hash', () async {
    final log = <String>[];
    final (resp, seen) = await send(await _node(log, dropSend: true), log);

    expect(resp.isSuccess, isFalse);
    expect(seen, isNotNull);
    expect(resp.data, seen);
  });

  test('a send the node refuses is a plain error', () async {
    final log = <String>[];
    final (resp, _) = await send(await _node(log, refuseSend: true), log);

    expect(resp.isSuccess, isFalse);
    expect(resp.data, isNull);
  });

  test('a throw before the broadcast means nothing is sent', () async {
    final log = <String>[];
    final (resp, _) = await send(await _node(log), log, failHook: true);

    expect(resp.isSuccess, isFalse);
    expect(resp.data, isNull);
    expect(log, isNot(contains('eth_sendRawTransaction')));
  });
}
