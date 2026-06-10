import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

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
        const SizedBox(height: GeniusWalletConsts.space12),
        _labeledBox(label: "From", value: fromAddress),
        const SizedBox(height: GeniusWalletConsts.space6),
        _labeledBox(label: "To", value: toAddress),
        const SizedBox(height: GeniusWalletConsts.space12),
        Center(
          child: Column(
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: GeniusWalletColors.textPrimary,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              Text(
                "Estimated changes",
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: GeniusWalletColors.gray500,
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: GeniusWalletConsts.space6,
                    horizontal: GeniusWalletConsts.space8),
                decoration: BoxDecoration(
                  gradient: GWDecorations.surfaceSheen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: GeniusWalletColors.borderSubtle, width: 1),
                ),
                child: Column(
                  children: [
                    _fieldRow("You send", "$amount ETH"),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    if (receiveTokenSymbol != null) ...[
                      _fieldRow("You receive", receiveTokenSymbol!),
                      const SizedBox(height: GeniusWalletConsts.space10),
                    ],
                    _fieldRow("Gas Fee", "$totalGasFee ETH"),
                    const SizedBox(height: GeniusWalletConsts.space2),
                    _fieldRow("Max Fee Per Gas", "$maxFeePerGas ETH"),
                    const SizedBox(height: GeniusWalletConsts.space2),
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
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.gray500)),
        const SizedBox(height: GeniusWalletConsts.space2),
        Container(
          padding: const EdgeInsets.all(GeniusWalletConsts.space6),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: GeniusWalletColors.gray600),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(color: GeniusWalletColors.textPrimary),
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
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.textPrimary70)),
        Text(value,
            style: GeniusWalletTypography.numericBody
                .copyWith(color: GeniusWalletColors.textPrimary)),
      ],
    );
  }
}
