import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:go_router/go_router.dart';

class NotEnoughBalanceScreen extends StatelessWidget {
  const NotEnoughBalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: '',
                    );
                  },
                ),
              ),
              const Spacer(),
              SvgPicture.asset('assets/images/not_enough_balance.svg'),
              const SizedBox(height: 30),
              Text(
                  'You don\'t have any ${context.read<WalletDetailsCubit>().state.selectedWallet!.currencySymbol}'),
              const SizedBox(height: 60),
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return MaterialButton(
                      onPressed: () {
                        context.push(
                          '/buy',
                          extra: context.read<WalletDetailsCubit>(),
                        );
                      },
                      child: IsactiveTrue(
                        constraints,
                        ovrContinue: 'Buy',
                      ),
                    );
                  },
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
