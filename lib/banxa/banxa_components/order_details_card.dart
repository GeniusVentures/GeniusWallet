import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:intl/intl.dart';

class OrderDetailCard extends StatefulWidget {
  final Order order;
  final Color? bannerColor;
  final String? bannerText;
  final Widget actionButton;

  const OrderDetailCard({
    super.key,
    required this.order,
    this.bannerColor,
    this.bannerText,
    required this.actionButton,
  });

  @override
  State<OrderDetailCard> createState() => _OrderDetailCardState();
}

class _OrderDetailCardState extends State<OrderDetailCard> {
  bool _showFullWallet = false;

  // 4 + 4 truncation per design system §6.5 (Numbers & money).
  String _maskWallet(String wallet) {
    if (wallet.length <= 10) return wallet;
    return '${wallet.substring(0, 4)}…${wallet.substring(wallet.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final isCompleted = o.status.toLowerCase() == 'completed';
    final statusColor = isCompleted
        ? GeniusWalletColors.statusSuccess
        : GeniusWalletColors.statusWarning;

    return Padding(
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: ListView(
        children: [
          if (widget.bannerText != null)
            Container(
              margin: const EdgeInsets.only(bottom: GeniusWalletConsts.space6),
              padding: const EdgeInsets.all(GeniusWalletConsts.space6),
              decoration: BoxDecoration(
                color: widget.bannerColor,
                borderRadius:
                    BorderRadius.circular(GeniusWalletConsts.radiusSm),
              ),
              child: Text(widget.bannerText!,
                  style: GeniusWalletTypography.bodyMd),
            ),
          ListTile(
            title: Text('Status', style: GeniusWalletTypography.bodyMd),
            trailing: Text(
              o.status,
              style: GeniusWalletTypography.titleMd.copyWith(color: statusColor),
            ),
          ),
          ListTile(
            title: Text('Fiat Amount', style: GeniusWalletTypography.bodyMd),
            trailing: Text('${o.fiatAmount} ${o.fiat}',
                style: GeniusWalletTypography.numericBody),
          ),
          ListTile(
            title: Text('Crypto Amount', style: GeniusWalletTypography.bodyMd),
            trailing: Text('${o.cryptoAmount} ${o.crypto.id}',
                style: GeniusWalletTypography.numericBody),
          ),
          ListTile(
            title: Text('Payment Method', style: GeniusWalletTypography.bodyMd),
            trailing: Text(o.paymentMethodName,
                style: GeniusWalletTypography.bodyMd),
          ),
          ListTile(
            title: Text('Wallet Address', style: GeniusWalletTypography.bodyMd),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    _showFullWallet
                        ? o.walletAddress
                        : _maskWallet(o.walletAddress),
                    style: GeniusWalletTypography.numericBody,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFullWallet ? Icons.visibility_off : Icons.visibility,
                    color: GeniusWalletColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _showFullWallet = !_showFullWallet);
                  },
                  tooltip: 'Toggle visibility',
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Created At', style: GeniusWalletTypography.bodyMd),
            trailing: Text(
              DateFormat.yMd().add_jm().format(o.createdAt.toLocal()),
              style: GeniusWalletTypography.bodyMd,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space10),
          widget.actionButton,
        ],
      ),
    );
  }
}
