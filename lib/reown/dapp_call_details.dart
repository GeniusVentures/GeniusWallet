import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

const _kUnlimitedAllowance =
    'This approves an unlimited amount: the spender could move this token out '
    'of your wallet at any time, until you revoke it.';

const _kStandingApproval =
    'An approval stands until it is revoked -- the spender does not have to '
    'ask again.';

const _kRevocation =
    'This sets the allowance to zero: the spender will no longer be able to '
    'move this token from your wallet.';

const _kAlsoMovesNative =
    'This call moves native currency as well as a token, so both figures are '
    'below.';

const _kNativeSwapValueDisagrees =
    'The amount this swap says it spends and the value attached to the call '
    'disagree, so both figures are below. Check them on the dApp before '
    'approving.';

const _kAlsoMovesNativeApprove =
    'This call moves native currency as well as changing an allowance, so '
    'both figures are below.';

const _kUnverifiedToken =
    'GeniusWallet cannot identify this token, so the figure below is in the '
    "contract's smallest units, not a token amount.";

const _kCheckTheAddresses = 'Check the addresses below before approving.';

const _kDestinationUnreadable =
    'GeniusWallet can read what is being sent into this swap, but it cannot '
    'read which token you receive or how much of it -- neither is in the '
    'transaction. Check them on the dApp before approving.';

/// Public for the same reason [kUnreadableRequestWarning] is: this screen is
/// assembled straight from the request, with no summary to read it from.
const kUnreadableSignatureWarning =
    'GeniusWallet cannot yet show what this request would sign, so it will '
    'not sign it. This request is declined either way -- nothing on this '
    'screen approves anything.';

const kUnreadableRequestWarning =
    'GeniusWallet could not read what this request does. Approving it may '
    'move funds in ways this screen does not show.';

/// A request for a chain other than the selected one. Every address and
/// every figure below would be read against the wrong network.
String wrongChainWarning(int requested, String selectedName) =>
    'This request is for chain $requested, but '
    '${selectedName.isEmpty ? 'another network' : selectedName} is selected. '
    'Switch the wallet to that network and ask the dApp again. This request '
    'is declined either way -- nothing on this screen approves anything.';

/// A method with no handler is declined whichever button is pressed, so the
/// copy must not imply that approving does anything.
const kUnhandledMethodWarning =
    'GeniusWallet does not handle this kind of request, so it will not act '
    'on it. This request is declined either way -- nothing on this screen '
    'approves anything.';

/// What the drawer calls this transaction. Only the kinds the send body
/// refuses reach here.
String dappCallHeadline(DappCallSummary summary) {
  if (summary.kind == DappCallKind.tokenApprove) {
    return summary.isRevocation ? 'Revoke spending' : 'Approve spending';
  }
  if (summary.kind == DappCallKind.tokenTransfer) {
    return 'Token transfer';
  }
  if (summary.kind == DappCallKind.unverifiedToken) {
    return 'Token transfer (unverified)';
  }
  final router = summary.routerName;
  if (summary.kind == DappCallKind.routerSwap) {
    final amount = summary.amount;
    final symbol = summary.symbol;
    // The input side is the only side that was read, so it is the only side
    // the headline may name. An unreadable input token leaves the figure to
    // the rows, where it can be labelled as base units.
    if (router == null || amount == null || symbol == null) {
      return 'Swap via ${router ?? 'a router'}';
    }
    return 'Swapping $amount $symbol via $router';
  }
  // Naming a listed router is not a claim about the call: the warning below
  // still says this one could not be read.
  return router == null ? 'Unknown contract call' : 'Unknown call to $router';
}

/// The caution above the rows, assembled from the sentences this particular
/// call earns. Kept out of the widget so the link from decoded calldata to
/// the words on screen is a thing a test can hold.
String dappCallWarning(DappCallSummary summary) {
  final isUnknown = summary.kind == DappCallKind.unknownCall;
  final isSwap = summary.kind == DappCallKind.routerSwap;
  // A swap spending the chain's own coin has no token-in address, and both
  // of its figures are native: "as well as a token" would be untrue.
  final isNativeSwap = isSwap && summary.tokenIn == null;
  return <String>[
    if (summary.isUnlimitedAllowance) _kUnlimitedAllowance,
    if (isUnknown) kUnreadableRequestWarning,
    if (isSwap) _kDestinationUnreadable,
    // An unreadable call has no token half for the native figure to be "as
    // well as", so that sentence would name a reading nobody made.
    if (!isUnknown && summary.nativeAmount != null)
      isNativeSwap
          ? _kNativeSwapValueDisagrees
          : summary.spender != null
          ? _kAlsoMovesNativeApprove
          : _kAlsoMovesNative,
    if (summary.kind == DappCallKind.unverifiedToken ||
        (isSwap && summary.symbol == null))
      _kUnverifiedToken,
    if (summary.isRevocation) _kRevocation,
    if (summary.spender != null && !summary.isRevocation) _kStandingApproval,
    _kCheckTheAddresses,
  ].join(' ');
}

/// The rows for [summary], in reading order; addresses are copyable so the
/// full value reaches the clipboard. [from] and the gas figures come from the
/// transaction, [networkName] and [nativeSymbol] from the wallet.
List<DappCallRow> dappCallRows(
  DappCallSummary summary, {
  String? from,
  String? networkName,
  String? nativeSymbol,
  String? gasFee,
  String? maxFeePerGas,
  String? priorityFee,
}) {
  final figure = summary.allowance ?? summary.amount;
  final symbol = summary.symbol;
  final native = summary.nativeAmount;
  final isUnknown = summary.kind == DappCallKind.unknownCall;
  String inNative(String amount) => nativeSymbol == null || nativeSymbol.isEmpty
      ? amount
      : '$amount $nativeSymbol';
  // First on every kind: the account the call is made from is the one thing
  // a user can check against the wallet they have selected.
  final fromRows = <DappCallRow>[
    if (from != null && from.isNotEmpty)
      DappCallRow(label: 'From', value: from, copyable: true),
  ];
  final gasRows = <DappCallRow>[
    if (gasFee != null) DappCallRow(label: 'Gas Fee', value: inNative(gasFee)),
    if (maxFeePerGas != null)
      DappCallRow(label: 'Max Fee Per Gas', value: inNative(maxFeePerGas)),
    if (priorityFee != null)
      DappCallRow(label: 'Priority Fee', value: inNative(priorityFee)),
  ];
  // A swap names the router it goes through and the token it spends, which
  // are two different addresses. Every other kind has only one, so this is
  // its own short list rather than a third label variant below.
  if (summary.kind == DappCallKind.routerSwap) {
    return <DappCallRow>[
      ...fromRows,
      if (summary.tokenContract != null)
        DappCallRow(
          label: 'Router',
          value: summary.tokenContract!,
          copyable: true,
        ),
      if (summary.tokenIn != null)
        DappCallRow(label: 'Token in', value: summary.tokenIn!, copyable: true),
      if (figure != null)
        DappCallRow(
          label: symbol == null ? 'Amount in (smallest units)' : 'Amount in',
          value: symbol == null ? figure : '$figure $symbol',
        ),
      if (native != null)
        DappCallRow(label: 'Also sending', value: inNative(native)),
      ...gasRows,
      if (networkName != null && networkName.isNotEmpty)
        DappCallRow(label: 'Network', value: networkName),
    ];
  }
  return <DappCallRow>[
    ...fromRows,
    if (summary.spender != null)
      DappCallRow(label: 'Spender', value: summary.spender!, copyable: true),
    if (summary.recipient != null)
      DappCallRow(
        label: 'Recipient',
        value: summary.recipient!,
        copyable: true,
      ),
    if (summary.tokenContract != null)
      DappCallRow(
        // Nothing identified it as a token, so naming it one would be the
        // reading this call did not get. A listed address is still named for
        // what it is, which is all the allow-list ever claims.
        label: isUnknown
            ? (summary.routerName == null ? 'Contract' : 'Router')
            : 'Token',
        value: summary.tokenContract!,
        copyable: true,
      ),
    if (figure != null)
      DappCallRow(
        label: symbol == null ? 'Amount (smallest units)' : 'Amount',
        value: symbol == null ? figure : '$figure $symbol',
      ),
    if (native != null)
      DappCallRow(
        label: isUnknown ? 'Value' : 'Also sending',
        value: inNative(native),
      ),
    ...gasRows,
    if (summary.selector != null)
      DappCallRow(label: 'Method', value: summary.selector!),
    if (networkName != null && networkName.isNotEmpty)
      DappCallRow(label: 'Network', value: networkName),
  ];
}

/// One line of [DappCallDetails]. Mark [copyable] for a value the user needs
/// whole -- an address -- so the full string reaches the clipboard even though
/// the row draws a shortened form.
class DappCallRow {
  const DappCallRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;
}

/// Drawer body for a call that is not a plain send. It carries no amount hero
/// and no "You send" row: those assert a figure leaves the wallet, which an
/// approval does not do and an unidentifiable token cannot promise.
class DappCallDetails extends StatelessWidget {
  const DappCallDetails({
    super.key,
    required this.headline,
    required this.warning,
    required this.rows,
  });

  final String headline;
  final String warning;
  final List<DappCallRow> rows;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          headline,
          textAlign: TextAlign.center,
          style: GeniusWalletTypography.titleMd.copyWith(color: gw.textPrimary),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        GWWarningNote(warning),
        // The heading travels with its rows: a "Details" label over an empty
        // well is a frame around nothing.
        if (rows.isNotEmpty) ...[
          const SizedBox(height: GeniusWalletConsts.space10),
          const GWKicker('Details'),
          const SizedBox(height: GeniusWalletConsts.space4),
          GWDetailGrid(
            rows: [
              for (final row in rows)
                if (row.copyable)
                  GWCopyRow(label: row.label, value: row.value)
                else
                  _PlainDetailRow(label: row.label, value: row.value),
            ],
          ),
        ],
      ],
    );
  }
}

/// A plain label/value row, kept as a small [StatelessWidget] rather than a
/// `_buildFoo()` helper method. Duplicated from the send body rather than
/// exported from it -- a shared row is not worth coupling the two bodies.
class _PlainDetailRow extends StatelessWidget {
  const _PlainDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return Padding(
      padding: kGWDetailRowPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flexible on BOTH sides: a long label beside a long value is how
          // this row overflowed, and a clipped word beats a striped bar.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textPrimary70,
              ),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space3),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
