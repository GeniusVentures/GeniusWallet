// SHADOW-NAMES: this file declares `class Splash`, the SAME class name as
// `lib/screens/splash.dart` -- develop's canonical boot splash, still routed
// from `lib/navigation/router.dart:30`. The canonical is a `StatelessWidget`;
// this shadow is a `StatefulWidget`. Alex's source branch DELETED
// `lib/screens/splash.dart` entirely, so it presents this file as a completed
// move -- it is not. This port does not delete, move, or edit the canonical,
// and does not repoint `router.dart`. Migrating the app's boot screen to this
// class is a deliberate act that must update
// `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` and re-run
// `tool/verify_additive_boundary.sh` in the same commit. See
// `03-SHADOW-NAMES.md` for the full hazard writeup.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
// NOTE: the reference worktree imports the `Loading` SHADOW
// (`components/loading/loading.dart`) here. Per
// `03-SHADOW-NAMES.md`, that shadow's only permitted importer is
// `lib/dev/design_gallery_screen.dart` -- this file may not add a second one,
// even though it is itself a shadow. Repointed to develop's canonical
// `components/loading.dart`, which declares the same class with an identical
// `{String? text}` constructor, so the `const Loading()` call site below is
// unchanged.
import 'package:genius_wallet/components/loading.dart';
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
      if (!mounted) {
        return;
      }
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
          // Defer navigation out of the build/listener phase. If wallet status
          // resolves synchronously (e.g. the UI-only stub backend), the bloc
          // emits `loaded` while a frame is building, and calling context.go
          // then marks the router dirty mid-build -> "!_dirty" red screen.
          final target = state.wallets.isEmpty
              ? '/landing_screen'
              : '/dashboard';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(target);
            }
          });
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
