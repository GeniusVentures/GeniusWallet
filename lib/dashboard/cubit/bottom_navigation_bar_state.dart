part of 'bottom_navigation_bar_cubit.dart';

class BottomNavigationBarState {
  final NavbarItem navbarItem;

  const BottomNavigationBarState({
    required this.navbarItem,
  });

  BottomNavigationBarState copyWith({
    NavbarItem? navbarItem,
  }) {
    return BottomNavigationBarState(
      navbarItem: navbarItem ?? this.navbarItem,
    );
  }
}

enum NavbarItem { dashboard, wallets, transactions, trade }
