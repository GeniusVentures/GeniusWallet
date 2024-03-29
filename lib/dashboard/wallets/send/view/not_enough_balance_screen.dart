import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_back_button_header.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:go_router/go_router.dart';

class NotEnoughBalanceScreen extends StatelessWidget {
  const NotEnoughBalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (GeniusBreakpoints.useDesktopLayout(context)) {
          return const _NotEnoughBalanceViewDesktop();
        }
        return const _NotEnoughBalanceViewMobile();
      }),
    );
  }
}

class _NotEnoughBalanceViewMobile extends StatelessWidget {
  const _NotEnoughBalanceViewMobile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Container(
        padding: const EdgeInsets.all(30),
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
    );
  }
}

class _NotEnoughBalanceViewDesktop extends StatelessWidget {
  const _NotEnoughBalanceViewDesktop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithBackButtonHeader(
      title: 'Send Bitcoin',
      body: Center(
        child: DesktopBodyContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
