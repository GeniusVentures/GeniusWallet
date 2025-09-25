import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';

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
            const Center(
                child: AutoSizeText(
              'Transactions',
              maxLines: 1,
              style: TextStyle(
                  fontSize: GeniusWalletFontSize.sectionHeader,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )),
            if (isMobile)
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      ResponsiveDrawer.show<void>(
                        context: context,
                        title: "Filters",
                        children: filters.map((filter) {
                          return HoverableFilterItem(
                            filter: filter,
                            isSelected: filter == _selectedFilter,
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                              widget.onFilterSelected(filter);
                              Navigator.of(context)
                                  .pop(); // Close drawer after selection
                            },
                          );
                        }).toList(),
                      );
                    },
                    icon: const Icon(Icons.filter_list, size: 30),
                    color: isFilterApplied
                        ? GeniusWalletColors.lightGreenPrimary
                        : GeniusWalletColors.white,
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

        /// **Desktop: Horizontal Filter Buttons**
        if (!isMobile) ...[
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterButton(
                    filter: filter,
                    isSelected: filter == _selectedFilter,
                    onTap: () {
                      setState(() {
                        // If the selected filter is clicked again, reset to "All"
                        _selectedFilter =
                            (_selectedFilter == filter) ? 'All' : filter;
                      });
                      widget.onFilterSelected(_selectedFilter!);
                    },
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ],
    );
  }
}

/// **📌 Reusable `HoverableFilterItem` for Drawer**
class HoverableFilterItem extends StatefulWidget {
  final String filter;
  final bool isSelected;
  final VoidCallback onTap;

  const HoverableFilterItem({
    Key? key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  HoverableFilterItemState createState() => HoverableFilterItemState();
}

class HoverableFilterItemState extends State<HoverableFilterItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isHovered
              ? GeniusWalletColors.lightGreenPrimary.withAlpha(26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: widget.onTap,
          title: Text(
            widget.filter,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          trailing: widget.isSelected
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

class FilterButton extends StatelessWidget {
  final String filter;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    Key? key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: isSelected
            ? GeniusWalletColors.btnFilterSelected
            : GeniusWalletColors.btnFilter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: isSelected
                ? GeniusWalletColors.btnFilterSelected
                : GeniusWalletColors.btnFilter,
          ),
        ),
      ),
      child: Text(
        filter,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}
