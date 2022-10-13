import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/cubit/bottom_navigation_bar_cubit.dart';
import 'package:genius_wallet/dashboard/home/view/home_screen.dart';
import 'package:genius_wallet/dashboard/widgets/genius_tabbar.dart';
import 'package:genius_wallet/dashboard/trade/view/trade_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_screen.dart';
import 'package:genius_wallet/dashboard/wallets/view/wallets_screen.dart';

class DashboardScreen extends StatelessWidget {
  final NavbarItem? initialItem;
  const DashboardScreen({
    Key? key,
    this.initialItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BottomNavigationBarCubit(initialItem: initialItem),
      child: Scaffold(
        bottomNavigationBar: const GeniusTabbar(),
        body: BlocBuilder<BottomNavigationBarCubit, BottomNavigationBarState>(
          builder: (context, state) {
            switch (state.navbarItem) {
              case NavbarItem.trade:
                return const TradeScreen();
              case NavbarItem.transactions:
                return const TransactionsScreen();
              case NavbarItem.wallets:
                return const WalletsScreen();
              case NavbarItem.dashboard:
              default:
                return const HomeScreen();
            }
          },
        ),
      ),
    );
  }
}
