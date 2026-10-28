import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:genius_api/src/genius_api.dart' show sdkAddressOrNull;
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/web3.dart' show rpcReadTimeout;
import 'package:wallet/wallet.dart' show EthereumAddress;
import 'package:web3dart/web3dart.dart';

/// The `bridgeOut` signature a chain's GNUS diamond has deployed.
enum BridgeOutForm { fiveArg, threeArg }

const bridgeOutFiveArgSelector = '0xa5a5aa20';
const bridgeOutThreeArgSelector = '0xe26d65a6';

const bridgeUnavailableMessage =
    'GNUS bridging is not available on this network.';
const bridgeAccountNotReadyMessage =
    'Your Genius account is not ready. Try again in a moment.';
const bridgeLookupFailedMessage =
    "Could not check this network's bridge. Try again.";
const bridgeCreditFailedMessage =
    'The GNUS left this network but was not credited to your Genius account.';

/// Whether the wallet itself must credit a confirmed burn on SuperGenius. The
/// relayer mints from the 5-arg event to `sgnsDestination`; nothing picks up
/// the 3-arg `BridgeSourceBurned`, so there the wallet mints.
// ponytail: relies on the relayer ignoring 3-arg events, and SuperGenius
// cross-node mint dedup is unconfirmed (wallet and relayer key a mint on
// different chain ids). If the relayer starts handling 3-arg burns, this
// must return false for both forms or the burn is credited twice.
bool walletCreditsBurn(BridgeOutForm form) => form == BridgeOutForm.threeArg;

final _fiveArgAbi = ContractAbi.fromJson('''
  [
    {
      "inputs": [
        { "internalType": "uint256", "name": "amount", "type": "uint256" },
        { "internalType": "uint256", "name": "id", "type": "uint256" },
        { "internalType": "uint256", "name": "destChainID", "type": "uint256" },
        { "internalType": "bytes32", "name": "sgnsDestination", "type": "bytes32" },
        { "internalType": "bool", "name": "destinationYOdd", "type": "bool" }
      ],
      "name": "bridgeOut",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ]
''', '');

final _threeArgAbi = ContractAbi.fromJson('''
  [
    {
      "inputs": [
        { "internalType": "uint256", "name": "amount", "type": "uint256" },
        { "internalType": "uint256", "name": "id", "type": "uint256" },
        { "internalType": "uint256", "name": "destChainID", "type": "uint256" }
      ],
      "name": "bridgeOut",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ]
''', '');

final _loupeAbi = ContractAbi.fromJson('''
  [
    {
      "inputs": [{ "internalType": "bytes4", "name": "_functionSelector", "type": "bytes4" }],
      "name": "facetAddress",
      "outputs": [{ "internalType": "address", "name": "facetAddress_", "type": "address" }],
      "stateMutability": "view",
      "type": "function"
    }
  ]
''', '');

final bridgeOutFiveArgFunction = _fiveArgAbi.functions.first;
final bridgeOutThreeArgFunction = _threeArgAbi.functions.first;

// ponytail: session cache, no invalidation. A diamond upgrade mid-session
// needs a restart; a removed facet makes the gas estimate revert before signing.
final _forms = <String, BridgeOutForm?>{};

@visibleForTesting
void resetBridgeOutFormCacheForTest() => _forms.clear();

/// Which `bridgeOut` [contract] has on [chainId], read from the diamond
/// loupe: the 5-argument form when present, else the 3-argument one, else
/// null. Only a definitive answer is cached; a failed read throws.
Future<BridgeOutForm?> bridgeOutForm(
  Web3Client client,
  int chainId,
  EthereumAddress contract,
) async {
  final key = '$chainId|${contract.with0x}';
  if (_forms.containsKey(key)) {
    return _forms[key];
  }
  final loupe = DeployedContract(_loupeAbi, contract);
  Future<bool> hasFacet(String selector) async {
    final result = await client
        .call(
          contract: loupe,
          function: loupe.function('facetAddress'),
          params: [hexToBytes(selector)],
        )
        .timeout(rpcReadTimeout);
    return (result.first as EthereumAddress).value.any((b) => b != 0);
  }

  final BridgeOutForm? form;
  if (await hasFacet(bridgeOutFiveArgSelector)) {
    form = BridgeOutForm.fiveArg;
  } else if (await hasFacet(bridgeOutThreeArgSelector)) {
    form = BridgeOutForm.threeArg;
  } else {
    form = null;
  }
  return _forms[key] = form;
}

/// The burn's destination word: X of the SDK [account] (`0x` + X||Y, 128 hex)
/// and the parity of Y. Null for a missing, malformed or zero-X account.
({Uint8List x, bool yOdd})? sgnsDestination(String? account) {
  final valid = account == null ? null : sdkAddressOrNull(account);
  if (valid == null) {
    return null;
  }
  final bytes = hexToBytes(valid);
  final x = Uint8List.fromList(bytes.sublist(0, 32));
  if (x.every((b) => b == 0)) {
    return null;
  }
  return (x: x, yOdd: bytes.last.isOdd);
}

typedef BridgeOutCall = ({
  BridgeOutForm form,
  DeployedContract contract,
  ContractFunction function,
  List<Object> params,
});

/// The burn's call for [contract] in the form its chain has, used for both
/// the gas estimate and the signed transaction. An error means nothing may be
/// signed: no bridge here, no usable [sgnsAccount] for the 5-arg form, or the
/// form could not be read.
Future<ApiResponse<BridgeOutCall>> resolveBridgeOutCall({
  required Web3Client client,
  required int chainId,
  required EthereumAddress contract,
  required BigInt amount,
  required int destinationChainId,
  String? sgnsAccount,
}) async {
  final BridgeOutForm? form;
  try {
    form = await bridgeOutForm(client, chainId, contract);
  } catch (_) {
    return ApiResponse.error(bridgeLookupFailedMessage);
  }
  // Token id stays 0.
  final head = [amount, BigInt.zero, BigInt.from(destinationChainId)];
  switch (form) {
    case null:
      return ApiResponse.error(bridgeUnavailableMessage);
    case BridgeOutForm.threeArg:
      return ApiResponse.success((
        form: BridgeOutForm.threeArg,
        contract: DeployedContract(_threeArgAbi, contract),
        function: bridgeOutThreeArgFunction,
        params: head,
      ));
    case BridgeOutForm.fiveArg:
      final dest = sgnsDestination(sgnsAccount);
      if (dest == null) {
        return ApiResponse.error(bridgeAccountNotReadyMessage);
      }
      return ApiResponse.success((
        form: BridgeOutForm.fiveArg,
        contract: DeployedContract(_fiveArgAbi, contract),
        function: bridgeOutFiveArgFunction,
        params: [...head, dest.x, dest.yOdd],
      ));
  }
}
