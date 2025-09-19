import 'package:flutter/material.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';

class FutureStateWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) onData;
  final Widget? loading;
  final Widget? error;
  final VoidCallback? onRetry;

  const FutureStateWidget({
    Key? key,
    required this.future,
    required this.onData,
    this.loading,
    this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const Center(child: Loading());
        } else if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAppSnackBar(context, 'Error: ${snapshot.error}');

          
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                error ?? const Icon(Icons.error, color: Colors.red, size: 48),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text("Retry"),
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
