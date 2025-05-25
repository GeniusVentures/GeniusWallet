import 'package:flutter/material.dart';
import 'package:genius_wallet/reown/approve_dapp_connection_drawer.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/reown/swap_result_drawer.dart';
import 'package:genius_wallet/squid_router/swap_success_drawer.dart';
import 'package:genius_wallet/squid_router/swap_fail_drawer.dart';

class TestSwapButtons extends StatelessWidget {
  const TestSwapButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        IconButton(
          tooltip: "Test Approve Connection Drawer",
          icon: const Icon(Icons.private_connectivity_outlined,
              color: Colors.yellowAccent),
          onPressed: () {
            ApproveDappConnectionDrawer.show(
              context: context,
              dappName: 'uniswap',
              dappUrl: 'uniswap.org',
              dappDescription:
                  'UniSwap is a decentralized exchange protocol that allows users to swap various cryptocurrencies directly from their wallets without the need for an intermediary.',
              iconUrl: 'https://uniswap.org/favicon.ico',
            );
          },
        ),
        IconButton(
          tooltip: "Test Swap Result Drawer (Success)",
          icon: const Icon(Icons.swap_horiz, color: Colors.greenAccent),
          onPressed: () {
            SwapResultDrawer.show(
              context: context,
              isSuccess: true,
              txHash:
                  "0x0f9b1b9a7c65dd5c1c0c0ef879b1dd73bb7f7f2187bbf1a8329c7edc9b3d4abc",
              coinSymbol: "ETH",
            );
          },
        ),
        IconButton(
          tooltip: "Test Swap Result Drawer (Failure)",
          icon: const Icon(Icons.swap_horiz, color: Colors.redAccent),
          onPressed: () {
            SwapResultDrawer.show(
              context: context,
              isSuccess: false,
              txHash:
                  "0x0f9b1b9a7c65dd5c1c0c0ef879b1dd73bb7f7f2187bbf1a8329c7edc9b3d4abc",
              coinSymbol: "ETH",
            );
          },
        ),
        IconButton(
          tooltip: "Test Approve Swap Drawer",
          icon: const Icon(Icons.approval, color: Colors.blueAccent),
          onPressed: () {
            ApproveTransactionDrawer.show(
              dappName: 'uniswap',
              dappUrl: 'https://uniswap.org',
              context: context,
              iconUrl: 'https://uniswap.org/favicon.ico',
              content: const SendTransactionDetails(
                fromAddress: "0x0From",
                toAddress: "0X0To",
                amount: "1.0",
                totalGasFee: "0.001",
                priorityFee: "0.001",
                maxFeePerGas: "0.001",
              ),
            );
          },
        ),
        // ✅ SwapSuccessDrawer
        IconButton(
          tooltip: "Test Swap Success Drawer",
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          onPressed: () {
            SwapSuccessDrawer.show(
              context,
              fromAmount: "1.0",
              toAmount: "0.98",
              fromSymbol: "ETH",
              toSymbol: "USDC",
              fromIconUrl:
                  "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
              toIconUrl:
                  "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png",
              chain: "Ethereum",
            );
          },
        ),
        // ❌ SwapFailedDrawer
        IconButton(
          tooltip: "Test Swap Failed Drawer",
          icon: const Icon(Icons.error_outline, color: Colors.redAccent),
          onPressed: () {
            SwapFailDrawer.show(
              context,
              fromAmount: "1.0",
              toAmount: "0.00",
              fromSymbol: "ETH",
              toSymbol: "USDC",
              fromIconUrl:
                  "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
              toIconUrl:
                  "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png",
              chain: "Ethereum",
            );
          },
        ),
      ],
    );
  }
}
