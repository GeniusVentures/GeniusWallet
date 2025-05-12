String getExplorerUrl(String coinSymbol, String txHash) {
  final lowercaseSymbol = coinSymbol.toLowerCase();

  final explorerMap = {
    'eth': 'https://etherscan.io/tx/',
    'polygon': 'https://polygonscan.com/tx/',
    'matic': 'https://polygonscan.com/tx/',
    'bnb': 'https://bscscan.com/tx/',
    'arb': 'https://arbiscan.io/tx/',
    'op': 'https://optimistic.etherscan.io/tx/',
    'avax': 'https://snowtrace.io/tx/',
    'ftm': 'https://ftmscan.com/tx/',
    'sol':
        'https://solscan.io/tx/', // Solana uses different semantics but many explorers accept just tx hash
    'dot': 'https://polkadot.subscan.io/extrinsic/',
    'pol':
        'https://polygonscan.com/tx/', // assuming 'pol' is a mislabeling of 'polygon'
    'base': 'https://basescan.org/tx/',
    'zec': 'https://zcha.in/transactions/',
  };

  final baseUrl = explorerMap[lowercaseSymbol];
  if (baseUrl == null || txHash.isEmpty) return '';

  return '$baseUrl$txHash';
}

String formatAmount(String amountStr) {
  final amount = double.tryParse(amountStr);
  if (amount == null) return amountStr;

  final fixed = amount.toStringAsFixed(8); // preserve small precision

  // Special case: show exact `.00` if the number ends in .00 (like 100.00)
  if (fixed.endsWith('.00')) {
    return fixed.substring(0, fixed.indexOf('.') + 3); // keep 2 decimal places
  }

  // Trim unnecessary trailing zeros but keep precision
  return fixed.replaceFirst(RegExp(r'([.]*[0]+)$'), '');
}
