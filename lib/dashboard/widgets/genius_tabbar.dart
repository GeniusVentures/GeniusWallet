import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genius_wallet/dashboard/cubit/bottom_navigation_bar_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class GeniusTabbar extends StatelessWidget {
  const GeniusTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: GeniusWalletColors.blue500,
            width: 2,
          ),
        ),
      ),
      child: BottomNavigationBar(
        onTap: context.read<BottomNavigationBarCubit>().tabTapped,
        currentIndex:
            context.watch<BottomNavigationBarCubit>().state.navbarItem.index,
        backgroundColor: GeniusWalletColors.gray800,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/bxsdashboard.svg',
              package: 'genius_wallet',
            ),
            label: 'Dashboard',
            activeIcon: SvgPicture.asset(
              'assets/images/dashboardiconactive.svg',
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/walleticon.svg',
              package: 'genius_wallet',
            ),
            activeIcon: Image.asset('assets/images/walleticonactive.png'),
            label: 'Wallets',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/transactioniconinactive.svg',
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/ribookletfill.svg',
              package: 'genius_wallet',
            ),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/group18.svg',
              package: 'genius_wallet',
            ),
            activeIcon: Image.asset('assets/images/tradeiconactive.png'),
            label: 'Trade',
          ),
        ],
      ),
    );
  }
}
