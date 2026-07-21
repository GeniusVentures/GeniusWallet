import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';

// DEV-ONLY: makes the SGNUS-wallet branch of WalletsOverview reachable in a
// walk for the first time. Before this fixture existed that branch needed a
// live SGNUS connection plus a real `isProcessing` tick — a state no walk
// had ever reached (05-VERIFICATION.md gap B1). Never used outside a
// kDebugMode && kShowDevTools call site — see dev_tools_bubble.dart for the
// two MOCK buttons that drive this and app_bloc.dart's
// `_onProcessingStatusTicked` for the gated short-circuit that makes
// [processingOverride] actually take effect.
//
// ponytail: process-lifetime in-memory state, one fixture wallet, not
// persisted. Destroyed by any `LoadWallets` dispatch (pull-to-refresh
// included), because `_onLoadWallets` (app_bloc.dart) rebuilds
// `WalletDetailsState` wholesale via `loadInitial` — pre-existing behavior
// already shared with the mock-holdings buttons. Upgrade path: re-press the
// MOCK button, or teach the cubit to survive a reload, which is a behavior
// change and out of scope here.
class DevMockSgnus {
  DevMockSgnus._();

  static final DevMockSgnus instance = DevMockSgnus._();

  /// Clearly-synthetic hex-shaped address with DEV legible in it, so it can
  /// never be mistaken for a real wallet address in a screenshot.
  static const String address =
      '0xDEV5GNUS00000000000000000000000000000001';

  /// Mirrors the shape real SGNUS wallets are built with at
  /// `app_bloc.dart:302-311`. `walletName` is a dev-tool label, not product
  /// copy, so it is outside the §6 copy contract — noted here so a later
  /// reader does not mistake it for a §6 violation.
  Wallet get wallet => const Wallet(
    walletName: 'DEV SGNUS Fixture',
    walletType: WalletType.sgnus,
    address: address,
    currencySymbol: 'minions',
    coinType: TWCoinType.TWCoinTypeEthereum,
    balance: 0,
  );

  /// `walletAddress` and `sgnusAddress` are BOTH [address] — deliberately.
  /// `SubmitJobDashboardButton` renders its 48px CTA only when
  /// `walletAddress == gnusConnectedWalletAddress`; matching them here is
  /// what makes this fixture reproduce the genuine worst case for
  /// `WalletsOverview` rather than a partial one missing that CTA.
  SGNUSConnection get connection => const SGNUSConnection(
    sgnusAddress: address,
    walletAddress: address,
    isConnected: true,
  );

  /// Sticky, tri-state override for `AppState.isProcessing`. Null means "no
  /// override, read the SDK". Sticky (not one-shot) is a deliberate,
  /// opposite choice from [DevFaultInjector]'s one-shot fault: a walker
  /// needs to hold this state while resizing the window and toggling
  /// appearance, whereas a fault must be spent so a retry press can
  /// succeed. Both choices follow from what each walk needs.
  bool? processingOverride;

  /// Fixed, obviously-synthetic percentage so the status text is
  /// deterministic across walks.
  static const double processingPercentage = 42.0;

  /// Arms the sticky override. Assigns, never toggles blindly — repeated
  /// presses of the same MOCK button are idempotent.
  void arm({required bool processing}) {
    processingOverride = processing;
  }

  /// Clears the override so the panel returns to reading the real SDK.
  void clear() {
    processingOverride = null;
  }
}
