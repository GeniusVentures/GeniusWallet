import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.subscribeToWalletStatus == AppStatus.loaded) {
          // Defer navigation out of the listener phase: if wallet status
          // resolves synchronously the bloc emits `loaded` while a frame is
          // building, and calling context.go then marks the router dirty
          // mid-build -> "!_dirty" red screen.
          final target = state.wallets.isEmpty ? '/landing_screen' : '/dashboard';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(target);
          });
        }
      },
      child: Scaffold(
        backgroundColor: GeniusWalletColors.surfaceBase,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
    );
  }
}
