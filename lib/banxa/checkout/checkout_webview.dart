import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Loads Banxa checkout inside the app. The return link and every navigation
/// are judged by the pure rules; the page itself is never trusted.
class CheckoutWebView extends StatefulWidget {
  const CheckoutWebView({
    super.key,
    required this.uri,
    required this.onReturn,
    required this.onLoadError,
  });

  final Uri uri;
  final VoidCallback onReturn;
  final VoidCallback onLoadError;

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;
  // The permission request names no origin, so the last main-frame page
  // stands in for it: a bank or 3-D Secure page never gets the camera.
  late bool _onBanxaPage = isTrustedCheckoutUrl(widget.uri);
  bool _pickedFiles = false;

  @override
  void initState() {
    super.initState();
    var params = const PlatformWebViewControllerCreationParams();
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      // Banxa's liveness step records video and needs it to play inline, with
      // no tap, or WebKit shows it full screen and the step stalls.
      params =
          WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            params,
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const {},
          );
    }
    _controller =
        WebViewController.fromPlatformCreationParams(
            params,
            onPermissionRequest: _onPermissionRequest,
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final uri = Uri.tryParse(request.url);
                if (isBanxaReturn(uri, isMainFrame: request.isMainFrame)) {
                  widget.onReturn();
                  return NavigationDecision.prevent;
                }
                if (!allowsCheckoutNavigation(uri)) {
                  return NavigationDecision.prevent;
                }
                if (request.isMainFrame && uri != null) {
                  _onBanxaPage = isTrustedCheckoutUrl(uri);
                }
                return NavigationDecision.navigate;
              },
              onPageStarted: (url) {
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  _onBanxaPage = isTrustedCheckoutUrl(uri);
                }
              },
              onPageFinished: (_) {
                if (mounted) {
                  setState(() => _loading = false);
                }
              },
              onWebResourceError: (error) {
                if (error.isForMainFrame ?? false) {
                  widget.onLoadError();
                }
              },
            ),
          )
          ..loadRequest(widget.uri);
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      unawaited(platform.setOnShowFileSelector(_pickFiles));
    }
  }

  Future<void> _onPermissionRequest(WebViewPermissionRequest request) async {
    if (!_onBanxaPage || !checkoutPermissionAllowed(request.types)) {
      await request.deny();
      return;
    }
    if (_controller.platform is AndroidWebViewController) {
      final results = await androidPermissionsFor(
        request.types,
      ).toList().request();
      // The OS prompt can outlive the page that triggered it.
      if (!_onBanxaPage || !results.values.every((s) => s.isGranted)) {
        await request.deny();
        return;
      }
    }
    await request.grant();
  }

  Future<List<String>> _pickFiles(FileSelectorParams params) async {
    if (!_onBanxaPage) {
      return const [];
    }
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'heic', 'pdf'],
      allowMultiple: params.mode == FileSelectorMode.openMultiple,
    );
    if (result == null) {
      return const [];
    }
    _pickedFiles = true;
    return [
      for (final file in result.files)
        if (file.path != null) Uri.file(file.path!).toString(),
    ];
  }

  @override
  void dispose() {
    if (_pickedFiles) {
      unawaited(clearPickedIdFiles(Platform.operatingSystem));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const Center(child: Loading()),
      ],
    );
  }
}
