import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';

class NavigationOverlayCubit extends Cubit<NavigationOverlayState> {
  final NavigationOverlayState initialState;
  NavigationOverlayCubit({
    this.initialState = const NavigationOverlayState(),
  }) : super(initialState);

  void navigationTapped(int index) {
    emit(state.copyWith(selectedScreen: NavigationScreen.values[index]));
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
