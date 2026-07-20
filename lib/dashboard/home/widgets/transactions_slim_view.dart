import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

enum Filters {
  all("All"),
  sent("Sent"),
  received("Received"),
  escrow("Escrow"),
  mint("Mint");

  final String label;
  const Filters(this.label);

  bool matches(Transaction tx) => switch (this) {
    all => true,
    sent => tx.transactionDirection == TransactionDirection.sent,
    received => tx.transactionDirection == TransactionDirection.received,
    mint => tx.type == TransactionType.mint,
    escrow => {
      TransactionType.escrow,
      TransactionType.escrowRelease,
    }.contains(tx.type),
  };
}

class TransactionsSlimView extends StatefulWidget {
  final List<Transaction> transactions;
  final bool? isShowOnlySGNUSTransactions;

  const TransactionsSlimView({
    super.key,
    required this.transactions,
    this.isShowOnlySGNUSTransactions,
  });

  @override
  State<TransactionsSlimView> createState() => _TransactionsSlimViewState();
}

class _TransactionsSlimViewState extends State<TransactionsSlimView>
    with WidgetsBindingObserver {
  Filters selectedFilter = Filters.all;

  List<Transaction> get filteredTransactions => widget.transactions.where((tx) {
    final matchesFilter = selectedFilter.matches(tx);
    final matchesSGNUS =
        !(widget.isShowOnlySGNUSTransactions ?? false) || (tx.isSGNUS ?? false);

    return matchesFilter && matchesSGNUS;
  }).toList();

  @override
  void didChangeMetrics() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final txs = filteredTransactions;
    final textScale = MediaQuery.textScalerOf(context).scale;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: GeniusBreakpoints.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        children: [
          Text(
            'Transactions',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SegmentedButton<Filters>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: GeniusWalletColors.brandPrimary,
              selectedForegroundColor: GeniusWalletColors.textOnBrand,
            ),
            segments: Filters.values
                .where((f) => f != Filters.all)
                .map(
                  (filter) => ButtonSegment<Filters>(
                    value: filter,
                    label: Text(filter.label),
                  ),
                )
                .toList(),
            selected: selectedFilter == Filters.all
                ? <Filters>{}
                : {selectedFilter},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (Set<Filters> newSelection) {
              setState(
                () => selectedFilter = newSelection.isEmpty
                    ? Filters.all
                    : newSelection.first,
              );
            },
          ),
          Expanded(
            child: txs.isEmpty
                ? const GWEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    message:
                        'Your sends, receives and swaps will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: GeniusWalletConsts.space6,
                      horizontal: GeniusWalletConsts.space2,
                    ),
                    itemCount: txs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: GeniusWalletConsts.space6),
                    itemBuilder: (_, i) => switch (txs[i].type) {
                      TransactionType.purchase => TransactionPurchasedItem(
                        tx: txs[i],
                      ),
                      TransactionType.escrowRelease =>
                        TransactionEscrowReleaseItem(tx: txs[i]),
                      TransactionType.swap => TransactionSwappedItem(
                        tx: txs[i],
                      ),
                      _ => TransactionItem(tx: txs[i]),
                    },
                  ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: AutoSizeText(
              "Transactions: ${txs.length}",
              maxLines: 1,
              style: GeniusWalletTypography.labelMd.copyWith(
                fontSize: textScale(GeniusWalletTypography.labelMd.fontSize!),
                color: gw.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
