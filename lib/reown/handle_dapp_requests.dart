import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/transaction.dart' as model;
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/swap_result_drawer.dart';
import 'package:genius_wallet/reown/utilites.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

Future<void> handleDappRequests(
    {required ReownWalletKit walletKit,
    required GeniusApi geniusApi,
    required WalletDetailsCubit walletDetailsCubit,
    required TransactionsCubit transactionsCubit}) async {
  final Set<int> pendingRequestIds = {};

  walletKit.onSessionRequest.subscribe((SessionRequestEvent? event) async {
    if (event == null) return;

    final int requestId = event.id;
    if (pendingRequestIds.contains(requestId)) {
      debugPrint('⚠️ Duplicate session request ID: $requestId – ignoring.');
      return;
    }

    pendingRequestIds.add(requestId);

    final Map<String, dynamic> tx = event.params[0];
    final String method = event.method;
    final String topic = event.topic;
    final dappMetadata = walletKit.getActiveSessions()[topic]?.peer.metadata;
    final dappName = dappMetadata?.name ?? 'Unknown DApp';
    final dappUrl = dappMetadata?.url ?? '';

    // todo parse the data to get token swap information
    // no built in help.. might need to build manually :(
    //final data = (tx['data']);

    Widget content;

    if (method == 'eth_sendTransaction') {
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

    final shouldApprove = await ApproveTransactionDrawer.show(
      context: navigatorKey.currentContext!,
      content: content,
      dappName: dappName,
      dappUrl: dappUrl,
      iconUrl: dappMetadata?.icons.isNotEmpty == true
          ? dappMetadata?.icons[0]
          : null,
    );

    if (shouldApprove == true) {
      final chainId = walletDetailsCubit.state.selectedNetwork?.chainId;
      final rpcUrl = walletDetailsCubit.state.selectedNetwork?.rpcUrl;
      final walletAddress = walletDetailsCubit.state.selectedWallet?.address;

      if (chainId == null || rpcUrl == null || walletAddress == null) {
        debugPrint('❌ Chain ID, RPC URL, or wallet address is null.');
        pendingRequestIds.remove(requestId);
        return;
      }

      final to = tx['to'] ?? 'Unknown';
      final amountWei = parseHexToBigInt(tx['value']);

      final gasLimit = parseHexToBigInt(tx['gas']);
      final maxFeePerGas = parseHexToBigInt(tx['maxFeePerGas']);

      final totalFeeWei = gasLimit * maxFeePerGas;
      final amountEth = formatEth(amountWei.toString());
      final totalFeeEth = formatEth(totalFeeWei.toString());

      // TODO: We should parse this out of the transaction data
      const coinSymbol = "ETH";

      // TODO: CONFIRM NETWORK ON SWAP MATCHES NETWORK SELECTED IN WALLET

      final result = await geniusApi.signAndSendTransaction(
          tx: tx,
          sourceChainId: chainId,
          rpcUrl: rpcUrl,
          address: walletAddress);

      if (result.isSuccess) {
        final txHash = result.data;

        await walletKit.respondSessionRequest(
          topic: topic,
          response: JsonRpcResponse(
            id: requestId,
            jsonrpc: '2.0',
            result: txHash,
          ),
        );
        debugPrint('✅ Success on Swap!: ${result.data}');

        // TODO: we should show a pending transaction until it completes
        // TODO: we should record the coin symbol instead of hard coding.
        final txModel = model.Transaction(
          hash: txHash ?? "",
          fromAddress: walletAddress,
          recipients: [TransferRecipients(toAddr: to, amount: amountEth)],
          timeStamp: DateTime.now(),
          transactionDirection: TransactionDirection.sent,
          fees: totalFeeEth,
          coinSymbol: coinSymbol,
          transactionStatus: TransactionStatus.completed,
          type: TransactionType.transfer,
        );

        SwapResultDrawer.show(
          context: navigatorKey.currentContext!,
          isSuccess: true,
          txHash: txHash ?? "",
          coinSymbol: coinSymbol,
        );

        pendingRequestIds.remove(requestId);

        // stream to ui
        transactionsCubit.addTransaction(txModel);
        // save to hive
        await TransactionStorageService()
            .addTransaction(walletAddress, txModel);
      } else {
        await walletKit.respondSessionRequest(
          topic: topic,
          response: JsonRpcResponse(
            id: requestId,
            jsonrpc: '2.0',
            error: JsonRpcError(
              code: Errors.USER_REJECTED.toInt(),
              message: result.errorMessage ?? 'Signing failed',
            ),
          ),
        );
        SwapResultDrawer.show(
          context: navigatorKey.currentContext!,
          isSuccess: false,
          txHash: "",
          coinSymbol: coinSymbol,
        );
        pendingRequestIds.remove(requestId);
        debugPrint('❌ Failed to Swap: ${result.errorMessage}');
      }
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
      SwapResultDrawer.show(
        context: navigatorKey.currentContext!,
        isSuccess: false,
        txHash: "",
        coinSymbol: "",
      );
      pendingRequestIds.remove(requestId);
      debugPrint('❌ Request rejected.');
    }
  });
}
