import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_escrow_release_item.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_item.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_purchased_item.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_swapped_item.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
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
        final matchesSGNUS = !(widget.isShowOnlySGNUSTransactions ?? false) ||
            (tx.isSGNUS ?? false);

        return matchesFilter && matchesSGNUS;
      }).toList();

  @override
  void didChangeMetrics() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final txs = filteredTransactions;
    final textScale = MediaQuery.textScalerOf(context).scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionFilters(
          selected: selectedFilter,
          onChanged: (f) => setState(() => selectedFilter = f),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: txs.length,
            itemBuilder: (_, i) => switch (txs[i].type) {
              TransactionType.purchase => TransactionPurchasedItem(tx: txs[i]),
              TransactionType.escrowRelease =>
                TransactionEscrowReleaseItem(tx: txs[i]),
              TransactionType.swap => TransactionSwappedItem(tx: txs[i]),
              _ => TransactionItem(tx: txs[i]),
            },
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AutoSizeText(
            "Transactions: ${txs.length}",
            maxLines: 1,
            style: TextStyle(
              fontSize: textScale(16),
              color: GeniusWalletColors.gray500,
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionFilters extends StatelessWidget {
  final Filters selected;
  final ValueChanged<Filters> onChanged;

  const TransactionFilters({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AutoSizeText(
              'Transactions',
              maxLines: 1,
              style: TextStyle(
                fontSize: GeniusWalletFontSize.sectionHeader,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (isMobile) _MobileFilters(selected, onChanged),
          ],
        ),
        if (!isMobile) ...[
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                for (final filter in Filters.values)
                  _FilterButton(
                    filter: filter,
                    selected: selected == filter,
                    onTap: () => onChanged(
                      selected == filter ? Filters.all : filter,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MobileFilters extends StatelessWidget {
  final Filters selected;
  final ValueChanged<Filters> onChanged;

  const _MobileFilters(this.selected, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final applied = selected != Filters.all;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.filter_list, size: 30),
          color: applied
              ? GeniusWalletColors.lightGreenPrimary
              : GeniusWalletColors.white,
          onPressed: () => ResponsiveDrawer.show<void>(
            context: context,
            title: "Filters",
            children: [
              for (final filter in Filters.values)
                _HoverableFilterItem(
                  filter: filter,
                  selected: selected == filter,
                  onTap: () {
                    onChanged(filter);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
        if (applied)
          const Positioned(
            right: 8,
            top: 8,
            child: _FilterDot(),
          ),
      ],
    );
  }
}

class _HoverableFilterItem extends StatefulWidget {
  final Filters filter;
  final bool selected;
  final VoidCallback onTap;

  const _HoverableFilterItem({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_HoverableFilterItem> createState() => _HoverableFilterItemState();
}

class _HoverableFilterItemState extends State<_HoverableFilterItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: hovered
              ? GeniusWalletColors.lightGreenPrimary.withAlpha(26)
              : Colors.transparent,
        ),
        child: ListTile(
          onTap: widget.onTap,
          title: Text(
            widget.filter.label,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: widget.selected
              ? const Icon(
                  Icons.check,
                  color: GeniusWalletColors.lightGreenPrimary,
                )
              : null,
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final Filters filter;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? GeniusWalletColors.btnFilterSelected
        : GeniusWalletColors.btnFilter;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: color),
        ),
      ),
      child: Text(
        filter.label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _FilterDot extends StatelessWidget {
  const _FilterDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: GeniusWalletColors.lightGreenPrimary,
      ),
    );
  }
}
