import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';

// DEV-ONLY: makes every child-wallet state reachable with no registered
// child and no live node. Before this fixture existed, walking the empty,
// populated, node-not-running and query-failure branches of
// `ChildWalletsCubit` needed a real registration on a real testnet node -
// `GENIUS_NODE_ERROR_REGISTRATION` in particular has no reachable trigger
// from the UI at all. Read behind `kDebugMode && kShowDevTools` at exactly
// one call site - see `ChildWalletsCubit.refresh`.
//
// ponytail: process-lifetime in-memory state, five fixed presets,
// deliberately not persisted and not generalised into a scenario registry.
// The upgrade path for a sixth preset is one more enum value plus one more
// switch arm, the same way DevMockJob's scenarios grew.
enum DevChildWalletsPreset {
  none,
  oneChild,
  threeChildren,
  queryError,
  nodeNotRunning,
}

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

  /// Clears the override so the cubit returns to reading the real SDK.
  void clear() {
    preset.value = null;
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

  /// The registrations [preset] should render, in fixture order. [app] and
  /// [mainAddress] resolve [DevChildWalletsPreset.threeChildren]'s linked
  /// slot without duplicating another own account's key material.
  static ChildRegistrations registrationsFor(
    DevChildWalletsPreset preset,
    AppState app,
    String mainAddress,
  ) {
    switch (preset) {
      case DevChildWalletsPreset.none:
        return const (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: <ChildRegistration>[],
        );
      case DevChildWalletsPreset.oneChild:
        return (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: [
            ChildRegistration(
              childAddress: singleChildAddress,
              mainAddress: mainAddress,
              sequence: 0,
            ),
          ],
        );
      case DevChildWalletsPreset.threeChildren:
        final linkedSibling = _firstLinkedSibling(app, mainAddress);
        return (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: [
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
          ],
        );
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
    }
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

  /// [childAddress]'s GNUS balance, in minions: 1.5 GNUS for
  /// [singleChildAddress], the mixed pair for [pairAddressA]/[pairAddressB],
  /// 250 GNUS for anything else (including a real linked sibling, or
  /// [fallbackLinkedAddress]).
  static BigInt balanceFor(String childAddress) {
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
