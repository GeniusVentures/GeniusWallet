import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';

/// The app's entire view of a swap aggregator. Squid is one implementation of
/// it; nothing above this line may name a provider's own types, so swapping
/// aggregators is a new implementation and one wiring line.
abstract interface class SwapProvider {
  /// A non-binding quote. It carries nothing signable, so it cannot move
  /// funds. Throws on a failed call — the caller owns the error copy.
  Future<SwapQuote> quote(SwapQuoteRequest request);

  /// Every token the aggregator can route on [chainId], and nothing about
  /// what this wallet holds — no aggregator publishes that. Throws on a
  /// failed call, same as [quote].
  Future<List<SwapToken>> tokens(String chainId);

  /// The same route, fetched to be EXECUTED. A quote carries nothing
  /// signable, so submitting re-fetches rather than signing what was shown.
  /// Throws when nothing signable comes back.
  Future<SwapTransaction> buildTransaction(SwapQuoteRequest request);

  /// What the aggregator says happened to [hash]. Throws when it cannot say
  /// yet — an unindexed transaction is a 404, not an answer.
  Future<SwapSettlement> status(SwapTransaction transaction, String hash);
}
