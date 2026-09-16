/// Whether a router contract may already spend the pay token, and if not, for
/// how much it should be approved. Pure Dart — no client, no Flutter, the same
/// shape as `swap_cta_state.dart` and `held_tokens.dart`.
sealed class ApprovalDecision {
  const ApprovalDecision._();
}

/// The pay token is the chain's native coin; it is sent, not approved.
class ApprovalNotRequired extends ApprovalDecision {
  const ApprovalNotRequired._() : super._();
}

/// The spender already holds an allowance covering the amount — no call.
class AllowanceSufficient extends ApprovalDecision {
  const AllowanceSufficient._() : super._();
}

/// An approval for exactly [amount] raw base units.
///
/// The constructor is private and [decideApproval] is its only caller, which
/// passes the swap amount through. An unlimited approval is unreachable.
class ApproveExactAmount extends ApprovalDecision {
  const ApproveExactAmount._(this.amount) : super._();

  final BigInt amount;
}

/// The two addresses that mean "this chain's native coin" rather than a
/// contract: the all-zero address, and Squid's 0xEeee… sentinel.
const _nativeAddresses = {
  '0x0000000000000000000000000000000000000000',
  '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
};

/// Decides whether [tokenAddress] needs an approval before [amount] can move.
///
/// [allowance] and [amount] are both RAW base units — the unit a route's
/// fromAmount arrives in. A scaled double on either side is off by 10^decimals.
ApprovalDecision decideApproval({
  required String tokenAddress,
  required BigInt allowance,
  required BigInt amount,
}) {
  if (_nativeAddresses.contains(tokenAddress.trim().toLowerCase())) {
    return const ApprovalNotRequired._();
  }
  if (allowance >= amount) {
    return const AllowanceSufficient._();
  }
  return ApproveExactAmount._(amount);
}
