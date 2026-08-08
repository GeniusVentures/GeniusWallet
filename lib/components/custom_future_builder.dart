import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class FutureStateWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) onData;
  final Widget? loading;
  final Widget? error;
  final VoidCallback? onRetry;

  const FutureStateWidget({
    super.key,
    required this.future,
    required this.onData,
    this.loading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const Center(child: Loading());
        } else if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showToast(context, 'Error: ${snapshot.error}');
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                error ??
                    Icon(
                      Icons.error_outline,
                      color: context.gw.statusError,
                      size: 48,
                    ),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  GWButton(
                    onPressed: onRetry,
                    label: "Retry",
                    variant: GWButtonVariant.primary,
                    leading: const Icon(Icons.refresh),
                  ),
                ],
              ],
            ),
          );
        } else if (snapshot.hasData) {
          return onData(snapshot.data as T);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
