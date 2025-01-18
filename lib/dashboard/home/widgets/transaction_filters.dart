import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';

final filters = ['All', 'Sent', 'Received', 'Escrow', 'Mint'];

class TransactionFilters extends StatefulWidget {
  final Function(String) onFilterSelected;
  const TransactionFilters({Key? key, required this.onFilterSelected})
      : super(key: key);

  @override
  TransactionFiltersState createState() => TransactionFiltersState();
}

class TransactionFiltersState extends State<TransactionFilters> {
  String? _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isFilterApplied = _selectedFilter != 'All';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AutoSizeText(
              'Transactions',
              maxLines: 1,
              style: TextStyle(
                fontSize: GeniusWalletFontSize.sectionHeader,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isMobile)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 30),
                    color: isFilterApplied
                        ? GeniusWalletColors.lightGreenPrimary
                        : GeniusWalletColors.white,
                    onPressed: () {
                      _showFilterDrawer(context);
                    },
                  ),
                  if (isFilterApplied)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: GeniusWalletColors.lightGreenPrimary,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
        if (!isMobile)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: filters.map((filter) {
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    widget.onFilterSelected(filter);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GeniusWalletColors.btnFilterSelectedBlue
                          : GeniusWalletColors.btnFilterBlue,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isSelected
                            ? GeniusWalletColors.btnFilterSelectedBlue
                            : GeniusWalletColors.btnFilterBlue,
                      ),
                    ),
                    child: AutoSizeText(
                      filter,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showFilterDrawer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Close when tapping outside
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(), // Close on tap outside
        child: Material(
          color: Colors.black.withOpacity(0.5), // Backdrop
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              color: GeniusWalletColors.deepBlueMenu,
              child: GestureDetector(
                onTap: () {}, // Prevent close when tapping the drawer
                child: FilterDrawer(
                  selectedFilter: _selectedFilter,
                  onFilterSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    widget.onFilterSelected(filter);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterDrawer extends StatelessWidget {
  final String? selectedFilter;
  final Function(String) onFilterSelected;

  const FilterDrawer({
    Key? key,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const Divider(color: Colors.white),
          const SizedBox(height: 16),
          Column(
            children: filters.map((filter) {
              final isSelected = filter == selectedFilter;
              return ListTile(
                onTap: () {
                  onFilterSelected(filter);
                },
                title: Text(
                  filter,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check,
                        color: GeniusWalletColors.lightGreenPrimary,
                      )
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
