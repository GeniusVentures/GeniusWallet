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

const _kAlsoMovesNative =
    'This call moves native currency as well as a token, so both figures are '
    'below.';

const _kUnverifiedToken =
    'GeniusWallet cannot identify this token, so the figure below is in the '
    "contract's smallest units, not a token amount.";

const _kCheckTheAddresses = 'Check the addresses below before approving.';

/// What the drawer calls this transaction. Only the kinds the send body
/// refuses reach here.
String dappCallHeadline(DappCallSummary summary) {
  if (summary.kind == DappCallKind.tokenApprove) {
    return 'Approve spending';
  }
  if (summary.kind == DappCallKind.unverifiedToken) {
    return summary.spender != null
        ? 'Token approval (unverified)'
        : 'Token transfer (unverified)';
  }
  return 'Contract call';
}

/// The caution above the rows, assembled from the sentences this particular
/// call earns. Kept out of the widget so the link from decoded calldata to
/// the words on screen is a thing a test can hold.
String dappCallWarning(DappCallSummary summary) => <String>[
  if (summary.isUnlimitedAllowance) _kUnlimitedAllowance,
  if (summary.nativeAmount != null) _kAlsoMovesNative,
  if (summary.kind == DappCallKind.unverifiedToken) _kUnverifiedToken,
  if (summary.spender != null) _kStandingApproval,
  _kCheckTheAddresses,
].join(' ');

/// The rows for [summary], in reading order. Addresses are copyable so the
/// full value reaches the clipboard; [networkName] and [nativeSymbol] come
/// from the wallet, not from the transaction.
List<DappCallRow> dappCallRows(
  DappCallSummary summary, {
  String? networkName,
  String? nativeSymbol,
}) {
  final figure = summary.allowance ?? summary.amount;
  final symbol = summary.symbol;
  final native = summary.nativeAmount;
  return <DappCallRow>[
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
        label: 'Token',
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
        label: 'Also sending',
        value: nativeSymbol == null || nativeSymbol.isEmpty
            ? native
            : '$native $nativeSymbol',
      ),
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
          Text(
            label,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textPrimary70,
            ),
          ),
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
