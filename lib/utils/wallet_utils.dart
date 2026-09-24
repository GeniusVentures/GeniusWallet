import 'package:genius_api/web3/web3.dart' show EthereumAddress;
import 'package:intl/intl.dart';

/// A 42-character `0x`-prefixed hex address. Mixed case must match its EIP-55
/// checksum, which catches the usual one-character copy typo; all-lower or
/// all-upper carries no checksum and is accepted as it is.
bool isEvmAddress(String raw) {
  final v = raw.trim();
  return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(v) &&
      EthereumAddress.isEip55ValidEthereumAddress(v);
}

const walletNameIsAddressMessage =
    'That looks like an address. Give the wallet a name instead.';

/// The one rule for every field that names a wallet. An address is refused
/// because the header shows the name alone, where it would read as a bug.
String? walletNameError(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) {
    return 'Please enter a wallet name';
  }
  // Lowercased so a `0X` prefix is caught too; `isEvmAddress` stays strict
  // because the payout field forwards what it accepts to the SDK verbatim.
  if (isEvmAddress(name.toLowerCase())) {
    return walletNameIsAddressMessage;
  }
  return null;
}

class WalletUtils {
  static String getAddressForDisplay(String address) {
    if (address.length >= 6) {
      return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
    }

    return address;
  }

  /// Zero reads "0 minions", never "0.0"; anything else keeps at most three
  /// decimals, and a balance too small for that reads "<0.001", never "0".
  static String formatMinions(double value) {
    if (value > 0 && value < 0.001) {
      return '<0.001 minions';
    }
    return '${NumberFormat('#,##0.###').format(value)} '
        '${value == 1 ? 'minion' : 'minions'}';
  }

  static String truncateToDecimals(String input, [int decimalPlaces = 5]) {
    final int decimalIndex = input.indexOf('.');
    if (decimalIndex != -1 && input.length > decimalIndex + decimalPlaces + 1) {
      return input.substring(0, decimalIndex + decimalPlaces + 1);
    }
    return input;
  }
}
