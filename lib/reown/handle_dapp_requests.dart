import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/transaction.dart' as model;
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart';
import 'package:genius_wallet/reown/dapp_call_details.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/swap_result_drawer.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

void Function() handleDappRequests({
  required ReownWalletKit walletKit,
  required GeniusApi geniusApi,
  required WalletDetailsCubit walletDetailsCubit,
  required TransactionsCubit transactionsCubit,
}) {
  final Set<int> pendingRequestIds = {};

  Future<void> onSessionRequest(SessionRequestEvent? event) async {
    if (event == null) {
      return;
    }

    final int requestId = event.id;
    if (pendingRequestIds.contains(requestId)) {
      debugPrint('⚠️ Duplicate session request ID: $requestId – ignoring.');
      return;
    }

    pendingRequestIds.add(requestId);

    final String method = event.method;
    final String topic = event.topic;

    // Exactly one answer per request, and never none. A caller left without
    // one waits for a reply that is not coming.
    var answered = false;
    // The answer that was attempted, kept so a retry after a dropped relay
    // says the same thing: a rejection resent as a server error would tell
    // the dApp the wallet failed when the user said no.
    JsonRpcResponse? attempted;
    Future<void> respond({String? result, JsonRpcError? error}) async {
      if (answered) {
        return;
      }
      attempted ??= JsonRpcResponse(
        id: requestId,
        jsonrpc: '2.0',
        result: result,
        error: error,
      );
      await walletKit.respondSessionRequest(topic: topic, response: attempted!);
      // Only once the relay took it: a throw above, on a dropped connection,
      // must leave the catch below free to try again.
      answered = true;
    }

    try {
      final dappMetadata = walletKit.getActiveSessions()[topic]?.peer.metadata;
      final dappName = dappMetadata?.name ?? 'Unknown DApp';
      final dappUrl = dappMetadata?.url ?? '';
      final iconUrl = dappMetadata?.icons.isNotEmpty == true
          ? dappMetadata?.icons[0]
          : null;
      final network = walletDetailsCubit.state.selectedNetwork;
      final networkName = network?.name ?? '';
      // Gas and a plain send are both denominated in the chain's own coin, so
      // the drawer and the stored receipt must read it from one place. Two
      // sources drifted once already: the screen said ETH on Polygon while the
      // record said POL. That coin is `nativeSymbol` where a chain has one:
      // Base's key is "base" but its gas is paid in ETH.
      final nativeUnit = (network?.nativeSymbol ?? network?.symbol ?? 'ETH')
          .toUpperCase();

      // The request names its chain and the signer signs on the selected one.
      // Those must agree before anything is decoded: the router allow-list,
      // the token list and the RPC below are all the selected network's.
      final requestedChain = eip155ChainId(event.chainId);
      final selectedChain = network?.chainId;
      if (requestedChain != null &&
          selectedChain != null &&
          requestedChain != selectedChain) {
        await ApproveTransactionDrawer.show(
          context: navigatorKey.currentContext!,
          content: DappCallDetails(
            headline: 'Request for another network',
            warning: wrongChainWarning(requestedChain, networkName),
            rows: [
              DappCallRow(label: 'Requested chain', value: '$requestedChain'),
              if (networkName.isNotEmpty)
                DappCallRow(label: 'Selected network', value: networkName),
            ],
          ),
          dappName: dappName,
          dappUrl: dappUrl,
          iconUrl: iconUrl,
        );
        await respond(error: unsupportedChainError());
        debugPrint('❌ Declined, request is for chain $requestedChain');
        return;
      }

      // The method decides what shape the parameters arrive in, so it is read
      // first. Casting first is what threw on every signing request.
      final kind = classifyDappRequest(method, event.params);

      if (kind == DappRequestKind.transaction) {
        final tx = transactionParam(event.params)!;
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

        // Read-only: `tx` is the same map handed to the signer below, so the
        // bytes the user approves stay exactly as the dApp sent them.
        final summary = summarizeTransaction(
          tx,
          // Tokens are matched by address, and the same address is a
          // different contract on another chain. The list is used only once
          // it was loaded for this network: symbols repeat (Ethereum, Sepolia).
          coins: walletDetailsCubit.state.coinsNetwork == network
              ? walletDetailsCubit.state.coins
              : const [],
          // The chain decides whether `to` is a router this wallet will name:
          // the same address is a different contract on a different chain.
          chainId: network?.chainId,
          nativeSymbol: nativeUnit,
        );
        final isTokenTransfer = summary.kind == DappCallKind.tokenTransfer;

        // The send body asserts that one figure, in one unit, leaves the
        // wallet. Only these two kinds were read well enough for that
        // sentence to be true -- and a token transfer that also carries
        // native value moves two figures, so it takes the rows instead.
        final Widget content;
        if (summary.kind == DappCallKind.nativeSend ||
            (isTokenTransfer && summary.nativeAmount == null)) {
          content = SendTransactionDetails(
            fromAddress: from,
            // For a token transfer `tx['to']` is the contract, not the person
            // being paid -- the recipient only exists inside the calldata.
            toAddress: isTokenTransfer ? summary.recipient! : to,
            amount: isTokenTransfer ? summary.amount! : amountEth,
            amountSymbol: isTokenTransfer ? summary.symbol! : nativeUnit,
            feeSymbol: nativeUnit,
            totalGasFee: totalFeeEth,
            priorityFee: priorityFeeEth,
            maxFeePerGas: maxFeePerGasEth,
          );
        } else {
          content = DappCallDetails(
            headline: dappCallHeadline(summary),
            warning: dappCallWarning(summary),
            rows: dappCallRows(
              summary,
              from: from,
              networkName: network?.name,
              nativeSymbol: nativeUnit,
              // The dApp chose these and the signer uses them as sent, so a
              // call the wallet cannot read still shows what it will cost.
              gasFee: totalFeeEth,
              maxFeePerGas: maxFeePerGasEth,
              priorityFee: priorityFeeEth,
            ),
          );
        }

        final shouldApprove = await ApproveTransactionDrawer.show(
          context: navigatorKey.currentContext!,
          content: content,
          dappName: dappName,
          dappUrl: dappUrl,
          iconUrl: iconUrl,
        );

        if (shouldApprove != true) {
          await respond(error: userRejectedError());
          debugPrint('❌ Request rejected.');
          return;
        }

        final chainId = network?.chainId;
        final rpcUrl = network?.rpcUrl;
        final walletAddress = walletDetailsCubit.state.selectedWallet?.address;

        if (chainId == null ||
            rpcUrl == null ||
            rpcUrl.isEmpty ||
            walletAddress == null) {
          // The user approved something the wallet then could not act on.
          // That is a failure on this side rather than a rejection, and it
          // used to be answered with silence.
          await respond(
            error: JsonRpcError.serverError(
              'No network, RPC URL or wallet is selected.',
            ),
          );
          debugPrint('❌ Chain ID, RPC URL, or wallet address is null.');
          return;
        }

        // Read off the same summary the drawer was built from, so the
        // record and the screen that authorised it cannot disagree.
        final coinSymbol = receiptSymbol(summary, nativeSymbol: nativeUnit);

        // TODO: CONFIRM NETWORK ON SWAP MATCHES NETWORK SELECTED IN WALLET

        final result = await geniusApi.signAndSendTransaction(
          tx: tx,
          sourceChainId: chainId,
          rpcUrl: rpcUrl,
          address: walletAddress,
        );

        // A signature that failed is not a user who said no, and a dApp that
        // cannot tell them apart retries the wrong one.
        final failure = JsonRpcError.serverError(
          result.errorMessage ?? 'Signing failed',
        );
        // A hash on a failure is a broadcast the node never answered. It may
        // be on the network, so it is recorded as pending for the next launch
        // to settle; the dApp is still told it failed.
        final maybeSent = !result.isSuccess && result.data != null;
        if (!result.isSuccess && !maybeSent) {
          await respond(error: failure);
          unawaited(
            SwapResultDrawer.show(
              context: navigatorKey.currentContext!,
              isSuccess: false,
              txHash: "",
              coinSymbol: coinSymbol,
            ),
          );
          debugPrint('❌ Failed to Swap: ${result.errorMessage}');
          return;
        }

        final txHash = result.data;
        // The hash may be on the network whether or not the dApp heard it: a
        // dropped answer is tried once more, and `attempted` holds the first
        // answer so nothing later can change it. The record below is owed
        // either way.
        for (var attempt = 1; attempt <= 2 && !answered; attempt++) {
          try {
            await (maybeSent
                ? respond(error: failure)
                : respond(result: txHash));
          } catch (answerFailed) {
            debugPrint(
              '❌ Answer $attempt for request $requestId failed: $answerFailed',
            );
          }
        }
        debugPrint('✅ Sent (confirmed: ${!maybeSent}): ${result.data}');

        // A token call's recipient and amount live in the calldata, not in
        // `tx['to']`/`amountEth` -- those still name the contract and the
        // (usually zero) native value. Only a decoded transfer has a real
        // pair to file under.
        final decodesRecipient =
            summary.kind == DappCallKind.tokenTransfer ||
            summary.kind == DappCallKind.unverifiedToken;
        final recipientAddress = decodesRecipient
            ? (summary.recipient ?? to)
            : to;
        // An unverified token's amount is raw base units -- no decimals are
        // known to scale it -- so it is labelled as such, never read as whole
        // tokens.
        final decoded = summary.amount;
        final recipientAmount = !decodesRecipient || decoded == null
            ? amountEth
            : summary.kind == DappCallKind.unverifiedToken
            ? '$decoded base units'
            : decoded;
        final nativeAlongside = decodesRecipient ? summary.nativeAmount : null;

        // TODO: we should show a pending transaction until it completes
        final txModel = model.Transaction(
          hash: txHash ?? "",
          fromAddress: walletAddress,
          recipients: [
            TransferRecipients(
              toAddr: recipientAddress,
              amount: recipientAmount,
            ),
            // Native value the same call paid the contract, kept rather than
            // dropped from history.
            if (nativeAlongside != null)
              TransferRecipients(toAddr: to, amount: nativeAlongside),
          ],
          timeStamp: DateTime.now(),
          transactionDirection: TransactionDirection.sent,
          fees: totalFeeEth,
          coinSymbol: nativeUnit,
          transactionStatus: maybeSent
              ? TransactionStatus.pending
              : TransactionStatus.completed,
          type: TransactionType.transfer,
          assetSymbol: coinSymbol,
          chainId: chainId,
        );

        if (maybeSent) {
          showToast(
            navigatorKey.currentContext!,
            "The network didn't confirm it received this transaction. It's "
            'in your history as pending -- check there before trying again.',
            title: 'Transaction not confirmed',
            type: ToastType.warning,
          );
        } else {
          unawaited(
            SwapResultDrawer.show(
              context: navigatorKey.currentContext!,
              isSuccess: true,
              txHash: txHash ?? "",
              coinSymbol: coinSymbol,
            ),
          );
        }

        // stream to ui
        transactionsCubit.addTransaction(txModel);
        // save to hive
        await const TransactionStorageService().addTransaction(
          walletAddress,
          txModel,
        );
        return;
      }

      // Everything else: a signature this wallet has no renderer for, or a
      // method it does not handle at all. Both are shown, neither is
      // honoured, and the copy says so before any button is pressed.
      //
      // ponytail: declining every signature is the ceiling of having no
      // typed-data renderer. The upgrade is to render EIP-712 payloads and
      // honour an approval for the ones that render.
      final isSignature = kind == DappRequestKind.unreadableSignature;
      await ApproveTransactionDrawer.show(
        context: navigatorKey.currentContext!,
        content: DappCallDetails(
          headline: isSignature
              ? 'Signature request: $method'
              : 'Unknown request',
          warning: isSignature
              ? kUnreadableSignatureWarning
              : kUnhandledMethodWarning,
          rows: [
            if (!isSignature) DappCallRow(label: 'Method', value: method),
            if (networkName.isNotEmpty)
              DappCallRow(label: 'Network', value: networkName),
          ],
        ),
        dappName: dappName,
        dappUrl: dappUrl,
        iconUrl: iconUrl,
      );
      await respond(error: userRejectedError());
      debugPrint('❌ Declined, nothing here can be read: $method');
    } catch (e) {
      debugPrint('❌ Session request handling failed: $e');
      try {
        // A fixed sentence rather than the exception: the caller needs an
        // answer, not this wallet's internals.
        await respond(
          error: JsonRpcError.serverError('The wallet could not handle this.'),
        );
      } catch (answerFailed) {
        debugPrint('❌ Could not answer request $requestId: $answerFailed');
      }
    } finally {
      pendingRequestIds.remove(requestId);
    }
  }

  walletKit.onSessionRequest.subscribe(onSessionRequest);

  return () {
    walletKit.onSessionRequest.unsubscribe(onSessionRequest);
  };
}
