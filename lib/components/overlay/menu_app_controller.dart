import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showDesktopSideMenu = true; // Default to showing side menu

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  bool get showDesktopSideMenu => _showDesktopSideMenu;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void toggleDesktopSideMenu() {
    _showDesktopSideMenu = !_showDesktopSideMenu;
    notifyListeners();
  }

  void setDesktopSideMenu(bool value) {
    _showDesktopSideMenu = value;
    notifyListeners();
  }
}
