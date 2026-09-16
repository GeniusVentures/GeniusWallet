import 'package:genius_wallet/swap/swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';

/// A [SwapProvider] that answers nothing. Cases override only the one call
/// they exercise; every other call throws rather than returning a plausible
/// blank, so a test that reaches one by accident fails loudly.
///
/// Shared because three files needed it the moment the boundary grew a fourth
/// method — below that, duplication would have been cheaper.
abstract class FakeSwapProvider implements SwapProvider {
  const FakeSwapProvider();

  @override
  Future<List<SwapToken>> tokens(String chainId) async => const [];

  @override
  Future<SwapQuote> quote(SwapQuoteRequest request) =>
      throw UnimplementedError('this case does not fetch a quote');

  @override
  Future<SwapTransaction> buildTransaction(SwapQuoteRequest request) =>
      throw UnimplementedError('this case does not execute a swap');

  @override
  Future<SwapSettlement> status(SwapTransaction transaction, String hash) =>
      throw UnimplementedError('this case does not poll a status');
}
