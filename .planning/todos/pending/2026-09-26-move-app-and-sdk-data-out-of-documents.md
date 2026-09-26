---
created: 2026-09-26T17:30:00.000Z
title: Windows/Linux keep the app's and the SDK's data loose in the user's Documents folder
area: storage
files:
  - packages/genius_api/lib/src/genius_api.dart
  - lib/hive/init.dart
  - lib/main.dart
---

## Problem

`prepareConfigFiles()` uses `getApplicationDocumentsDirectory()` as the SDK base path and
`Hive.initFlutter()` uses the same folder, so on Windows the node databases
(`SuperGNUSNode.Node.*`), `secure_storage_id`, `my_tasks.json`, `ipfs_cache/`, sgns logs, config
JSONs and every app `.hive`/`.lock` box sit directly in `C:\Users\<user>\Documents`. Only Windows
and Linux are affected: Android/iOS/macOS resolve Documents to an app-private location.

## Why it is its own phase

Braian chose (2026-09-26) to plan this properly rather than patch it:
- the move must run in `main.dart` before Hive opens and hand the folder to `GeniusApi`;
- the SDK writes more files than the obvious list (`my_tasks.json`, `ipfs_cache/`, `.old.log`s,
  a legacy secure-storage JSON), so "move known names" can silently leave data behind;
- Windows refuses renames of open files, and two first-upgrade instances would race without a lock;
- a partial move needs a rollback path;
- target folder is a product call: app-support on Windows is the ROAMING profile
  (`%APPDATA%\com.example\genius_wallet`), which would roam node databases; local AppData is likely right;
- `.planning/reference/FRESH-INSTALL-RECIPE.md` hardcodes the Documents paths.

SDK private keys are NOT in Documents (Credential Manager / Keychain / KeyStore), only the
public-key account list, so the move is data-safety work, not key-custody work.
