import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/swap/swap_token.dart';

/// The live walk. Skipped without an integrator ID, so a plain `flutter test`
/// stays credential-free and offline. Run it with:
///   flutter test test/swap/live_catalogue_walk_test.dart --dart-define-from-file=squid.local.json

const _base = '8453';
const _gnusOnBase = '0x614577036F0a024DBC1C88BA616b394DD65d105a';

void main() {
  test(
    'the catalogue is the network answering, filtered to one chain',
    () async {
      const provider = SquidSwapProvider();

      final onBase = await provider.tokens(_base);

      // The fabricated list held 13 entries across nine chains and no GNUS.
      expect(onBase, isNotEmpty);
      expect(onBase.every((t) => t.chainId == _base), isTrue);

      final gnus = onBase.firstWhere(
        (t) => t.address.toLowerCase() == _gnusOnBase.toLowerCase(),
      );
      // One provider researched for this phase reports 16 for GNUS on BNB.
      // Squid is right today; this is the assertion that notices if it stops.
      expect(gnus.decimals, 18);
      expect(gnus.symbol, 'GNUS');

      // Nothing the catalogue hands back carries a balance: no aggregator
      // knows what this wallet holds, and a zero here would read as one.
      expect(onBase.every((t) => t.rawBalance == null), isTrue);
      expect(onBase.every((t) => isPlausibleDecimals(t.decimals)), isTrue);

      // A second read must not spend a second request against the 1 RPS tier.
      final again = await provider.tokens(_base);
      expect(again.length, onBase.length);
    },
    skip: squidConfigured ? false : 'no integrator ID in this build',
  );
}
