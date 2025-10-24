import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/handle_banxa_redirect.dart';
import 'package:genius_wallet/components/loading/loading.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyGnusScreen extends StatelessWidget {
  final String checkoutUrl;

  const BuyGnusScreen({super.key, required this.checkoutUrl});

  @override
  Widget build(BuildContext context) {
    final TransactionsCubit transactionsCubit =
        context.read<TransactionsCubit>();

    if (Platform.isLinux) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openBanxaInBrowser(checkoutUrl);
        Navigator.of(context).pop();
      });

      return const Scaffold(
        body: Center(child: Text('Launching Banxa checkout in browser...')),
      );
    }

    if (Platform.isWindows) {
      final controller = WebviewController();
      return FutureBuilder(
        future: controller.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: Loading()),
            );
          }

          controller.loadUrl(checkoutUrl);

          /// Listen to the url to respond to successful / cancelled purchases
          controller.url.listen((uri) {
            handleBanxaRedirect(
                context: context,
                uri: uri,
                transactionsCubit: transactionsCubit);
          });

          return Scaffold(
            appBar: AppBar(),
            body: Webview(controller),
          );
        },
      );
    }

    // Mobile
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (urlChange) {
            // TODO: VALIDATE URL FOR BANXA REDIRECTS
            handleBanxaRedirect(
              context: context,
              uri: urlChange.url!,
              transactionsCubit: transactionsCubit,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));

    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: controller),
    );
  }
}

/// No way to listen or handle the URL on Linux, so no nice flow for buying on Linux
void _openBanxaInBrowser(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
