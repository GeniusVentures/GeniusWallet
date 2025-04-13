import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';

class ToastNavigatorObserver extends NavigatorObserver {
  final ToastManager toastManager;

  ToastNavigatorObserver(this.toastManager);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    toastManager.dispose(); // Close active toast
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    toastManager.dispose(); // Close active toast
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    toastManager.dispose(); // Close active toast
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    toastManager.dispose(); // Close active toast
  }
}
