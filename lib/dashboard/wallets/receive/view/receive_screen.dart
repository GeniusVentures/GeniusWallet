import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/copy_wallet_i_d.g.dart';
import 'package:genius_wallet/widgets/components/wallet_q_r_code.g.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle:
                          'Receive ${context.read<WalletDetailsCubit>().state.selectedWallet!.currencySymbol}',
                    );
                  },
                ),
              ),
              const Spacer(),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return WalletQRCode(
                    constraints,
                    ovrWalletID: context
                        .read<WalletDetailsCubit>()
                        .state
                        .selectedWallet!
                        .address,
                  );
                },
              ),
              const SizedBox(height: 50),
              SizedBox(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return CopyWalletID(constraints);
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
