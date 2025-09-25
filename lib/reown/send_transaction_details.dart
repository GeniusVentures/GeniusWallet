import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class SendTransactionDetails extends StatelessWidget {
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String totalGasFee;
  final String maxFeePerGas;
  final String priorityFee;
  final String? receiveTokenSymbol;

  const SendTransactionDetails(
      {super.key,
      required this.fromAddress,
      required this.toAddress,
      required this.amount,
      required this.totalGasFee,
      required this.maxFeePerGas,
      required this.priorityFee,
      this.receiveTokenSymbol});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _labeledBox(label: "From", value: fromAddress),
        const SizedBox(height: 12),
        _labeledBox(label: "To", value: toAddress),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Estimated changes",
                style: TextStyle(
                  color: GeniusWalletColors.gray500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: GeniusWalletColors.deepBlueCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _fieldRow("You send", "$amount ETH"),
                    const SizedBox(height: 8),
                    if (receiveTokenSymbol != null) ...[
                      _fieldRow("You receive", receiveTokenSymbol!),
                      const SizedBox(height: 20),
                    ],
                    _fieldRow("Gas Fee", "$totalGasFee ETH"),
                    const SizedBox(height: 4),
                    _fieldRow("Max Fee Per Gas", "$maxFeePerGas ETH"),
                    const SizedBox(height: 4),
                    _fieldRow("Priority Fee", "$priorityFee ETH"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labeledBox({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: GeniusWalletColors.gray500, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: GeniusWalletColors.gray600),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _fieldRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
