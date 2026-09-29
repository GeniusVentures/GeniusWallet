import 'dart:async';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';

// DEV-ONLY: makes every child-wallet state reachable with no registered
// child and no live node. Before this fixture existed, walking the empty,
// populated, node-not-running and query-failure branches of
// `ChildWalletsCubit` needed a real registration on a real testnet node -
// `GENIUS_NODE_ERROR_REGISTRATION` in particular has no reachable trigger
// from the UI at all. Read behind `kDebugMode && kShowDevTools` at exactly
// one call site - see `ChildWalletsCubit.refresh`. Writes route through
// [submitWrite] behind the same gate, at `ChildOperationsCubit`'s own seam.
//
// ponytail: process-lifetime in-memory state, five fixed read presets plus
// three write modes, deliberately not persisted and not generalised into a
// scenario registry. A simulated write lands after a fixed 3 s with no
// jitter, and never debits the fixed main balance. The upgrade path for a
// sixth preset is one more enum value plus one more switch arm, the same
// way DevMockJob's scenarios grew.
enum DevChildWalletsPreset {
  none,
  oneChild,
  threeChildren,
  queryError,
  nodeNotRunning,
}

/// The outcome a simulated submit takes, selectable independently of
/// [DevMockChildWallets.preset]. `confirm` is the default so an ordinary
/// walk sees a successful write without pressing anything first.
enum DevChildWalletsWriteMode { confirm, timeout, fail }

class DevMockChildWallets {
  DevMockChildWallets._();

  static final DevMockChildWallets instance = DevMockChildWallets._();

  /// `null` means no override - read the real SDK. Sticky, not one-shot,
  /// same reasoning as `DevMockJob.scenario`: a walk holds a preset across
  /// resizes and appearance toggles. `ValueNotifier` only notifies on a
  /// changed value, so re-arming the same preset is idempotent for free.
  final ValueNotifier<DevChildWalletsPreset?> preset = ValueNotifier(null);

  /// Arms the sticky override. Assigns, never toggles - repeated presses of
  /// the same button are idempotent.
  void arm(DevChildWalletsPreset value) {
    preset.value = value;
  }

  /// Sticky like [preset] - a walk holds a write mode across several
  /// submits, not just one.
  final ValueNotifier<DevChildWalletsWriteMode> writeMode = ValueNotifier(
    DevChildWalletsWriteMode.confirm,
  );

  /// Assigns the write mode every subsequent [submitWrite] reads.
  void setWriteMode(DevChildWalletsWriteMode mode) {
    writeMode.value = mode;
  }

  /// Children added to, or removed from, a main by a simulated write, keyed
  /// by the lowercased main address. Independent of [preset] - both layer
  /// onto whichever fixture [registrationsFor] would otherwise return.
  final Map<String, Set<String>> _addedTo = {};
  final Map<String, Set<String>> _removedFrom = {};

  /// The running total a simulated fund or recover has shifted a child's
  /// balance by, keyed by the lowercased child address.
  final Map<String, BigInt> _balanceDelta = {};

  /// Every `confirm`-mode write still waiting to land, so [clear] can cancel
  /// them instead of letting a stale one fire after a preset moved on.
  final List<Timer> _pendingWrites = [];

  /// Clears the override so the cubit returns to reading the real SDK, and
  /// forgets every simulated write along with it. [writeMode] is left alone
  /// - a walk clearing the read preset mid-way still wants its chosen write
  /// outcome for the next arm.
  void clear() {
    preset.value = null;
    for (final timer in _pendingWrites) {
      timer.cancel();
    }
    _pendingWrites.clear();
    _addedTo.clear();
    _removedFrom.clear();
    _balanceDelta.clear();
  }

  /// Simulates submitting [op]: `fail` refuses it with the SDK's
  /// registration error and changes nothing; `timeout` accepts it but never
  /// applies it, so the caller's own timeout is what ends it; `confirm`
  /// accepts it and applies it 3 s later. Never a real SDK call - this is
  /// the only place a write can land while a preset is armed.
  GeniusNodeReturnValue submitWrite(ChildOperation op) {
    switch (writeMode.value) {
      case DevChildWalletsWriteMode.fail:
        return GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION;
      case DevChildWalletsWriteMode.timeout:
        return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
      case DevChildWalletsWriteMode.confirm:
        _pendingWrites.add(Timer(const Duration(seconds: 3), () => _apply(op)));
        return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
    }
  }

  /// Applies [op]'s effect to the simulated tables - the same shape a real
  /// node's observable state would take on once the write actually landed.
  /// [_addedTo] and [_removedFrom] keep the target's original case, since a
  /// registrations read has to render it exactly as submitted; only the
  /// main key and membership checks are lowercased.
  void _apply(ChildOperation op) {
    final main = op.main.toLowerCase();
    final target = op.target;
    switch (op.kind) {
      case ChildOperationKind.register:
        _addedTo.putIfAbsent(main, () => {}).add(target);
        _removedFrom[main]?.removeWhere(
          (child) => child.toLowerCase() == target.toLowerCase(),
        );
        break;
      case ChildOperationKind.revoke:
      case ChildOperationKind.detach:
        _removedFrom.putIfAbsent(main, () => {}).add(target);
        _addedTo[main]?.removeWhere(
          (child) => child.toLowerCase() == target.toLowerCase(),
        );
        break;
      case ChildOperationKind.move:
        final newMain = op.newMain!.toLowerCase();
        _removedFrom.putIfAbsent(main, () => {}).add(target);
        _addedTo[main]?.removeWhere(
          (child) => child.toLowerCase() == target.toLowerCase(),
        );
        _addedTo.putIfAbsent(newMain, () => {}).add(target);
        _removedFrom[newMain]?.removeWhere(
          (child) => child.toLowerCase() == target.toLowerCase(),
        );
        break;
      case ChildOperationKind.fund:
        final key = target.toLowerCase();
        _balanceDelta[key] =
            (_balanceDelta[key] ?? BigInt.zero) + op.amountMinions!;
        break;
      case ChildOperationKind.recover:
        final key = target.toLowerCase();
        _balanceDelta[key] =
            (_balanceDelta[key] ?? BigInt.zero) - op.amountMinions!;
        break;
    }
  }

  /// The lone child in [DevChildWalletsPreset.oneChild]. Unlinked by
  /// construction - there is nothing else armed that could link it.
  static const String singleChildAddress =
      '0xDEV1000000000000000000000000000000AAA1';

  /// [DevChildWalletsPreset.threeChildren]'s unlinked pair - one with a
  /// real balance, one at zero. Both start `0xDEV` and differ only in
  /// their last four characters from every other synthetic address here,
  /// so the short address alone tells all of them apart.
  static const String pairAddressA = '0xDEV2000000000000000000000000000000AAA2';
  static const String pairAddressB = '0xDEV3000000000000000000000000000000AAA3';

  /// Stands in for [DevChildWalletsPreset.threeChildren]'s linked slot when
  /// no other own SDK account is linked to a wallet.
  static const String fallbackLinkedAddress =
      '0xDEV4000000000000000000000000000000AAA4';

  /// The mock main's own GNUS balance, in minions - fixed regardless of any
  /// fund or recover already simulated, since nothing here ever debits it.
  /// Fund's amount cap while a preset is armed.
  static final BigInt mainBalanceMinions =
      BigInt.from(1000) * BigInt.from(1000000);

  /// The registrations [preset] should render for [mainAddress], with every
  /// simulated register, revoke, detach or move already layered on. [app]
  /// resolves [DevChildWalletsPreset.threeChildren]'s linked slot without
  /// duplicating another own account's key material.
  static ChildRegistrations registrationsFor(
    DevChildWalletsPreset preset,
    AppState app,
    String mainAddress,
  ) {
    switch (preset) {
      case DevChildWalletsPreset.queryError:
        return const (
          result: GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
          entries: <ChildRegistration>[],
        );
      case DevChildWalletsPreset.nodeNotRunning:
        return const (
          result: GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
          entries: <ChildRegistration>[],
        );
      case DevChildWalletsPreset.none:
      case DevChildWalletsPreset.oneChild:
      case DevChildWalletsPreset.threeChildren:
        // The fixture set only ever sits under the running account, or
        // under any main when none is selected - a write simulated onto a
        // different main never inherits another main's fixture children.
        final isRunningMain =
            app.selectedSDKAccount == null ||
            app.selectedSDKAccount!.toLowerCase() == mainAddress.toLowerCase();
        final fixtures = isRunningMain
            ? _fixtureEntries(preset, app, mainAddress)
            : const <ChildRegistration>[];
        return (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: instance._withSimulated(mainAddress, fixtures),
        );
    }
  }

  static List<ChildRegistration> _fixtureEntries(
    DevChildWalletsPreset preset,
    AppState app,
    String mainAddress,
  ) {
    switch (preset) {
      case DevChildWalletsPreset.oneChild:
        return [
          ChildRegistration(
            childAddress: singleChildAddress,
            mainAddress: mainAddress,
            sequence: 0,
          ),
        ];
      case DevChildWalletsPreset.threeChildren:
        final linkedSibling = _firstLinkedSibling(app, mainAddress);
        return [
          ChildRegistration(
            childAddress: linkedSibling ?? fallbackLinkedAddress,
            mainAddress: mainAddress,
            sequence: 0,
          ),
          ChildRegistration(
            childAddress: pairAddressA,
            mainAddress: mainAddress,
            sequence: 1,
          ),
          ChildRegistration(
            childAddress: pairAddressB,
            mainAddress: mainAddress,
            sequence: 2,
          ),
        ];
      case DevChildWalletsPreset.none:
      case DevChildWalletsPreset.queryError:
      case DevChildWalletsPreset.nodeNotRunning:
        return const <ChildRegistration>[];
    }
  }

  /// Layers this main's simulated removals and additions onto [fixtures].
  List<ChildRegistration> _withSimulated(
    String mainAddress,
    List<ChildRegistration> fixtures,
  ) {
    final main = mainAddress.toLowerCase();
    final removed = _removedFrom[main]?.map((c) => c.toLowerCase()).toSet();
    final kept = (removed == null || removed.isEmpty)
        ? fixtures
        : fixtures
              .where(
                (entry) => !removed.contains(entry.childAddress.toLowerCase()),
              )
              .toList();
    final added = _addedTo[main];
    if (added == null || added.isEmpty) {
      return kept;
    }
    final already = kept
        .map((entry) => entry.childAddress.toLowerCase())
        .toSet();
    final result = [...kept];
    for (final child in added) {
      if (already.contains(child.toLowerCase())) {
        continue;
      }
      result.add(
        ChildRegistration(
          childAddress: child,
          mainAddress: mainAddress,
          sequence: result.length,
        ),
      );
    }
    return result;
  }

  /// The first of the user's own SDK accounts, other than [mainAddress],
  /// that has a linked wallet - or null when none does.
  static String? _firstLinkedSibling(AppState app, String mainAddress) {
    for (final address in app.sdkAccounts) {
      if (address.toLowerCase() == mainAddress.toLowerCase()) {
        continue;
      }
      final linked = AppBloc.linkedWallet(
        address,
        app.sdkAccountLinks,
        app.wallets,
      );
      if (linked != null) {
        return address;
      }
    }
    return null;
  }

  /// [childAddress]'s GNUS balance, in minions, with any simulated fund or
  /// recover delta already applied: 1.5 GNUS for [singleChildAddress], the
  /// mixed pair for [pairAddressA]/[pairAddressB], 250 GNUS for anything
  /// else (including a real linked sibling, or [fallbackLinkedAddress]).
  static BigInt balanceFor(String childAddress) {
    final delta =
        instance._balanceDelta[childAddress.toLowerCase()] ?? BigInt.zero;
    return _baseBalanceFor(childAddress) + delta;
  }

  static BigInt _baseBalanceFor(String childAddress) {
    if (childAddress == singleChildAddress) {
      return BigInt.from(1500000);
    }
    if (childAddress == pairAddressA) {
      return BigInt.from(12345678);
    }
    if (childAddress == pairAddressB) {
      return BigInt.zero;
    }
    return BigInt.from(250000000);
  }
}
