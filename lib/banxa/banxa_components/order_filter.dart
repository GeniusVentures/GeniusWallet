import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:intl/intl.dart';

class OrderFilterPanel extends StatelessWidget {
  final List<String> statuses;
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onDateRangePressed;

  const OrderFilterPanel({
    required this.statuses,
    required this.selectedStatus,
    required this.startDate,
    required this.endDate,
    required this.onStatusChanged,
    required this.onDateRangePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GeniusWalletConsts.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space6,
                    vertical: GeniusWalletConsts.space8),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.isEmpty ? "All" : status),
                );
              }).toList(),
              onChanged: onStatusChanged,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: GeniusWalletColors.textPrimary),
                padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusXs),
                ),
              ),
              onPressed: onDateRangePressed,
              child: const Text("Pick Date Range"),
            ),
          ),
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space2,
                  vertical: GeniusWalletConsts.space4),
              child: Text(
                "Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} → ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                style: GeniusWalletTypography.bodyMd
                    .copyWith(color: GeniusWalletColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
