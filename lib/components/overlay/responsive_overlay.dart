import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/components/overlay/desktop_overlay.dart';
import 'package:genius_wallet/components/overlay/mobile_overlay.dart';
import 'package:genius_wallet/dashboard/chart/markets_screen.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/news/view/crypto_news_screen.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/web/web_view_screen.dart';

class ResponsiveOverlay extends StatelessWidget {
  final NavigationScreen? selectedScreen;
  const ResponsiveOverlay({Key? key, this.selectedScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedScreen != null) {
      context.read<NavigationOverlayCubit>().navigationTapped(selectedScreen!);
    }

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>(
          builder: (context, navState) {
            final platform = GeniusBreakpoints.getPlaform(context);

            final screenMap = <NavigationScreen, Widget>{
              NavigationScreen.dashboard: const DashboardScreen(),
              NavigationScreen.transactions: const TransactionsScreen(),
              NavigationScreen.swap: const SwapScreen(),
              NavigationScreen.news: const CryptoNewsScreen(),
              NavigationScreen.markets: const MarketsScreen(),
              NavigationScreen.web:
                  const WebViewScreen(url: "https://app.uniswap.org"),
            };

            final selected = navState.selectedScreen;
            final currentIndex = screenMap.keys.toList().indexOf(selected);

            final content = IndexedStack(
              index: currentIndex,
              children: screenMap.values.toList(),
            );

            final overlay = (!GeniusBreakpoints.useDesktopOverlay(context) ||
                    platform == Platforms.mobile)
                ? MobileOverlay(child: content)
                : DesktopOverlay(child: content);

            return Stack(
              children: [
                overlay,
                if (appState.isProcessing)
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: Colors.black.withAlpha(115),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Loading(),
                              SizedBox(height: 12),
                              Text(
                                'Genius Wallet is processing…',
                                
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
