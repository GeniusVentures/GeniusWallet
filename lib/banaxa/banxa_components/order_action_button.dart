import 'package:flutter/material.dart';
class OrderActionButton extends StatelessWidget {
  final String status;
  final VoidCallback? onCompletePayment;
  final VoidCallback? onRetryOrder;
  const OrderActionButton({
    required this.status,
    this.onCompletePayment,
    this.onRetryOrder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pendingpayment':
        return ElevatedButton(
          onPressed: onCompletePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Complete Payment'),
        );
      case 'declined':
        return OutlinedButton(
          onPressed: onRetryOrder,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Retry Order'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
