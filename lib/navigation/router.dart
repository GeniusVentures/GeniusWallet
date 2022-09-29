import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/landing/routes/landing_routes.dart';
import 'package:go_router/go_router.dart';

final geniusWalletRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Splash(
          onCompletion: '/wallet_creation',
        );
      },
    ),
    ...LandingRoutes().landingRoutes,
  ],
);
