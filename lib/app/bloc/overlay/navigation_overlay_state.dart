class NavigationOverlayState {
  final NavigationScreen selectedScreen;
  final bool displayDesktopOverlay;
  final bool displayMobileOverlay;
  const NavigationOverlayState({
    this.selectedScreen = NavigationScreen.dashboard,
    this.displayDesktopOverlay = false,
    this.displayMobileOverlay = false,
  });

  NavigationOverlayState copyWith({
    NavigationScreen? selectedScreen,
    bool? displayDesktopOverlay,
    bool? displayMobileOverlay,
  }) {
    return NavigationOverlayState(
      selectedScreen: selectedScreen ?? this.selectedScreen,
      displayDesktopOverlay:
          displayDesktopOverlay ?? this.displayDesktopOverlay,
      displayMobileOverlay: displayMobileOverlay ?? this.displayMobileOverlay,
    );
  }
}

// This order determines what screen to select on when clicking on the navigation rail, this order must match the order in `destinations`
enum NavigationScreen {
  dashboard,
  wallets,
  transactions,
  trade,
  web,
  markets,
  calculator,
  news,
  events,
  settings
}
