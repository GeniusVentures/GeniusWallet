import 'package:flutter/material.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/feedback/gw_loading_state.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';

class FutureStateWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) onData;
  final Widget? loading;
  final Widget? error;
  final VoidCallback? onRetry;
  final String? errorTitle;
  final String? errorMessage;
  final bool Function(T data)? isEmpty;
  final Widget? emptyState;
  final bool showErrorSnackBar;

  const FutureStateWidget({
    Key? key,
    required this.future,
    required this.onData,
    this.loading,
    this.error,
    this.onRetry,
    this.errorTitle,
    this.errorMessage,
    this.isEmpty,
    this.emptyState,
    this.showErrorSnackBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const GWLoadingState();
        } else if (snapshot.hasError) {
          if (showErrorSnackBar) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              showAppSnackBar(context, 'Error: ${snapshot.error}');
            });
          }
          return error ??
              GWErrorState(
                title: errorTitle ?? 'Something went wrong',
                message: errorMessage ?? snapshot.error?.toString(),
                onRetry: onRetry,
              );
        } else if (snapshot.hasData) {
          final data = snapshot.data as T;
          if (isEmpty != null && isEmpty!(data)) {
            return emptyState ??
                const GWEmptyState(title: 'Nothing to show yet');
          }
          return onData(data);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
