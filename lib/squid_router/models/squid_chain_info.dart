class SquidChainInfo {
  final String chainName;
  final String chainType;
  final String rpc;
  final String networkName;
  final int chainId;
  final NativeCurrency nativeCurrency;
  final List<String> blockExplorerUrls;
  final ChainNativeContracts chainNativeContracts;
  final AxelarContracts axelarContracts;

  SquidChainInfo({
    required this.chainName,
    required this.chainType,
    required this.rpc,
    required this.networkName,
    required this.chainId,
    required this.nativeCurrency,
    required this.blockExplorerUrls,
    required this.chainNativeContracts,
    required this.axelarContracts,
  });

  factory SquidChainInfo.fromJson(Map<String, dynamic> json) {
    return SquidChainInfo(
      chainName: json['chainName'],
      chainType: json['chainType'],
      rpc: json['rpc'],
      networkName: json['networkName'],
      chainId: json['chainId'],
      nativeCurrency: NativeCurrency.fromJson(json['nativeCurrency']),
      blockExplorerUrls: List<String>.from(json['blockExplorerUrls']),
      chainNativeContracts:
          ChainNativeContracts.fromJson(json['chainNativeContracts']),
      axelarContracts: AxelarContracts.fromJson(json['axelarContracts']),
    );
  }
}

class NativeCurrency {
  final String name;
  final String symbol;
  final int decimals;
  final String icon;

  NativeCurrency({
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.icon,
  });

  factory NativeCurrency.fromJson(Map<String, dynamic> json) {
    return NativeCurrency(
      name: json['name'],
      symbol: json['symbol'],
      decimals: json['decimals'],
      icon: json['icon'],
    );
  }
}

class ChainNativeContracts {
  final String wrappedNativeToken;
  final String ensRegistry;
  final String multicall;
  final String usdcToken;

  ChainNativeContracts({
    required this.wrappedNativeToken,
    required this.ensRegistry,
    required this.multicall,
    required this.usdcToken,
  });

  factory ChainNativeContracts.fromJson(Map<String, dynamic> json) {
    return ChainNativeContracts(
      wrappedNativeToken: json['wrappedNativeToken'],
      ensRegistry: json['ensRegistry'],
      multicall: json['multicall'],
      usdcToken: json['usdcToken'],
    );
  }
}

class AxelarContracts {
  final String gateway;
  final String forecallable;

  AxelarContracts({
    required this.gateway,
    required this.forecallable,
  });

  factory AxelarContracts.fromJson(Map<String, dynamic> json) {
    return AxelarContracts(
      gateway: json['gateway'],
      forecallable: json['forecallable'],
    );
  }
}
