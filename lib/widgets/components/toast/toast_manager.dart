import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/toast/ticker_provider.dart';
import 'package:genius_wallet/widgets/components/toast/toast_widget.dart';

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();

  factory ToastManager() => _instance;

  ToastManager._internal();

  OverlayEntry? _currentOverlayEntry; // Track the active toast
  AnimationController? _currentAnimationController; // Track the animation
  ToastTickerProvider? _currentTickerProvider; // Track the ticker provider
  Timer? _currentTimer; // Track the auto-dismiss timer

  void showToast({
    required BuildContext context,
    required String title,
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context);

    // Close any existing toast
    _dismissCurrentToast();

    // Create a TickerProvider
    final tickerProvider = ToastTickerProvider();

    // Create an AnimationController
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: tickerProvider,
    );

    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Positioned(
              top: 80,
              left: isMobile ? 0 : null,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Align(
                  alignment: isMobile ? Alignment.center : Alignment.topRight,
                  child: SizedBox(
                    width: isMobile ? double.infinity : 600,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: ToastWidget(
                        title: title,
                        message: message,
                        type: type,
                        onDismiss: () {
                          _dismissCurrentToast();
                          if (onClose != null) onClose();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(overlayEntry);
    animationController.forward();

    _currentOverlayEntry = overlayEntry;
    _currentAnimationController = animationController;
    _currentTickerProvider = tickerProvider;

    _currentTimer = Timer(duration, () {
      _dismissCurrentToast();
      if (onClose != null) onClose();
    });
  }

  void _dismissCurrentToast() {
    _currentTimer?.cancel();
    _currentTimer = null;

    if (_currentAnimationController != null) {
      _currentAnimationController!.reverse().then((_) {
        _currentOverlayEntry?.remove();
        _currentTickerProvider?.dispose();
        _currentAnimationController?.dispose();

        _currentOverlayEntry = null;
        _currentAnimationController = null;
        _currentTickerProvider = null;
      });
    }
  }

  void dispose() {
    _dismissCurrentToast();
  }
}

enum ToastType { success, error, warning }
