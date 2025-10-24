import 'package:flutter/material.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
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

  String _maskWallet(String wallet) {
    if (wallet.length <= 10) return wallet;
    return '${wallet.substring(0, 6)}...${wallet.substring(wallet.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          if (widget.bannerText != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.bannerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.bannerText!),
            ),
          ListTile(
            title: const Text('Status'),
            trailing: Text(
              o.status,
              style: TextStyle(
                color: o.status.toLowerCase() == 'completed'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Fiat Amount'),
            trailing: Text('${o.fiatAmount} ${o.fiat}'),
          ),
          ListTile(
            title: const Text('Crypto Amount'),
            trailing: Text('${o.cryptoAmount} ${o.crypto.id}'),
          ),
          ListTile(
            title: const Text('Payment Method'),
            trailing: Text(o.paymentMethodName),
          ),
          ListTile(
            title: const Text('Wallet Address'),
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
                  ),
                  onPressed: () {
                    setState(() => _showFullWallet = !_showFullWallet);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Created At'),
            trailing: Text(
              DateFormat.yMd().add_jm().format(o.createdAt.toLocal()),
            ),
          ),
          const SizedBox(height: 20),
          widget.actionButton,
        ],
      ),
    );
  }
}
