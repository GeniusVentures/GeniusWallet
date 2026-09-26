import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory>? _appDataDirectory;

/// The folder for Hive boxes, the SDK tree and its logs, created on first use.
/// An install whose Documents already holds its data stays there, so its
/// wallets never look missing; `wallet.hive` is the app's wallet box.
Future<Directory> appDataDirectory() => _appDataDirectory ??= _resolve();

Future<Directory> _resolve() async {
  try {
    final picked = pickAppDataDirectory(
      documents: await getApplicationDocumentsDirectory(),
      operatingSystem: Platform.operatingSystem,
      environment: Platform.environment,
    );
    return await picked.create(recursive: true);
  } catch (_) {
    // Forget the failure so the next caller retries instead of inheriting it.
    _appDataDirectory = null;
    rethrow;
  }
}

/// Picks the data folder without touching the disk beyond existence checks.
/// Windows and Linux get a local data folder unless Documents already holds
/// the wallet box or the SDK account list; every other OS keeps Documents.
Directory pickAppDataDirectory({
  required Directory documents,
  required String operatingSystem,
  required Map<String, String> environment,
}) {
  final local = _localDataFolder(operatingSystem, environment);
  if (local == null) {
    return documents;
  }
  final existingInstall = ['wallet.hive', 'secure_storage_id'].any(
    (name) =>
        FileSystemEntity.typeSync('${documents.path}/$name') !=
        FileSystemEntityType.notFound,
  );
  if (existingInstall) {
    return documents;
  }
  return Directory(local);
}

String? _localDataFolder(String os, Map<String, String> env) {
  if (os == 'windows') {
    final base = env['LOCALAPPDATA'] ?? '';
    return base.isEmpty ? null : '$base\\GeniusVentures\\GeniusWallet';
  }
  if (os == 'linux') {
    final xdg = env['XDG_DATA_HOME'] ?? '';
    if (xdg.startsWith('/')) {
      return '$xdg/GeniusWallet';
    }
    final home = env['HOME'] ?? '';
    return home.isEmpty ? null : '$home/.local/share/GeniusWallet';
  }
  return null;
}
