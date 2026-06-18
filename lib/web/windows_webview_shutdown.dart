typedef WindowsWebViewDisposer = Future<void> Function();

class WindowsWebViewShutdown {
  WindowsWebViewShutdown._();

  static final WindowsWebViewShutdown instance = WindowsWebViewShutdown._();

  final Set<WindowsWebViewDisposer> _disposers = <WindowsWebViewDisposer>{};
  Future<void>? _disposeAllFuture;

  bool get hasActiveWebViews => _disposers.isNotEmpty;

  void register(WindowsWebViewDisposer disposer) {
    _disposers.add(disposer);
  }

  void unregister(WindowsWebViewDisposer disposer) {
    _disposers.remove(disposer);
  }

  Future<void> disposeAll() {
    final inFlight = _disposeAllFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _disposeAllInternal();
    _disposeAllFuture = future;
    return future.whenComplete(() {
      if (identical(_disposeAllFuture, future)) {
        _disposeAllFuture = null;
      }
    });
  }

  Future<void> _disposeAllInternal() async {
    final disposers = List<WindowsWebViewDisposer>.from(_disposers);
    for (final disposer in disposers) {
      await disposer();
    }
  }
}
