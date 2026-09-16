import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:web3dart/web3dart.dart';

/// The shared ERC-20 ABI is what every token read and write in the wallet is
/// encoded from. A swap needs two entries it never had — and the four that were
/// already there feed the asset list, so breaking one is not a swap bug.
ContractFunction _function(String name) =>
    Web3.abi.functions.firstWhere((f) => f.name == name);

List<String> _inputTypes(String name) =>
    _function(name).parameters.map((p) => p.type.name).toList();

List<String> _outputTypes(String name) =>
    _function(name).outputs.map((p) => p.type.name).toList();

void main() {
  group('the entries a swap adds', () {
    test('allowance takes an owner and a spender, and returns uint256', () {
      expect(_inputTypes('allowance'), ['address', 'address']);
      expect(_outputTypes('allowance'), ['uint256']);
    });

    test('approve takes a spender and a uint256 amount', () {
      expect(_inputTypes('approve'), ['address', 'uint256']);
    });

    test('both carry the canonical ERC-20 signature', () {
      expect(_function('approve').encodeName(), 'approve(address,uint256)');
      expect(_function('allowance').encodeName(), 'allowance(address,address)');
    });
  });

  group('the entries that were already there', () {
    test('name, symbol, decimals and balanceOf still resolve', () {
      expect(_outputTypes('name'), ['string']);
      expect(_outputTypes('symbol'), ['string']);
      expect(_outputTypes('decimals'), ['uint8']);
      expect(_inputTypes('balanceOf'), ['address']);
      expect(_outputTypes('balanceOf'), ['uint256']);
    });
  });
}
