import 'package:flutter/material.dart';

class DevToolsState {
  static final DevToolsState _instance = DevToolsState._internal();

  factory DevToolsState() => _instance;

  DevToolsState._internal();

  final ValueNotifier<bool> showDevTools = ValueNotifier(false);
}
