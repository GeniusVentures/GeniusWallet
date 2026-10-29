// Read-only check of the burn's per-chain form against public testnets.
// Opt in with GW_SEPOLIA_CHECK=1; GW_SEPOLIA_FROM (an address holding Sepolia
// GNUS) also proves the destination slot. Nothing is signed or sent.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/bridge_out_abi.dart';
import 'package:genius_api/web3/web3.dart' show EthereumAddress;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

final _skip = Platform.environment['GW_SEPOLIA_CHECK'] == '1'
    ? false
    : 'set GW_SEPOLIA_CHECK=1 to query public testnets';

const _sepoliaRpc = 'https://ethereum-sepolia-rpc.publicnode.com';
const _amoyRpc = 'https://polygon-amoy-bor-rpc.publicnode.com';
const _baseSepoliaRpc = 'https://base-sepolia-rpc.publicnode.com';

final _sepoliaGnus = EthereumAddress.fromHex(
  '0x9af8050220D8C355CA3c6dC00a78B474cd3e3c70',
);
final _amoyGnus = EthereumAddress.fromHex(
  '0xeC20bDf2f9f77dc37Ee8313f719A3cbCFA0CD1eB',
);
final _baseSepoliaGnus = EthereumAddress.fromHex(
  '0x2BB00eB869B91F82098eb7731303A577730d5b04',
);
final _dead = EthereumAddress.fromHex(
  '0x000000000000000000000000000000000000dEaD',
);

const _destinationChain = 15305752297694;

String get _account {
  final key = Uint8List(32)..[31] = 1;
  return '0x${bytesToHex(privateKeyBytesToPublic(key))}';
}

void main() {
  setUp(resetBridgeOutFormCacheForTest);

  Web3Client clientFor(String rpc) {
    final client = Web3Client(rpc, Client());
    addTearDown(client.dispose);
    return client;
  }

  Future<BridgeOutCall> sepoliaCall(BigInt amount) async {
    final resp = await resolveBridgeOutCall(
      client: clientFor(_sepoliaRpc),
      chainId: 11155111,
      contract: _sepoliaGnus,
      amount: amount,
      destinationChainId: _destinationChain,
      sgnsAccount: _account,
    );
    expect(resp.errorMessage, isNull);
    return resp.data!;
  }

  test(
    'the loupe gives Sepolia 5-arg, Amoy 3-arg and Base Sepolia neither',
    () async {
      expect(
        await bridgeOutForm(clientFor(_sepoliaRpc), 11155111, _sepoliaGnus),
        BridgeOutForm.fiveArg,
      );
      expect(
        await bridgeOutForm(clientFor(_amoyRpc), 80002, _amoyGnus),
        BridgeOutForm.threeArg,
      );
      expect(
        await bridgeOutForm(
          clientFor(_baseSepoliaRpc),
          84532,
          _baseSepoliaGnus,
        ),
        isNull,
      );
    },
    skip: _skip,
  );

  test(
    'Sepolia accepts the 5-arg encoding and rejects the 3-arg one',
    () async {
      final call = await sepoliaCall(BigInt.zero);
      final client = clientFor(_sepoliaRpc);

      await client.callRaw(
        sender: _dead,
        contract: _sepoliaGnus,
        data: call.function.encodeCall(call.params),
      );

      final threeArg = bridgeOutThreeArgFunction.encodeCall(
        call.params.take(3).toList(),
      );
      await expectLater(
        client.callRaw(sender: _dead, contract: _sepoliaGnus, data: threeArg),
        throwsA(predicate((e) => '$e'.contains('Function does not exist'))),
      );
    },
    skip: _skip,
  );

  final holder = Platform.environment['GW_SEPOLIA_FROM'];
  test(
    'a Sepolia holder burns with the destination, and not with a zero one',
    () async {
      if (holder == null || holder.isEmpty) {
        // ignore: avoid_print
        print(
          'GW_SEPOLIA_FROM not set: destination slot not proven from a holder',
        );
        return;
      }
      final from = EthereumAddress.fromHex(holder);
      final oneGnus = BigInt.from(10).pow(18);
      final call = await sepoliaCall(oneGnus);
      final client = clientFor(_sepoliaRpc);
      final data = call.function.encodeCall(call.params);

      await client.callRaw(sender: from, contract: _sepoliaGnus, data: data);

      // Selector (4) + amount, id, chain (96), then the destination word.
      final zeroed = Uint8List.fromList(data)..fillRange(100, 132, 0);
      await expectLater(
        client.callRaw(sender: from, contract: _sepoliaGnus, data: zeroed),
        throwsA(anything),
      );
    },
    skip: _skip,
  );
}
