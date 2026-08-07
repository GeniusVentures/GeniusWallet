import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/effects/gw_mesh_background.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/screens/boot_sequence.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// Pinned dark canvas for the boot screen (sketch 015 "Signal Edge", 13-CONTEXT
/// D8). This screen must render IDENTICALLY in both app themes -- the logo is a
/// white wordmark that vanishes on a light surface. `GeniusWalletColors.surfaceBase`
/// is the nearest token but it is a mode-FLIPPING getter, so a literal is used
/// here instead: one consumer, no shared token warranted.
// ── Boot canvas depth — sketch 020, variant G ("Ember") ────────────────────
//
// The default mesh (intensity 1.0) walked too bright on 2026-07-22: the boot
// canvas read much lighter than the dashboard it hands over to, so the
// handover landed as a visible brightness DROP.
//
// `intensity` alone cannot fix that — in `_MeshPainter` it scales the blob
// alpha (110x) AND the black dim overlay (38x) together, so lowering it makes
// the field paler rather than deeper. Hence the separate `dimAlpha`.
//
// Variant G keeps the base BELOW the dashboard's own `#0B0D12`, so the
// handover brightens slightly instead of dimming, and lets a little more brand
// colour survive than C did (blob alpha 110*0.40 vs 110*0.30) under a slightly
// heavier overlay. Chosen on 2026-07-22 after walking C and G back to back on
// real builds — C read too neutral, G keeps the teal legible without the
// original's brightness clash.
//
// NOTE: sketch 020's HTML UNDERSTATED how bright these values render — its CSS
// blobs were far more contained than `_MeshPainter`'s, which uses a radius of
// `maxDim * 0.95` and fills the WHOLE rect. These numbers were settled on the
// live app, not from the mock. Trust this file over that sketch.
//
// All three values live here, not on the component: `GWMeshBackground` is
// shared with `wallet_creation_screen.dart` (Phase 6, in progress), and
// `dimAlpha: null` there preserves its previous rendering exactly.
// dimAlpha 235 (not sketch 020's 120) is the value that was actually walked and
// approved on 2026-07-22. It first shipped by accident, as a diagnostic probe to
// prove the parameter reached the painter — and that build was the one that read
// right. At 235 the overlay keeps ~92% of the blob colour suppressed, so the
// brand hues survive only as a faint cast on a near-black field. Sketch 020's
// numbers are NOT trustworthy here; see the note above.
const Color _kBootCanvas = Color(0xFF06070B);
const double _kBootMeshIntensity = 0.40;
const int _kBootMeshDim = 235;

/// The routed boot screen (navigation/router.dart:30 -> the ONE canonical
/// importer of this path). `lib/components/splash.dart` is a same-named
/// shadow class and stays dead -- see 13-CONTEXT.md H1.
///
/// Composition: `Scaffold` -> `GWMeshBackground` (explicit pinned [_kBootCanvas]
/// baseColor, defeating its mode-flipping default) -> a `Stack` of a centred,
/// constrained logo and a bottom-anchored status kicker + gradient rail.
///
/// The ~9.6s native SDK freeze (13-CONTEXT M1) means nothing on this screen can
/// animate until it lifts -- so nothing here promises motion. Once
/// `subscribeToWalletStatus` and `accountStatus` have both settled, this drives
/// [BootSequence] (13-02) through three truthful confirmations while the real
/// boot work (markets, chart, and the coins/holdings read) runs in parallel,
/// then hands over to `/dashboard`.
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final BootSequence _bootSequence = BootSequence();

  // One-shot guard: AppBloc's listener can fire more than once while both
  // statuses settle, and the closing run must start exactly once.
  bool _closingRunStarted = false;

  String _statusText = 'Preparing your wallet…';
  double _railTarget = 0;
  Duration _railDuration = Duration.zero;

  void _onStage(BootStage stage, double railTarget, Duration railDuration) {
    if (!mounted) {
      return;
    }
    setState(() {
      _railTarget = railTarget;
      _railDuration = railDuration;
      _statusText = switch (stage) {
        BootStage.preparing => 'Preparing your wallet…',
        BootStage.walletsReady => 'Wallets ready',
        BootStage.balancesReady => 'Balances ready',
        BootStage.marketsReady => 'Markets ready',
      };
    });
  }

  void _startClosingRun() {
    if (_closingRunStarted) {
      return;
    }
    _closingRunStarted = true;

    // Kick off the REAL work now, in parallel with the timed stages -- D7
    // requires the minimum hold to COVER this work, not precede it. This
    // warms the same Hive cache MarketsDashboardView and CryptoLiveChart read
    // on mount (13-04), letting their own loaders be deleted.
    //
    // The coins/holdings leg (getCoins()) does NOT get its own timeout here:
    // 13-01 measured it settling `successful` in all four cold starts
    // (9558/9207/9556ms connected, 137ms offline), its own work is ~137ms when
    // unmasked by the freeze, and its network calls are already bounded by
    // coin_gecko_api.dart's shared 3s requestTimeout. A second timeout would
    // be unrequested complexity on an already-bounded, already-succeeding path.
    final walletDetailsCubit = context.read<WalletDetailsCubit>();
    final Future<void> work = Future.wait<dynamic>([
      getDashboardMarketCoins(),
      fetchHistoricalPrices('bitcoin'),
      Future.sync(() => walletDetailsCubit.getCoins()),
    ]);

    unawaited(_runClosingSequence(work));
  }

  Future<void> _runClosingSequence(Future<void> work) async {
    await _bootSequence.run(
      onStage: _onStage,
      work: work,
      isLive: () => mounted,
    );
    if (!mounted) {
      return;
    }
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.subscribeToWalletStatus != AppStatus.loaded) {
          return;
        }

        if (state.wallets.isEmpty) {
          // A fresh/wallet-less profile has no balances and nothing true to
          // confirm (D6) -- straight to landing, no closing run.
          context.go('/landing_screen');
          return;
        }

        // Start the run once the account has SETTLED either way. Waiting on
        // `loaded` alone would hang the splash forever on an account error --
        // the dashboard already has its own error branch with a Retry button
        // (dashboard_screen.dart), so handing over on a settled-but-failed
        // account is correct and a permanent splash is not.
        final accountSettled =
            state.accountStatus == AppStatus.loaded ||
            state.accountStatus == AppStatus.error;
        if (accountSettled) {
          _startClosingRun();
        }
      },
      child: Scaffold(
        // Pins the one frame before the mesh paints so it is never a light
        // flash -- same literal as GWMeshBackground's baseColor below.
        backgroundColor: _kBootCanvas,
        body: GWMeshBackground(
          baseColor: _kBootCanvas,
          intensity: _kBootMeshIntensity,
          dimAlpha: _kBootMeshDim,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: GeniusBreakpoints.small * 2 / 3,
                    ),
                    child: Image.asset(
                      'assets/images/logo_and_title.png',
                      package: 'genius_wallet',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                // The boot screen had NO SafeArea at all, so the 2px progress
                // rail below sat on the physical screen edge -- under the home
                // indicator and inside the corner radius on a notched iPhone
                // (reported 2026-08-06 from Sidney). `top: false` leaves the
                // centred logo alone; `minimum` is a FLOOR, not an addition, so
                // a device with no gesture handle (viewPadding.bottom == 0)
                // still clears the edge by one 4-pt step instead of nothing.
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(
                    bottom: GeniusWalletConsts.space6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          GeniusWalletConsts.space10,
                          0,
                          GeniusWalletConsts.space10,
                          GeniusWalletConsts.space6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'STATUS',
                              style: GeniusWalletTypography.labelMd.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 13 * 0.16,
                                // A literal, not `textPrimary38` -- that token
                                // flips with appearance (D2/D8). Alpha raised
                                // 0.38 -> 0.85 (walk 13-03, variant C): the 38%
                                // kicker faded into bright mesh blobs; Jakub chose
                                // the loud, first-read weight.
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(width: GeniusWalletConsts.space6),
                            Flexible(
                              child: Text(
                                _statusText,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                // bodySm already bakes the const `textSecondary`
                                // colour -- passed explicitly anyway so the
                                // safety is visible at the call site rather
                                // than inherited from a default that could
                                // change.
                                style: GeniusWalletTypography.bodySm.copyWith(
                                  color: context.gw.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Track -- kept per the approved sketch's `.rail`
                                // background; without it the rail's own extent
                                // is invisible at zero.
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: _railTarget,
                                  ),
                                  duration: _railDuration,
                                  builder: (context, value, child) => Container(
                                    width: constraints.maxWidth * value,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          context.gw.brandPrimary,
                                          context.gw.brandSecondary,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
