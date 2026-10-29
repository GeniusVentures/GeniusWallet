// The burn's per-chain bridgeOut form against a JSON-RPC endpoint on localhost.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/bridge_out_abi.dart';
import 'package:genius_api/web3/web3.dart' show EthereumAddress;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const _fiveArg = bridgeOutFiveArgSelector;
const _threeArg = bridgeOutThreeArgSelector;
final _contract = EthereumAddress.fromHex(
  '0x9af8050220D8C355CA3c6dC00a78B474cd3e3c70',
);

String _account(int privateKey) {
  final key = Uint8List(32)..[31] = privateKey;
  return '0x${bytesToHex(privateKeyBytesToPublic(key))}';
}

class _Node {
  _Node(this.facets);

  /// Selector (`0x` + 8 hex) to the facet address the loupe answers.
  final Map<String, String> facets;
  bool failLoupe = false;
  final loupeCalls = <String>[];
  final estimates = <String>[];
  late final String url;

  static Future<_Node> start(Map<String, String> facets) async {
    final node = _Node(facets);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      final body =
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      final method = body['method'] as String;
      final params = body['params'] as List;
      Map<String, Object?> answer;
      if (method == 'eth_call' &&
          !((params.first as Map)['data'] as String).startsWith('0xcdffacc6')) {
        answer = {
          'error': {'code': -32000, 'message': 'not the loupe'},
        };
      } else if (method == 'eth_call') {
        final data = (params.first as Map)['data'] as String;
        final selector = '0x${data.substring(10, 18)}';
        node.loupeCalls.add(selector);
        final facet = node.facets[selector] ?? '0x${'00' * 20}';
        answer = node.failLoupe
            ? {
                'error': {'code': -32000, 'message': 'node down'},
              }
            : {'result': '0x${'00' * 12}${facet.substring(2)}'};
      } else if (method == 'eth_estimateGas') {
        node.estimates.add((params.first as Map)['data'] as String);
        answer = {'result': '0x5208'};
      } else {
        answer = {
          'error': {'code': -32601, 'message': 'unexpected $method'},
        };
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'jsonrpc': '2.0', 'id': body['id'], ...answer}),
      );
      await request.response.close();
    });
    node.url = 'http://127.0.0.1:${server.port}';
    return node;
  }
}

String _facet() => '0x${'11' * 20}';

void main() {
  setUp(resetBridgeOutFormCacheForTest);

  Web3Client clientFor(_Node node) {
    final client = Web3Client(node.url, Client());
    addTearDown(client.dispose);
    return client;
  }

  group('sgnsDestination', () {
    test('key 1 gives X of the generator and an even Y', () {
      final dest = sgnsDestination(_account(1))!;
      expect(
        bytesToHex(dest.x),
        '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
      );
      expect(dest.yOdd, isFalse);
    });

    test('key 6 gives its X and an odd Y', () {
      final dest = sgnsDestination(_account(6))!;
      expect(
        bytesToHex(dest.x),
        'fff97bd5755eeea420453a14355235d382f6472f8568a18b2f057a1460297556',
      );
      expect(dest.yOdd, isTrue);
    });

    test('a missing, short, non-hex or zero-X account is refused', () {
      expect(sgnsDestination(null), isNull);
      expect(sgnsDestination('0x1234'), isNull);
      expect(sgnsDestination('0x${'zz' * 64}'), isNull);
      expect(sgnsDestination('0x${'00' * 32}${'11' * 32}'), isNull);
    });
  });

  test('the ABIs encode the selectors the diamonds expose', () {
    final five = bridgeOutFiveArgFunction.encodeCall([
      BigInt.one,
      BigInt.zero,
      BigInt.two,
      Uint8List(32),
      false,
    ]);
    final three = bridgeOutThreeArgFunction.encodeCall([
      BigInt.one,
      BigInt.zero,
      BigInt.two,
    ]);
    expect('0x${bytesToHex(five.sublist(0, 4))}', _fiveArg);
    expect('0x${bytesToHex(three.sublist(0, 4))}', _threeArg);
  });

  group('bridgeOutForm', () {
    Future<BridgeOutForm?> form(_Node node, {int chainId = 11155111}) =>
        bridgeOutForm(clientFor(node), chainId, _contract);

    test('5-arg facet only is fiveArg', () async {
      final node = await _Node.start({_fiveArg: _facet()});
      expect(await form(node), BridgeOutForm.fiveArg);
    });

    test('3-arg facet only is threeArg', () async {
      final node = await _Node.start({_threeArg: _facet()});
      expect(await form(node), BridgeOutForm.threeArg);
    });

    test('both facets prefer fiveArg', () async {
      final node = await _Node.start({_fiveArg: _facet(), _threeArg: _facet()});
      expect(await form(node), BridgeOutForm.fiveArg);
    });

    test('neither facet is null', () async {
      final node = await _Node.start({});
      expect(await form(node), isNull);
    });

    test('a definitive answer is cached per chain and contract', () async {
      final node = await _Node.start({_fiveArg: _facet()});
      await form(node);
      final asked = node.loupeCalls.length;
      final lower = EthereumAddress.fromHex(_contract.with0x.toLowerCase());
      expect(
        await bridgeOutForm(clientFor(node), 11155111, lower),
        BridgeOutForm.fiveArg,
      );
      expect(node.loupeCalls.length, asked);
      await form(node, chainId: 80002);
      expect(node.loupeCalls.length, asked + 1);
    });

    test('a failed read throws and is not cached', () async {
      final node = await _Node.start({_fiveArg: _facet()});
      node.failLoupe = true;
      await expectLater(form(node), throwsA(anything));
      node.failLoupe = false;
      expect(await form(node), BridgeOutForm.fiveArg);
    });
  });

  group('resolveBridgeOutCall', () {
    Future<ApiResponse<BridgeOutCall>> resolve(_Node node, String? account) =>
        resolveBridgeOutCall(
          client: clientFor(node),
          chainId: 11155111,
          contract: _contract,
          amount: BigInt.from(5),
          destinationChainId: 80002,
          sgnsAccount: account,
        );

    test('a 5-arg chain builds the call the node estimates', () async {
      final node = await _Node.start({_fiveArg: _facet()});
      final resp = await resolveBridgeOutCall(
        client: clientFor(node),
        chainId: 11155111,
        contract: _contract,
        amount: BigInt.from(5),
        destinationChainId: 80002,
        sgnsAccount: _account(1),
      );
      final call = resp.data!;
      expect(call.params, hasLength(5));
      expect(call.params[3], hasLength(32));
      expect(call.params[4], false);
      final client = clientFor(node);
      await client.estimateGas(
        to: _contract,
        data: call.function.encodeCall(call.params),
      );
      expect(node.estimates.single, startsWith(_fiveArg));
      expect(
        node.estimates.single,
        contains(
          '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
        ),
      );
    });

    test('a 5-arg chain refuses a missing or zero-X account', () async {
      final node = await _Node.start({_fiveArg: _facet()});
      for (final account in [null, '0x${'00' * 32}${'11' * 32}']) {
        final resp = await resolve(node, account);
        expect(resp.isSuccess, isFalse);
        expect(resp.errorMessage, bridgeAccountNotReadyMessage);
      }
    });

    test('a chain with neither form is unavailable', () async {
      final node = await _Node.start({});
      final resp = await resolve(node, _account(1));
      expect(resp.isSuccess, isFalse);
      expect(resp.errorMessage, bridgeUnavailableMessage);
    });

    test('a 3-arg chain needs no account', () async {
      final node = await _Node.start({_threeArg: _facet()});
      final resp = await resolve(node, null);
      final call = resp.data!;
      expect(call.params, hasLength(3));
      expect(
        '0x${bytesToHex(call.function.encodeCall(call.params).sublist(0, 4))}',
        _threeArg,
      );
    });

    test('a failed lookup is its own error, not unavailable', () async {
      final node = await _Node.start({_fiveArg: _facet()});
      node.failLoupe = true;
      final resp = await resolve(node, _account(1));
      expect(resp.isSuccess, isFalse);
      expect(resp.errorMessage, bridgeLookupFailedMessage);
    });
  });
}
