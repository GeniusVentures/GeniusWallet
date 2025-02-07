import 'package:flutter/services.dart';

Future<String?> safeLoadAsset(String path) async {
  try {
    return await rootBundle.loadString(path);
  } catch (e) {
    print(e);
    return null;
  }
}
