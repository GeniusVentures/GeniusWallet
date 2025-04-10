import 'package:flutter/material.dart';
import 'package:genius_wallet/app/reown/send_transaction_details.dart';
import 'package:genius_wallet/app/reown/utilites.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

Future<void> handleDappRequests({
  required ReownWalletKit walletKit,
}) async {
  walletKit.onSessionRequest.subscribe((SessionRequestEvent? event) async {
    debugPrint('🔄 Session request received: ${event?.eventName}');
    //debugPrint(event.toString());
    if (event == null) return;

    final String method = event.method;
    final int requestId = event.id;
    final String topic = event.topic;
    final dappMetadata = walletKit.getActiveSessions()[topic]?.peer.metadata;
    final dappName = dappMetadata?.name ?? 'Unknown DApp';
    final dappUrl = dappMetadata?.url ?? '';

    // todo parse the data to get token swap information
    // no built in help.. might need to build manually :(
    //final data = (tx['data']);

    Widget content;

    if (method == 'eth_sendTransaction') {
      final Map<String, dynamic> tx = event.params[0];
      final from = tx['from'] ?? 'Unknown';
      final to = tx['to'] ?? 'Unknown';
      final amountWei = parseHexToBigInt(tx['value']);

      final gasLimit = parseHexToBigInt(tx['gas']);
      final maxFeePerGas = parseHexToBigInt(tx['maxFeePerGas']);
      final maxPriorityFee = parseHexToBigInt(tx['maxPriorityFeePerGas']);

      final totalFeeWei = gasLimit * maxFeePerGas;
      final amountEth = formatEth(amountWei.toString());
      final totalFeeEth = formatEth(totalFeeWei.toString());
      final maxFeePerGasEth = formatEth(maxFeePerGas.toString());
      final priorityFeeEth = formatEth(maxPriorityFee.toString());

      content = SendTransactionDetails(
        fromAddress: from,
        toAddress: to,
        amount: amountEth,
        totalGasFee: totalFeeEth,
        priorityFee: priorityFeeEth,
        maxFeePerGas: maxFeePerGasEth,
      );
    } else {
      content = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dappUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(dappUrl,
                    style: const TextStyle(
                        color: GeniusWalletColors.gray500, fontSize: 12)),
              ),
            Text("Method: $method",
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            const Text("Params:",
                style: TextStyle(color: GeniusWalletColors.gray500)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(event.params.toString(),
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }

    final bool? shouldApprove = await showModalBottomSheet<bool>(
        enableDrag: false,
        context: navigatorKey.currentContext!,
        isScrollControlled: true,
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          final sheetMaxHeight = mediaQuery.size.height * 0.75;

          return SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: sheetMaxHeight,
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueTertiary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(
                            GeniusWalletConsts.borderRadiusButton),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/crypto/${dappName.toLowerCase()}.png",
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (frame == null) {
                                return const SizedBox.shrink(); // not loaded
                              }
                              return Row(
                                children: [
                                  child,
                                  const SizedBox(width: 12),
                                ],
                              );
                            },
                          ),
                          Flexible(
                            child: Text(
                              dappUrl,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: content,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text("Reject",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                          ),
                          child: const Text("Approve",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });

    if (shouldApprove == true) {
      await walletKit.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: requestId,
          jsonrpc: '2.0',
          result: '0x123456...', // Replace with real logic
        ),
      );
      debugPrint('✅ Request approved and responded.');
    } else {
      await walletKit.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: requestId,
          jsonrpc: '2.0',
          error: JsonRpcError(
            code: Errors.USER_REJECTED.toInt(),
            message: 'User rejected the request.',
          ),
        ),
      );
      debugPrint('❌ Request rejected.');
    }
  });
}
