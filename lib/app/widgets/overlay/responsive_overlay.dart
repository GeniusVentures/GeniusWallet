import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/overlay/desktop_overlay.dart';
import 'package:genius_wallet/app/widgets/overlay/mobile_overlay.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/chart/markets_screen.dart';
import 'package:genius_wallet/dashboard/events/view/events_screen.dart';
import 'package:genius_wallet/dashboard/home/view/home_screen.dart';
import 'package:genius_wallet/dashboard/news/view/news_screen.dart';
import 'package:genius_wallet/dashboard/trade/view/trade_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_screen.dart';
import 'package:genius_wallet/wallets/view/wallets_screen.dart';
import 'package:genius_wallet/web/web_view_screen.dart';

/// Widget that adds a navigation overlay according to the platform and size of the screen.
class ResponsiveOverlay extends StatelessWidget {
  final NavigationScreen? selectedScreen;
  const ResponsiveOverlay({Key? key, this.selectedScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedScreen != null) {
      context
          .read<NavigationOverlayCubit>()
          .navigationTapped(NavigationScreen.values.indexOf(selectedScreen!));
    }
    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        final platform = GeniusBreakpoints.getPlaform(context);
        Widget child;

        switch (state.selectedScreen) {
          case NavigationScreen.wallets:
            child = const WalletsScreen();
            break;
          case NavigationScreen.transactions:
            child = const TransactionsScreen();
            break;
          case NavigationScreen.news:
            child = const NewsScreen();
            break;
          case NavigationScreen.markets:
            child = MarketsScreen();
            break;
          case NavigationScreen.events:
            child = const EventsScreen();
            break;
          case NavigationScreen.trade:
            child = const TradeScreen();
            break;
          case NavigationScreen.settings:
            child = const Center(child: Text('Coming soon'));
            break;
          case NavigationScreen.web:
            child = const WebViewScreen(url: "https://www.gnus.ai/");
            break;
          case NavigationScreen.dashboard:
          default:
            child = const HomeScreen();
        }

        if (!GeniusBreakpoints.useDesktopLayout(context) ||
            platform == Platforms.mobile) {
          return MobileOverlay(child: child);
        } else {
          return DesktopOverlay(child: child);
        }
      },
    );
  }
}
