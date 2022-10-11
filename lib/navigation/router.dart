import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/dashboard/view/dashboard_screen.dart';
import 'package:genius_wallet/onboarding/routes/landing_routes.dart';
import 'package:go_router/go_router.dart';

final geniusWalletRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Splash(
          onCompletion: '/landing_screen',
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: ((context, state) {
        return const DashboardScreen();
      }),
    ),
    ...LandingRoutes().landingRoutes,
  ],
);
