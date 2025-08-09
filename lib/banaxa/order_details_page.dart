import 'package:flutter/material.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  const OrderDetailsPage({required this.orderId, super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<OrderResponseModel> _orderFuture;
  final _service = BanxaApiService();

  bool _showFullWallet = false; // Toggle for wallet address visibility

  @override
  void initState() {
    super.initState();
    _orderFuture = _service.getOrderById(widget.orderId);
  }

  String _maskWallet(String wallet) {
    if (wallet.length <= 10) return wallet; // If too short, skip masking
    return '${wallet.substring(0, 6)}...${wallet.substring(wallet.length - 4)}';
  }

  Widget _buildActionButton(BuildContext context, OrderResponseModel o) {
    final status = o.status.toLowerCase();
    final orderStatusUrl =
        o.orderStatusUrl;

    if (status == 'pendingpayment') {
      return ElevatedButton(
        onPressed: () async {
          await context.push(
            '/checkout',
            extra: {
              'checkoutUrl': orderStatusUrl,
              'redirectUrl': 'your_redirect_url_here',
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Complete Payment'),
      );
    } else if (status == 'declined') {
      return OutlinedButton(
        onPressed: () {
          context.push(
            '/createOrder',
            extra: {
              'fiat': o.fiat,
              'crypto': o.crypto.id,
              'method': o.paymentMethodId,
              'amount': o.fiatAmount,
              'wallet': o.walletAddress,
            },
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,

          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Retry Order'),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<OrderResponseModel>(
        future: _orderFuture,
        builder: (c, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final o = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
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
                          _showFullWallet
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFullWallet = !_showFullWallet;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (o.transactionHash != null)
                  ListTile(
                    title: const Text('Transaction Hash'),
                    subtitle: Text(o.transactionHash!),
                  ),
                ListTile(
                  title: const Text('Created At'),
                  trailing: Text(
                    DateFormat.yMd().add_jm().format(o.createdAt.toLocal()),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildActionButton(context, o),
              ],
            ),
          );
        },
      ),
    );
  }
}
