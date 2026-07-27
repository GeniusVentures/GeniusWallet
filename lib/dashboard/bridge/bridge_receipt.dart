import 'package:genius_api/models/transaction.dart';

/// Synthesizes a display-only `Transaction` for the shared 031-B receipt
/// (`showTransactionDetails`), because `bridge_screen.dart` has never built
/// one — bridge's result today is a raw `AlertDialog`, not a `Transaction`.
///
/// WHY `TransactionType.mint`: the destination-chain half of a bridge IS a
/// mint, and the API call itself asks for it (`bridgeOut(...
/// shouldMintTokens: true)`). `TransactionType` is Hive-persisted with
/// explicit `@HiveField` indices (`packages/genius_api/lib/models/
/// transaction.dart`), so adding an eighth value would be a persisted-schema
/// change — out of bounds for a re-skin phase (D-19). The knowingly accepted
/// cost: the receipt's badge and title copy read "Minted", not "Bridged".
/// D-19's sanctioned fallback, if this reads badly in situ, is `transfer` —
/// a walk-time observation, not a call made here.
///
/// WHY `fees` is always blank: the only fee datum bridge has is a gas PRICE
/// in Gwei of the SOURCE chain's native token (`getBrigeOutGasCost`), while
/// the shared receipt's Network Fee row composes any non-blank fee against
/// THIS Transaction's own `coinSymbol` (the destination/GNUS side). Printing
/// that gas price there would be either a doubled unit or a false magnitude.
/// The gas figure stays exactly where it already lives — the bridge screen's
/// own gas card, whose own label owns its own unit.
///
/// THAT this record is display-only and deliberately never persisted: this
/// factory takes no widget-tree context and makes no cubit or on-disk
/// storage call of its own. Bridge results are not persisted today either
/// (T-08-27, accepted), so this factory does not change that.
Transaction bridgeReceiptTransaction({
  required bool isSuccess,
  required String? txHash,
  required String walletAddress,
  required String amount,
  required String coinSymbol,
  DateTime? timestamp,
}) {
  final trimmedHash = txHash?.trim();
  final hash = (trimmedHash == null || trimmedHash.isEmpty) ? '' : trimmedHash;

  return Transaction(
    hash: hash,
    fromAddress: walletAddress,
    recipients: [TransferRecipients(toAddr: walletAddress, amount: amount)],
    timeStamp: timestamp ?? DateTime.now(),
    transactionDirection: TransactionDirection.received,
    // Always blank — see the file-level doc comment above.
    fees: '',
    coinSymbol: coinSymbol,
    transactionStatus: isSuccess
        ? TransactionStatus.completed
        : TransactionStatus.failed,
    type: TransactionType.mint,
    // exchangeRate deliberately left unset (null): bridge is 1:1 and has no
    // rate, so leaving it unset is what correctly suppresses the Rate row.
  );
}
