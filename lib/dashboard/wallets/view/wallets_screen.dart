import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/widgets/components/%D0%B0dd_wallet_text.g.dart';
import 'package:genius_wallet/widgets/components/genius_appbar.g.dart';
import 'package:genius_wallet/widgets/components/wallet_module.g.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GeniusAppbar(constraints);
                  },
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Wallets',
                    style: TextStyle(fontSize: 24),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    height: 15,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return DdWalletText(constraints);
                      },
                    ),
                  ),
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
                        itemCount: state.wallets.length,
                        itemBuilder: (context, index) {
                          final currentWallet = state.wallets[index];
                          return SizedBox(
                            height: 300,
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
                                String transactionId = '';
                                if (currentWallet.transactions.isNotEmpty) {
                                  // TODO: May need to actually compare dates to get latest
                                  final lastTransaction =
                                      currentWallet.transactions.last;

                                  timestamp = lastTransaction.timeStamp;
                                  transactionValue = lastTransaction.amount;
                                  transactionId = lastTransaction.hash;
                                }
                                return WalletModule(
                                  constraints,
                                  ovrCoinName: currentWallet.currencyName,
                                  ovrCoinSymbol: currentWallet.currencySymbol,
                                  ovrWalletBalance:
                                      currentWallet.balance.toString(),
                                  ovrLastTransactionID: transactionId,
                                  ovrLastTransactionValue: transactionValue,
                                  ovrTimestamp: timestamp,
                                  ovrTrendLine: trendLine,
                                  ovrCoinImage:
                                      WalletUtils.currencySymbolToImage(
                                    currentWallet.currencySymbol,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Text('No Wallets');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
