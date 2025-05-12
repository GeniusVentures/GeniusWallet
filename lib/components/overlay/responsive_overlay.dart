import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/components/overlay/desktop_overlay.dart';
import 'package:genius_wallet/components/overlay/mobile_overlay.dart';
import 'package:genius_wallet/dashboard/chart/markets_screen.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/news/view/crypto_news_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_screen.dart';
import 'package:genius_wallet/web/web_view_screen.dart';

class ResponsiveOverlay extends StatelessWidget {
  final NavigationScreen? selectedScreen;
  const ResponsiveOverlay({Key? key, this.selectedScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedScreen != null) {
      context.read<NavigationOverlayCubit>().navigationTapped(selectedScreen!);
    }

    return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
      builder: (context, state) {
        final platform = GeniusBreakpoints.getPlaform(context);

        // Map screen enum to actual widget
        final screenMap = <NavigationScreen, Widget>{
          NavigationScreen.dashboard: const DashboardScreen(),
          NavigationScreen.transactions: const TransactionsScreen(),
          NavigationScreen.swap: const SwapScreen(),
          NavigationScreen.news: const CryptoNewsScreen(),
          NavigationScreen.markets: const MarketsScreen(),
          NavigationScreen.web:
              const WebViewScreen(url: "https://app.uniswap.org"),
        };

        final selected = state.selectedScreen;
        final currentIndex = screenMap.keys.toList().indexOf(selected);

        final child = IndexedStack(
          index: currentIndex,
          children: screenMap.values.toList(),
        );

        if (!GeniusBreakpoints.useDesktopOverlay(context) ||
            platform == Platforms.mobile) {
          return MobileOverlay(child: child);
        } else {
          return DesktopOverlay(child: child);
        }
      },
    );
  }
}
