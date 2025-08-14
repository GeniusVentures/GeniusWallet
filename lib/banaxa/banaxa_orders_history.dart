// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/handle_banaxa_drawer.dart';
import 'package:genius_wallet/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa_order/banxa_order_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<OrdersCubit>(context).fetchOrders('your-cust-id');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pendingpayment':
      case 'pending':
        return Colors.orange;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date.toLocal());
    } catch (_) {
      return dateTime;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Map<String, dynamic> order) {
    final status = order['status']?.toString().toLowerCase() ?? '';
    final orderStatusUrl = order['orderStatusUrl'];
    final redirectUrl = Uri(
      scheme: 'geniuswallet',
      host: 'banxa',
      path: 'callback',
      queryParameters: {
        'extOrderId': order['externalOrderId']
      },
    ).toString();

    if (status == 'pendingpayment') {
      return ElevatedButton(
        onPressed: () async {
          print(redirectUrl);
          showCheckoutOptionsSheet(
            context,
            checkoutUrl: orderStatusUrl,
            orderId: order['id'],
            redirectUrl: redirectUrl,
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
              'fiat': order['fiat'],
              'crypto': order['crypto']['id'],
              'method': order['paymentMethodId'],
              'amount': order['fiatAmount'],
              'wallet': order['walletAddress'],
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

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] ?? 'Unknown';
    final fiat = "${order['fiatAmount']} ${order['fiat']}";
    final crypto = "${order['cryptoAmount']} ${order['crypto']['id']}";
    final paymentMethod = order['paymentMethodName'] ?? 'N/A';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order['reference'] ?? order['id']}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildInfoRow("Fiat:", fiat),
            _buildInfoRow("Crypto:", crypto),
            _buildInfoRow("Payment:", paymentMethod),
            const Divider(height: 20),
            _buildInfoRow("Updated:", _formatDate(order['updatedAt'] ?? '')),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(context, order),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/orderDetails',
                      extra: {
                        'orderId': order['id'] as String,
                        'checkoutUrl': order['orderStatusUrl'] as String,
                        'redirectUrl': BanxaApiService.redirectUrl
                      },
                    );
                  },
                  child: const Text('See Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = GoRouter.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: canGoBack,
        leading: canGoBack
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/dashboard');
                },
              ),
        title: const Text("My Orders"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersCubit>().fetchOrders('your-cust-id');
            },
          ),
          IconButton(
            onPressed: () => context.push('/createOrder'),
            icon: const Row(
              children: [
                Icon(Icons.add),
                SizedBox(width: 4),
                Text('New Order'),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.status == OrdersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == OrdersStatus.error) {
            return Center(
              child: Text("❌ ${state.error}",
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (state.orders.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<OrdersCubit>().fetchOrders('your-cust-id'),
            child: ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }
}
