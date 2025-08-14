import 'package:flutter/material.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:genius_wallet/banaxa/handle_banaxa_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final String? checkoutUrl;
  final String? redirectUrl;
  final String? initialStatus;

  const OrderDetailsPage({
    required this.orderId,
    this.checkoutUrl,
    this.redirectUrl,
    this.initialStatus,
    super.key,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<OrderResponseModel> _orderFuture;
  final _service = BanxaApiService();
  bool _showFullWallet = false;

  Color? _bannerColor;
  String? _bannerText;

  @override
  void initState() {
    super.initState();
    _orderFuture = _service.getOrderById(widget.orderId);

    final s = widget.initialStatus?.toLowerCase();
    if (s == 'cancel') {
      _bannerColor = Colors.amber.shade100;
      _bannerText = 'Checkout cancelled. Verifying order status…';
    } else if (s == 'failure' || s == 'failed') {
      _bannerColor = Colors.red.shade100;
      _bannerText = 'Payment failed. Verifying order status…';
    } else if (s == 'success' || s == 'completed') {
      _bannerColor = Colors.green.shade100;
      _bannerText = 'Payment completed. Fetching final details…';
    }

    if (_bannerText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_bannerText!)),
        );
      });
    }
  }

  String _maskWallet(String wallet) {
    if (wallet.length <= 10) return wallet;
    return '${wallet.substring(0, 6)}...${wallet.substring(wallet.length - 4)}';
  }

  String? _effectiveCheckoutUrl(OrderResponseModel o) {
    if ((widget.checkoutUrl ?? '').isNotEmpty) return widget.checkoutUrl;
    return o.orderStatusUrl.isNotEmpty ? o.orderStatusUrl : null;
  }

  Widget _buildActionButton(BuildContext context, OrderResponseModel o) {
    final status = o.status.toLowerCase();
    final checkout = _effectiveCheckoutUrl(o);
    final orderId = (o.id.isNotEmpty ? o.id : widget.orderId);
    final redirect = widget.redirectUrl ?? BanxaApiService.redirectUrl;

    if (status == 'pendingpayment' && checkout != null && orderId.isNotEmpty) {
      return ElevatedButton(
        onPressed: () async {
          await showCheckoutOptionsSheet(
            context,
            checkoutUrl: checkout,
            orderId: orderId,
            redirectUrl: redirect,
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
          context.push('/createOrder', extra: {
            'fiat': o.fiat,
            'crypto': o.crypto.id,
            'method': o.paymentMethodId,
            'amount': o.fiatAmount,
            'wallet': o.walletAddress,
          });
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
    final canGoBack = GoRouter.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        automaticallyImplyLeading: canGoBack,
        leading: canGoBack
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/buy');
                },
              ),
      ),
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
                if (_bannerText != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bannerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_bannerText!),
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
                          _showFullWallet
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _showFullWallet = !_showFullWallet);
                        },
                      ),
                    ],
                  ),
                ),
                if (o.transactionHash != null && o.transactionHash!.isNotEmpty)
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
                const SizedBox(height: 20),
                _buildActionButton(context, o),
              ],
            ),
          );
        },
      ),
    );
  }
}
