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
