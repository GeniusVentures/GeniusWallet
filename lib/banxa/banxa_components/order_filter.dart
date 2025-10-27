import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(8.0),
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: onDateRangePressed,
              child: const Text("Pick Date Range"),
            ),
          ),
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                "Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} → ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
