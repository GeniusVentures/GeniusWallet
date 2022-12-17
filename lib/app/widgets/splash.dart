import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

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
        body: AppScreenView(
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Image.asset(
                'assets/images/logo_and_title.png',
                package: 'genius_wallet',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
