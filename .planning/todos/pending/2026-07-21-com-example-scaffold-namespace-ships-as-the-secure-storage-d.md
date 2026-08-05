---
created: 2026-07-21T17:46:37.483Z
title: com.example scaffold namespace ships as the secure-storage data directory
area: general
severity: minor-but-shipping
files:
  - windows/runner/Runner.rc
---

## Problem

`windows/runner/Runner.rc` still carries the Flutter scaffold defaults:
`CompanyName "com.example"`, `ProductName "genius_wallet"`, `InternalName "genius_wallet"`.

Consequence: a released crypto wallet stores **seeds, private keys and PIN** under
`%APPDATA%\com.example\genius_wallet\`. Three problems: it is a placeholder namespace in shipped
software; it is effectively undiscoverable to a user trying to find or back up their own data; and it
**collides with any other Flutter app that also never changed the default** (verified: two other apps
on this machine keep their own `flutter_secure_storage.dat` under vendor-named folders, so the
convention is real and `com.example` is the unclaimed bucket).

**Severity note:** this is not by itself a vulnerability — the file is still per-user and subject to
normal filesystem ACLs. It is a shipping-hygiene and data-ownership problem, not a security hole.

## Solution

Change `CompanyName`/`ProductName` in `windows/runner/Runner.rc` to a real vendor namespace.

**Warning:** changing `CompanyName`/`ProductName` **moves the data directory**, so existing users'
wallets would appear to vanish. Any fix needs a migration (read from the old path, write to the new,
or read-both-write-new), or it must ship in a release where that is explicitly handled. This is the
kind of change that looks trivial and destroys user data — do not ship it without a migration path.
