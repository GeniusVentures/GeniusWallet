import 'package:genius_wallet/swap/swap_token.dart';

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
List<SwapToken> heldTokens(List<SwapToken> tokens) =>
    tokens.where(hasSpendableBalance).toList();

/// Whether [token] carries a balance greater than zero.
///
/// An ABSENT balance is not spendable — the conservative read of a holding
/// that never arrived. Dust below the display floor is: it is real, and the
/// picker already renders it as `<0.000001` rather than hiding it.
bool hasSpendableBalance(SwapToken token) {
  final raw = token.rawBalance;
  if (raw == null) {
    return false;
  }
  return raw > BigInt.zero;
}
