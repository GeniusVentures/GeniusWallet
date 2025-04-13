import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';

class NavigationOverlayCubit extends Cubit<NavigationOverlayState> {
  final NavigationOverlayState initialState;
  NavigationOverlayCubit({
    this.initialState = const NavigationOverlayState(),
  }) : super(initialState);

  void navigationTapped(NavigationScreen selectedScreen) {
    emit(state.copyWith(selectedScreen: selectedScreen));
  }

  void selectNavigation(NavigationScreen screen) {
    emit(state.copyWith(selectedScreen: screen));
  }

  void setVisibility({
    bool? displayDesktopOverlay,
    bool? displayMobileOverlay,
  }) {
    emit(state.copyWith(
      displayDesktopOverlay: displayDesktopOverlay,
      displayMobileOverlay: displayMobileOverlay,
    ));
  }
}
