/// A 42-character `0x`-prefixed hex address. Deliberately not a checksum test:
/// the SDK does that, and rejecting a valid lowercase address because it is not
/// EIP-55 cased would be worse than the no-validation this replaces.
bool isEvmAddress(String raw) {
  final v = raw.trim();
  return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(v);
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
  if (isEvmAddress(name)) {
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

  static String truncateToDecimals(String input, [int decimalPlaces = 5]) {
    final int decimalIndex = input.indexOf('.');
    if (decimalIndex != -1 && input.length > decimalIndex + decimalPlaces + 1) {
      return input.substring(0, decimalIndex + decimalPlaces + 1);
    }
    return input;
  }
}
