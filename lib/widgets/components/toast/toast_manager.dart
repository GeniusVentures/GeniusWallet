import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/toast/ticker_provider.dart';
import 'package:genius_wallet/widgets/components/toast/toast_widget.dart';

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();

  factory ToastManager() => _instance;

  ToastManager._internal();

  final List<_ToastEntry> _activeToasts = []; // Track all active toasts
  final Map<OverlayEntry, double> _toastPositions = {}; // Track fixed positions

  void showToast({
    required BuildContext context,
    required String title,
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context);

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

    late OverlayEntry overlayEntry;

    // Determine the position for the new toast
    final topOffset = 80 + (_activeToasts.length * 80.0);

    overlayEntry = OverlayEntry(
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final fixedTopOffset = _toastPositions[overlayEntry] ?? topOffset;

            return Positioned(
              top: fixedTopOffset,
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
                          _removeToast(overlayEntry, animationController,
                              tickerProvider);
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

    // Insert the overlay entry
    overlay.insert(overlayEntry);
    animationController.forward();

    // Track the toast and its position
    _activeToasts.add(_ToastEntry(
      overlayEntry: overlayEntry,
      animationController: animationController,
      tickerProvider: tickerProvider,
    ));
    _toastPositions[overlayEntry] = topOffset;

    // Auto-remove the toast after the specified duration
    Timer(duration, () {
      _removeToast(overlayEntry, animationController, tickerProvider);
      if (onClose != null) onClose();
    });
  }

  void _removeToast(
    OverlayEntry overlayEntry,
    AnimationController animationController,
    ToastTickerProvider tickerProvider,
  ) {
    final toastIndex = _activeToasts.indexWhere(
      (entry) => entry.overlayEntry == overlayEntry,
    );

    if (toastIndex != -1) {
      final toast = _activeToasts[toastIndex];
      _activeToasts.removeAt(toastIndex);
      _toastPositions.remove(toast.overlayEntry);

      if (animationController.isAnimating || animationController.isCompleted) {
        animationController.reverse().then((_) {
          overlayEntry.remove();
          tickerProvider.dispose();
          animationController.dispose();
        });
      } else {
        overlayEntry.remove();
        tickerProvider.dispose();
        animationController.dispose();
      }
    }
  }

  void dispose() {
    for (final entry in _activeToasts) {
      entry.animationController.reverse().then((_) {
        entry.overlayEntry.remove();
        entry.tickerProvider.dispose();
        entry.animationController.dispose();
      }).catchError((_) {
        entry.overlayEntry.remove();
        entry.tickerProvider.dispose();
      });
    }
    _activeToasts.clear();
    _toastPositions.clear();
  }
}

class _ToastEntry {
  final OverlayEntry overlayEntry;
  final AnimationController animationController;
  final ToastTickerProvider tickerProvider;

  _ToastEntry({
    required this.overlayEntry,
    required this.animationController,
    required this.tickerProvider,
  });
}

enum ToastType { success, error, warning }
