import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/utils/formatters.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/app/widgets/responsive_grid.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/add_wallet_block.g.dart';
import 'package:genius_wallet/widgets/components/wallet_module.g.dart';
import 'package:go_router/go_router.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (GeniusBreakpoints.useDesktopLayout(context)) {
      return const Desktop();
    }
    return const Mobile();
  }
}

class Desktop extends StatelessWidget {
  const Desktop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DesktopContainer(
      title: 'Wallets',
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.wallets.isNotEmpty) {
            return ResponsiveGrid(children: [
              for (var wallet in state.wallets)
                SizedBox(
                  height: 350,
                  width: 350,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      //TODO: override trendline here
                      final trendLine = SvgPicture.asset(
                        'assets/images/trendline.svg',
                        package: 'genius_wallet',
                        fit: BoxFit.fill,
                      );
                      String timestamp = '';
                      String transactionValue = '';
                      String transactionId = 'No transactions for this wallet';
                      if (wallet.transactions.isNotEmpty) {
                        // TODO: May need to actually compare dates to get latest
                        final lastTransaction = wallet.transactions.last;

                        timestamp =
                            dateFormatter.format(lastTransaction.timeStamp);
                        transactionValue =
                            lastTransaction.recipients.first.amount;
                        transactionId = lastTransaction.hash;
                      }
                      return MaterialButton(
                          onPressed: () {
                            context.push('/wallets/${wallet.address}');
                          },
                          child: WalletModule(
                            constraints,
                            walletType: wallet.walletType,
                            walletAddress: wallet.address,
                            walletName: wallet.walletName,
                            ovrCoinSymbol: wallet.currencySymbol,
                            ovrWalletBalance: wallet.balance.toStringAsFixed(8),
                            ovrLastTransactionID: transactionId,
                            ovrLastTransactionValue: transactionValue,
                            ovrTimestamp: timestamp,
                            ovrTrendLine: trendLine,
                            ovrCoinImage: WalletUtils.currencySymbolToImage(
                              wallet.currencySymbol,
                            ),
                          ));
                    },
                  ),
                ),
              SizedBox(child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return AddWalletBlock(constraints);
                },
              )),
            ]);
          }
          return const Text('No Wallets');
        },
      ),
    );
  }
}

class Mobile extends StatelessWidget {
  const Mobile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                      child: AutoSizeText(
                    'Wallets',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24),
                  )),
                  TextButton.icon(
                      onPressed: () =>
                          context.push('/landing_screen', extra: true),
                      style: ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (!states.contains(MaterialState.selected)) {
                              return GeniusWalletColors.lightGreenPrimary;
                            }
                            return GeniusWalletColors.lightGreenSecondary;
                          }),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ))),
                      label: const AutoSizeText(
                        GeniusWalletText.btnAddWallet,
                        maxLines: 1,
                        style: TextStyle(
                            color: GeniusWalletColors.deepBlueTertiary),
                      ),
                      icon: const Icon(
                        Icons.add_circle_outlined,
                        color: GeniusWalletColors.deepBlueTertiary,
                      )),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  if (state.wallets.isNotEmpty) {
                    return Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: state.wallets.length + 1,
                        itemBuilder: (context, index) {
                          /// Last item should be an "Add Wallet"
                          if (index == state.wallets.length) {
                            return SizedBox(
                              height: 350,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return AddWalletBlock(constraints);
                                },
                              ),
                            );
                          }
                          final currentWallet = state.wallets[index];
                          return SizedBox(
                            height: 350,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                //TODO: override trendline here
                                final trendLine = SvgPicture.asset(
                                  'assets/images/trendline.svg',
                                  package: 'genius_wallet',
                                  fit: BoxFit.fill,
                                );
                                String timestamp = '';
                                String transactionValue = '';
                                String transactionId =
                                    'No transactions for this wallet';
                                if (currentWallet.transactions.isNotEmpty) {
                                  // TODO: May need to actually compare dates to get latest
                                  final lastTransaction =
                                      currentWallet.transactions.last;

                                  timestamp = dateFormatter
                                      .format(lastTransaction.timeStamp);
                                  transactionValue =
                                      lastTransaction.recipients.first.amount;
                                  transactionId = lastTransaction.hash;
                                }
                                return MaterialButton(
                                    onPressed: () {
                                      context.push(
                                          '/wallets/${currentWallet.address}');
                                    },
                                    child: WalletModule(
                                      constraints,
                                      walletAddress: currentWallet.address,
                                      walletName: currentWallet.walletName,
                                      walletType: currentWallet.walletType,
                                      ovrCoinSymbol:
                                          currentWallet.currencySymbol,
                                      ovrWalletBalance: currentWallet.balance
                                          .toStringAsFixed(8),
                                      ovrLastTransactionID: transactionId,
                                      ovrLastTransactionValue: transactionValue,
                                      ovrTimestamp: timestamp,
                                      ovrTrendLine: trendLine,
                                      ovrCoinImage:
                                          WalletUtils.currencySymbolToImage(
                                        currentWallet.currencySymbol,
                                      ),
                                    ));
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Text('No Wallets');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
