// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();

  factory DeepLinkService() => _instance;

  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void startListening(GlobalKey<NavigatorState> navigatorKey) {
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) _handleUri(uri, navigatorKey);
      },
      onError: (err) => debugPrint("DeepLink error: $err"),
    );
  }

  void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    debugPrint('🧭 Received deep link: $uri');

    Future.microtask(() {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final host = uri.host;
        final path = uri.path;
        final query = uri.query;

        String fullPath = '/$host$path';
        if (query.isNotEmpty) fullPath += '?$query';

        debugPrint('📍 Navigating to: $fullPath');
        GoRouter.of(context).go(fullPath);
      } else {
        debugPrint("⚠️ Navigator context is null, can't navigate.");
      }
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}
