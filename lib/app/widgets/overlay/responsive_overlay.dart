import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/overlay/desktop_overlay.dart';
import 'package:genius_wallet/app/widgets/overlay/mobile_overlay.dart';
import 'package:genius_wallet/calculator/view/calculator_screen.dart';
import 'package:genius_wallet/dashboard/home/view/home_screen.dart';
import 'package:genius_wallet/dashboard/trade/view/trade_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_screen.dart';
import 'package:genius_wallet/dashboard/wallets/view/wallets_screen.dart';
import 'package:genius_wallet/markets/view/markets_screen.dart';

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
            child = const Center(child: Text('Coming soon'));
            break;
          case NavigationScreen.markets:
            child = const MarketsScreen();
            break;
          case NavigationScreen.events:
            child = const Center(child: Text('Coming soon'));
            break;
          case NavigationScreen.calculator:
            child = const CalculatorScreen();
            break;
          case NavigationScreen.trade:
            child = const TradeScreen();
            break;
          case NavigationScreen.dashboard:
          default:
            child = const HomeScreen();
        }

        if (platform == Platforms.mobile) {
          return MobileOverlay(child: child);
        } else if (platform == Platforms.desktop) {
          return DesktopOverlay(child: child);
        }
        return child;
      },
    );
  }
}
