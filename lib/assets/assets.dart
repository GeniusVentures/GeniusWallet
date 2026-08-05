import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String?> safeLoadAsset(String path) async {
  try {
    return await rootBundle.loadString(path);
  } catch (e) {
    debugPrint('$e');
    return null;
  }
}
