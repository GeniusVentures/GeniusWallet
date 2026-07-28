import 'package:genius_wallet/squid_router/held_tokens.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';

/// Which side of the swap a preselected coin lands on.
///
/// `pay` means the user is spending the coin; `receive` means acquiring it.
enum PreselectSide { pay, receive }

/// The outcome of resolving a coin page's Swap button into a seated token.
class Preselection {
  const Preselection(this.token, this.side);

  final SquidTokenInfo token;
  final PreselectSide side;
}

/// Resolves the coin a user tapped Swap on into a token to seat, and the side
/// to seat it on. Returns null when nothing should be seated.
///
/// **Why a side has to be decided at all.** The pay side is filtered to
/// holdings (`heldTokens`) because you cannot spend a coin you do not have.
/// Seating an unheld coin as "You Pay" would put back exactly what that filter
/// removes — the user would arrive at a form whose CTA can only ever say
/// "Insufficient balance". So:
///
/// * **held → [PreselectSide.pay]** — you are spending it
/// * **not held → [PreselectSide.receive]** — you are acquiring it
///
/// Both are honest readings of "swap this coin"; which one applies is decided
/// by what the wallet can actually do rather than guessed.
///
/// **Why it can return null.** The catalogue is `mockTokens` today (13
/// entries), so many real coins — GNUS among them — have no match. Seating a
/// neighbouring token would be worse than an empty form, because the user has
/// to notice the wrong one before they can correct it.
///
/// [chainId] is a *preference*, not a filter: the same symbol legitimately
/// exists on several chains (ETH on 1, 137 and 80001), so it disambiguates
/// when it can and is ignored when it matches nothing.
Preselection? resolvePreselection({
  required List<SquidTokenInfo> tokens,
  required String? symbol,
  int? chainId,
}) {
  final wanted = symbol?.trim();
  if (wanted == null || wanted.isEmpty) return null;

  final matches = tokens
      .where((t) => t.symbol.toLowerCase() == wanted.toLowerCase())
      .toList();
  if (matches.isEmpty) return null;

  SquidTokenInfo? pick;

  // 1. The requested chain, when the catalogue has it.
  if (chainId != null) {
    for (final t in matches) {
      if (t.chainId == chainId) {
        pick = t;
        break;
      }
    }
  }

  // 2. Otherwise any chain the wallet actually holds it on — a held match is
  //    strictly more useful than an unheld one, because it can seat on the pay
  //    side and is immediately spendable.
  pick ??= matches.firstWhere(hasSpendableBalance, orElse: () => matches.first);

  return Preselection(
    pick,
    hasSpendableBalance(pick) ? PreselectSide.pay : PreselectSide.receive,
  );
}
