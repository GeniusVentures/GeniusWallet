// Manages closing the toasts if a user navigates
import 'package:flutter/widgets.dart';
import 'package:genius_wallet/widgets/components/toast/toast_manager.dart';

class ToastNavigatorObserver extends NavigatorObserver {
  final ToastManager toastManager;

  ToastNavigatorObserver(this.toastManager);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    toastManager.dispose(); // Close any active toast
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    toastManager.dispose(); // Close any active toast
  }
}
