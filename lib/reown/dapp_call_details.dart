import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

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

/// Drawer body for a transaction that is NOT a plain send: it says what could
/// be read of the calldata and warns about what could not. Every string
/// arrives already decoded and formatted -- no arithmetic happens here.
///
/// There is no amount hero and no "You send" row on purpose. Those assert that
/// a figure leaves the wallet, which is false of an approval and unknowable of
/// a token this wallet cannot identify.
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
