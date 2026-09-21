import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/web3.dart';

/// A rejected or failed approval has to be able to say why. The bridge write
/// this one is modelled on builds its error and never returns it, so every
/// failure there reads as one generic string — these cases pin that the
/// approval path does not inherit that.
void main() {
  group('approve returns its own error', () {
    test(
      'a malformed token address reports itself, before any key is read',
      () async {
        await expectLater(
          Web3().approve(
            contractAddress: 'not-an-address',
            rpcUrl: 'http://127.0.0.1:1',
            wallet: null,
            spender: '0xce16F69375520ab01377ce7B88f5BA8C48F8D666',
            amount: BigInt.from(1000000),
            chainId: 8453,
          ),
          completion(
            isA<ApiResponse<String>>()
                .having((r) => r.isSuccess, 'isSuccess', isFalse)
                .having(
                  (r) => r.errorMessage,
                  'errorMessage',
                  allOf(isNotNull, isNot(contains('unknown'))),
                ),
          ),
        );
      },
    );

    test('a wallet with no key says so rather than failing silently', () async {
      await expectLater(
        Web3().approve(
          contractAddress: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
          rpcUrl: 'http://127.0.0.1:1',
          wallet: null,
          spender: '0xce16F69375520ab01377ce7B88f5BA8C48F8D666',
          amount: BigInt.from(1000000),
          chainId: 8453,
        ),
        completion(
          isA<ApiResponse<String>>()
              .having((r) => r.isSuccess, 'isSuccess', isFalse)
              .having(
                (r) => r.errorMessage,
                'errorMessage',
                'No signing key found for this wallet',
              ),
        ),
      );
    });
  });
}
