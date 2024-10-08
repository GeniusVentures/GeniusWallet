class Network {
  String name;
  String symbol;
  int chainId;
  String rpcUrl;
  String? iconPath;

  Network(
      {required this.name,
      required this.symbol,
      required this.chainId,
      required this.rpcUrl,
      this.iconPath});
}
