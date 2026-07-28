import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

class OrderDetailCard extends StatefulWidget {
  final Order order;
  final OrderStatusTone? bannerTone;
  final String? bannerText;
  final Widget actionButton;

  const OrderDetailCard({
    super.key,
    required this.order,
    this.bannerTone,
    this.bannerText,
    required this.actionButton,
  });

  @override
  State<OrderDetailCard> createState() => _OrderDetailCardState();
}

class _OrderDetailCardState extends State<OrderDetailCard> {
  bool _showFullWallet = false;

  String _maskWallet(String wallet) {
    if (wallet.length <= 10) {
      return wallet;
    }
    return '${wallet.substring(0, 6)}...${wallet.substring(wallet.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final o = widget.order;
    final statusTone = orderStatusTone(o.status);
    final statusPaint = orderStatusPaint(statusTone, gw);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          if (widget.bannerText != null && widget.bannerTone != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderStatusBanner(
                text: widget.bannerText!,
                tone: widget.bannerTone!,
              ),
            ),
          ListTile(
            title: Text(
              'Status',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            trailing: Text(
              o.status,
              style: GeniusWalletTypography.bodyLg.copyWith(
                color: statusPaint.fg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Fiat Amount',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            trailing: Text(
              '${o.fiatAmount} ${o.fiat}',
              style: GeniusWalletTypography.bodyLg.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Crypto Amount',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            trailing: Text(
              '${o.cryptoAmount} ${o.crypto.id}',
              style: GeniusWalletTypography.bodyLg.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Payment Method',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            trailing: Text(
              o.paymentMethodName,
              style: GeniusWalletTypography.bodyLg.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Wallet Address',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    _showFullWallet
                        ? o.walletAddress
                        : _maskWallet(o.walletAddress),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showFullWallet ? Icons.visibility_off : Icons.visibility,
                    color: gw.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _showFullWallet = !_showFullWallet);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'Created At',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
            trailing: Text(
              DateFormat.yMd().add_jm().format(o.createdAt.toLocal()),
              style: GeniusWalletTypography.bodyLg.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          widget.actionButton,
        ],
      ),
    );
  }
}
