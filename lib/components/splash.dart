import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final state = context.read<AppBloc>().state;
      if (state.subscribeToWalletStatus != AppStatus.loaded) {
        context.go('/landing_screen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.subscribeToWalletStatus == AppStatus.loaded) {
          if (state.wallets.isEmpty) {
            context.go('/landing_screen');
          } else {
            context.go('/dashboard');
          }
        }
      },
      child: Scaffold(
        backgroundColor: GeniusWalletColors.deepBlue,
        body: AppScreenView(
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_and_title.png',
                  package: 'genius_wallet',
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: GeniusWalletConsts.space12),
                const Loading(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
