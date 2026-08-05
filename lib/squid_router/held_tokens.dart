import 'package:genius_wallet/squid_router/models/squid_token_info.dart';

/// The "You Pay" side of a swap may only offer what the wallet can actually
/// spend.
///
/// Decided by Braian at the 08-07 walk (2026-07-27): *"a user can't simply swap
/// a BNB he does not have."* Before this, both pickers listed the entire Squid
/// catalogue, so the pay side offered tokens whose dead end only surfaced at the
/// CTA — after picking a token AND typing an amount.
///
/// **Pay side only.** The "You Receive" side keeps the full catalogue: filtering
/// it to holdings would make it impossible to swap INTO a token you don't
/// already own, which is most of the point of a swap. That asymmetry is the
/// decision, not an oversight.
///
/// Kept as a free function on purpose — the same shape as `swap_cta_state.dart`
/// and `slippage_state.dart`, so the rule is unit-testable without pumping a
/// widget or standing up a wallet.
List<SquidTokenInfo> heldTokens(List<SquidTokenInfo> tokens) =>
    tokens.where(hasSpendableBalance).toList();

/// Whether [token] carries a balance greater than zero.
///
/// Reads the RAW balance string rather than [SquidBalance.amountAsDouble]. Two
/// reasons, both deliberate:
///
/// * **It cannot throw.** `amountAsDouble` bang-unwraps `double.tryParse`, so a
///   malformed balance takes the whole picker down with it. A filter is the
///   wrong place to discover that.
/// * **Decimals are irrelevant to the question.** `decimals` only scales the
///   value; it can never turn a non-zero raw amount into zero, nor the reverse.
///   Dust below the display floor is still spendable and still listed — the
///   picker renders it as `<0.000001` rather than hiding it.
///
/// A balance that will not parse is treated as NOT spendable. That is the
/// conservative read of ambiguous data for a spend affordance, and it fails
/// visibly (a token missing from the list, which a person will report) rather
/// than silently seating an unspendable token on the pay side. If real Squid
/// data ever returns a shape this rejects, fix the parse — do not loosen this.
bool hasSpendableBalance(SquidTokenInfo token) {
  final balance = token.balance;
  if (balance == null) {
    return false;
  }
  final raw = double.tryParse(balance.balance);
  if (raw == null) {
    return false;
  }
  return raw > 0;
}
