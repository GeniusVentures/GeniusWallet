import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/dashboard/cubit/bottom_navigation_bar_cubit.dart';
import 'package:genius_wallet/dashboard/view/dashboard_screen.dart';
import 'package:genius_wallet/onboarding/routes/landing_routes.dart';
import 'package:go_router/go_router.dart';

final geniusWalletRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // return const DashboardScreen(initialItem: NavbarItem.dashboard);
        return const Splash(
          onCompletion: '/landing_screen',
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: ((context, state) {
        return const DashboardScreen(initialItem: NavbarItem.dashboard);
      }),
    ),
    GoRoute(
      path: '/wallets',
      builder: ((context, state) {
        return const DashboardScreen(initialItem: NavbarItem.wallets);
      }),
    ),
    GoRoute(
      path: '/transactions',
      builder: ((context, state) {
        return const DashboardScreen(initialItem: NavbarItem.transactions);
      }),
    ),
    GoRoute(
      path: '/trade',
      builder: ((context, state) {
        return const DashboardScreen(initialItem: NavbarItem.trade);
      }),
    ),
    ...LandingRoutes().landingRoutes,
  ],
);
