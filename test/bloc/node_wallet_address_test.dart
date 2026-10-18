import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';

void main() {
  const links = {
    '0xaaa': (walletAddress: '0xDefault', walletName: 'default'),
    '0xbbb': (walletAddress: '0xOther', walletName: 'other'),
  };

  test('node wallet follows the node account, not the start account', () {
    const state = AppState(selectedSDKAccount: '0xBBB', sdkAccountLinks: links);
    expect(state.nodeWalletAddress, '0xOther');

    final compute = resolveComputeState(
      hasSelectedWallet: true,
      isNodeConnected: true,
      nodeWalletAddress: state.nodeWalletAddress!,
      selectedWalletAddress: '0xother',
      isProcessingUnavailable: false,
      initPercentage: 1.0,
      isProcessing: false,
      sinceJobFinished: null,
    );
    expect(compute, isNot(ComputeState.notDefaultAccount));
  });

  test('unlinked node account has no wallet', () {
    const state = AppState(selectedSDKAccount: '0xccc', sdkAccountLinks: links);
    expect(state.nodeWalletAddress, isNull);
  });
}
