import 'package:flutter_bloc/flutter_bloc.dart';

part 'bottom_navigation_bar_state.dart';

class BottomNavigationBarCubit extends Cubit<BottomNavigationBarState> {
  BottomNavigationBarCubit()
      : super(const BottomNavigationBarState(
          navbarItem: NavbarItem.dashboard,
        ));

  void tabTapped(int index) {
    emit(state.copyWith(navbarItem: NavbarItem.values[index]));
  }
}
