import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banxa_order/polling_order_cubit.dart';
import 'package:genius_wallet/banaxa/banxa_order/polling_order_state.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class CheckoutQrPage extends StatelessWidget {
  final String checkoutUrl;
  final String orderId;

  const CheckoutQrPage({
    super.key,
    required this.checkoutUrl,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = math.max(
        160.0, math.min(320.0, MediaQuery.of(context).size.width - 64));

    return BlocBuilder<PollingCubit, PollingState>(
      builder: (context, state) {
        final cubit = context.read<PollingCubit>();
        if (state.order != null &&
            (state.order!.status.toLowerCase() == 'completed' ||
                state.order!.status.toLowerCase() == 'inprogress') &&
            !cubit.hasNavigated) {
          cubit.hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.push(
              '/orderDetails',
              extra: {
                'orderId': state.order!.orderId,
                'checkoutUrl': state.order!.orderStatusUrl,
              },
            );
          });
        }

        if (state.order != null &&
            (state.order!.status.toLowerCase() == 'failed' ||
                state.order!.status.toLowerCase() == 'cancelled') &&
            !cubit.hasNavigated) {
          cubit.hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAppSnackBar(context, 'Order ${state.order!.status}');
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Scan to Continue')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Scan this QR on another device to complete checkout.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: QrImageView(
                      data: checkoutUrl,
                      version: QrVersions.auto,
                      size: qrSize,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  checkoutUrl.length > 50
                      ? '${checkoutUrl.substring(0, 50)}...'
                      : checkoutUrl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: checkoutUrl));
                          if (context.mounted) {
                            showAppSnackBar(context, 'Link copied');
                          }
                        },
                        icon: const Icon(Icons.content_copy),
                        label: const Text('Copy Link'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      if (state.status == PollingStatus.loading)
                        const Loading(),
                      const SizedBox(height: 12),
                      Text(
                        state.message.isNotEmpty
                            ? state.message
                            : 'Waiting for payment...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
