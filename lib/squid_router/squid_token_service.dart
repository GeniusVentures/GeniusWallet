import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_fee_cost.dart';
import 'package:genius_wallet/squid_router/models/squid_gas_cost.dart';
import 'package:genius_wallet/squid_router/models/squid_route_response.dart';
import 'package:genius_wallet/squid_router/models/squid_swap_params.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';

class SquidTokenService {
  static Future<List<SquidTokenInfo>> fetchTokens() async {
    // 🧪 MOCKED TOKEN DATA
    return mockTokens;

    // 🌐 REAL API CALL — restore this later when ready
    /*
    final res = await http.get(Uri.parse('$_baseUrl/tokens'));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final tokens = body['data']['tokens'] as List;

      return tokens.map((json) => SquidTokenInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch tokens (Status: ${res.statusCode})');
    }
    */
  }

  /// Fetch token balances for a given address across multiple chains.
  static Future<List<SquidBalance>> fetchBalances({
    required List<String> chainIds,
    required String walletAddress,
  }) async {
    return mockSquidBalances;

    // 🌐 REAL API CALL — restore this later when ready
    // final url = Uri.parse('$_baseUrl/balances');

    // final response = await http.post(
    //   url,
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     "chainIds": chainIds,
    //     "evmAddress": walletAddress,
    //   }),
    // );

    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   return data;
    // } else {
    //   print('Failed to fetch balances (Status Code: ${response.statusCode})');
    //   return {};
    // }
  }

  static Future<SquidRouteResponse> getRoute(SquidSwapParams params) async {
    return mockSquidRoute;
    // final uri = Uri.parse('$baseUrl/route').replace(
    //   queryParameters: {
    //     'fromChain': params.fromChain,
    //     'fromToken': params.fromToken,
    //     'fromAmount': params.fromAmount,
    //     'toChain': params.toChain,
    //     'toToken': params.toToken,
    //     'fromAddress': params.fromAddress,
    //     'toAddress': params.toAddress,
    //     'slippage': '1', // optional, set as needed
    //     'enableUniversalRouter': 'true',
    //   },
    // );

    // final response = await http.get(uri);

    // if (response.statusCode != 200) {
    //   throw Exception('Failed to fetch route: ${response.body}');
    // }

    // final Map<String, dynamic> data = json.decode(response.body);
    // return SquidRouteResponse.fromJson(data);
  }

  // TODO: Add chains, update main chains dropdown to also use this.. remove the chains hardcoded in assets/networks.json
  //   const getChains = async () => {
  //     const result = await axios.get('https://testnet.api.squidrouter.com/v1/chains');
  //     return result.data;
  //   }
}

final mockSquidRoute = SquidRouteResponse(
  routeId: 'mock-route-123',
  fromChain: 'ethereum',
  toChain: 'ethereum',
  fromToken: '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
  toToken: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  fromAmount: '1000000000000000000',
  toAmount: '995000',
  exchangeRate: '993.72',
  aggregatePriceImpact: '0.51',
  route: [/* ... as before ... */],
  gasCosts: [
    SquidGasCost(
      type: 'executeCall',
      token: SquidTokenInfo(
        commonKey: 'eth',
        crosschain: false,
        chainId: 1,
        address: '0x0000000000000000000000000000000000000000',
        name: 'Ethereum',
        symbol: 'ETH',
        decimals: 18,
        logoURI:
            'https://assets.coingecko.com/coins/images/279/small/ethereum.png?1595348880',
        coingeckoId: 'ethereum',
      ),
      amount: '12439757116840000',
      amountUSD: '15.0604',
      gasPrice: '10117084325',
      maxFeePerGas: '21447857098',
      maxPriorityFeePerGas: '1500000000',
      estimate: '580000',
      limit: '667000',
    ),
  ],
  feeCosts: [
    SquidFeeCost(
      name: 'Gas Receiver Fee',
      description: 'Estimated Gas Receiver fee',
      percentage: '0',
      token: SquidTokenInfo(
        commonKey: 'eth',
        crosschain: false,
        chainId: 1,
        address: '0x0000000000000000000000000000000000000000',
        name: 'Ethereum',
        symbol: 'ETH',
        decimals: 18,
        logoURI:
            'https://assets.coingecko.com/coins/images/279/small/ethereum.png?1595348880',
        coingeckoId: 'ethereum',
      ),
      amount: '503509582401222',
      amountUSD: '0.3048',
    ),
  ],
);

final List<SquidBalance> mockSquidBalances = [
  SquidBalance(
    balance: "1000000000000000000", // 1 ETH
    symbol: "ETH",
    address: "0x0000000000000000000000000000000000000000",
    decimals: 18,
    chainId: "1", // Ethereum Mainnet
  ),
  SquidBalance(
    balance: "500000000", // 500 USDT (6 decimals)
    symbol: "USDT",
    address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    decimals: 6,
    chainId: "1",
  ),
  SquidBalance(
    balance: "2000000000000000000", // 2 ETH
    symbol: "ETH",
    address: "0x0000000000000000000000000000000000000000",
    decimals: 18,
    chainId: "137", // Polygon Mainnet
  ),
  SquidBalance(
    balance: "1500000000", // 1500 USDT
    symbol: "USDT",
    address: "0x3813e82e6f7098b9583FC0F33a962D02018B6803",
    decimals: 6,
    chainId: "137",
  ),
  SquidBalance(
    balance: "100000000000000000", // 0.1 ETH
    symbol: "ETH",
    address: "0x0000000000000000000000000000000000000000",
    decimals: 18,
    chainId: "80001", // Polygon Amoy Testnet
  ),
  SquidBalance(
    balance: "1000000", // 1 USDT
    symbol: "USDT",
    address: "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
    decimals: 6,
    chainId: "80001",
  ),
  SquidBalance(
    balance: "10000000000000220",
    chainId: '1',
    address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    symbol: 'DAI',
    decimals: 18,
  ),

  // ---------------------------------------------------------------------
  // MAGNITUDE STRESS FIXTURES (added at the 08-07 walk, 2026-07-27)
  //
  // Every balance above is a comfortable middle-sized number, so nothing in
  // the picker or the amount field was ever asked to render a real token
  // magnitude. These four are the extremes a wallet actually produces. Each
  // one names what it SHOULD render as, so a layout that breaks under it is
  // obvious rather than debatable.
  //
  // They attach to tokens already in `mockTokens` — the merge in
  // `swap_screen._loadTokens` matches on symbol + chainId + address, so an
  // entry that does not line up on all three silently never appears.
  // ---------------------------------------------------------------------

  // DUST — 1e-15 WETH, i.e. 0.000000000000001. Below `displayBalance`'s
  // readable floor, so the picker must say `<0.000001` and NOT round it to
  // `0`: the wallet holds something, and saying otherwise is a lie. This is
  // also the case `hasSpendableBalance` must keep — dust is spendable.
  SquidBalance(
    balance: "1000",
    symbol: "WETH",
    address: "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619",
    decimals: 18,
    chainId: "137",
  ),

  // EXACTLY THE FLOOR — 0.000001 USDC. The boundary `<0.000001` is compared
  // against; it must render as the figure itself, not as the "less than"
  // form. One raw unit of a 6-decimal token.
  SquidBalance(
    balance: "1",
    symbol: "USDC",
    address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
    decimals: 6,
    chainId: "1",
  ),

  // LONG FRACTION — 1.234567890123456789 WETH-ARB, an 18-decimal value with
  // eighteen significant digits after the point. `displayBalance` caps at six
  // (1.234568) while MAX still puts the EXACT value in the amount field, so
  // this is the fixture that shows the two diverging on purpose.
  SquidBalance(
    balance: "1234567890123456789",
    symbol: "WETH-ARB",
    address: "0x82af49447d8a07e3bd95bd0d56f35241523fbab1",
    decimals: 18,
    chainId: "42161",
  ),

  // HUGE — 1,000,000,000,000 WFTM (1e12), thirteen digits before the point.
  // The widest string the row and the 38px amount slot have to survive.
  // Deliberately kept inside int64: `displayBalance` routes whole numbers
  // through `double.toInt()`, and a value past 2^63 would fall into its catch
  // and render as `0` — a real edge, but a different bug from this one, and
  // not one to smuggle in behind a layout fixture.
  SquidBalance(
    balance: "1000000000000000000000000000000",
    symbol: "WFTM",
    address: "0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83",
    decimals: 18,
    chainId: "250",
  ),
];

final mockTokens = [
  SquidTokenInfo(
    chainId: 1,
    address: '0x0000000000000000000000000000000000000000',
    name: 'Ethereum',
    symbol: 'ETH',
    decimals: 18,
    crosschain: true,
    commonKey: 'eth',
    logoURI: 'https://assets.coingecko.com/coins/images/279/small/ethereum.png',
    coingeckoId: 'ethereum',
  ),
  SquidTokenInfo(
    chainId: 1284,
    address: '0xAcc15dC74880C9944775448304B263D191c6077F',
    name: 'Wrapped GLMR',
    symbol: 'WGLMR',
    decimals: 18,
    crosschain: false,
    commonKey: 'uwglmr',
    logoURI: 'https://assets.coingecko.com/coins/images/22459/small/glmr.png',
    coingeckoId: 'wrapped-moonbeam',
  ),
  SquidTokenInfo(
    chainId: 1,
    address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    name: 'Dai Stablecoin',
    symbol: 'DAI',
    decimals: 18,
    crosschain: true,
    commonKey: 'dai',
    logoURI: 'https://assets.coingecko.com/coins/images/9956/small/4943.png',
    coingeckoId: 'dai',
  ),
  SquidTokenInfo(
    chainId: 1,
    address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    name: 'USD Coin',
    symbol: 'USDC',
    decimals: 6,
    crosschain: true,
    commonKey: 'usdc',
    logoURI:
        'https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png',
    coingeckoId: 'usd-coin',
  ),
  SquidTokenInfo(
    chainId: 1,
    address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    name: 'Tether USD',
    symbol: 'USDT',
    decimals: 6,
    crosschain: true,
    commonKey: 'usdt',
    logoURI: 'https://assets.coingecko.com/coins/images/325/small/Tether.png',
    coingeckoId: 'tether',
  ),
  SquidTokenInfo(
    chainId: 137,
    address: '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619',
    name: 'Wrapped Ether',
    symbol: 'WETH',
    decimals: 18,
    crosschain: true,
    commonKey: 'weth',
    logoURI: 'https://assets.coingecko.com/coins/images/2518/small/weth.png',
    coingeckoId: 'weth',
  ),
  SquidTokenInfo(
    chainId: 56,
    address: '0x55d398326f99059fF775485246999027B3197955',
    name: 'Tether USD (BSC)',
    symbol: 'USDT-BSC',
    decimals: 18,
    crosschain: false,
    commonKey: 'usdt_bsc',
    logoURI: 'https://assets.coingecko.com/coins/images/325/small/Tether.png',
    coingeckoId: 'tether',
  ),
  SquidTokenInfo(
    chainId: 250,
    address: '0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83',
    name: 'Wrapped FTM',
    symbol: 'WFTM',
    decimals: 18,
    crosschain: false,
    commonKey: 'wftm',
    logoURI: 'https://assets.coingecko.com/coins/images/4001/small/Fantom.png',
    coingeckoId: 'wrapped-fantom',
  ),
  SquidTokenInfo(
    chainId: 42161,
    address: '0x82af49447d8a07e3bd95bd0d56f35241523fbab1',
    name: 'Wrapped ETH (Arbitrum)',
    symbol: 'WETH-ARB',
    decimals: 18,
    crosschain: true,
    commonKey: 'weth_arb',
    logoURI: 'https://assets.coingecko.com/coins/images/2518/small/weth.png',
    coingeckoId: 'weth',
  ),
  SquidTokenInfo(
    chainId: 10,
    address: '0x4200000000000000000000000000000000000006',
    name: 'Optimism Token',
    symbol: 'OP',
    decimals: 18,
    crosschain: true,
    commonKey: 'op',
    logoURI:
        'https://assets.coingecko.com/coins/images/25244/small/Optimism.png',
    coingeckoId: 'optimism',
  ),
  SquidTokenInfo(
    chainId: 42220,
    address: '0x471EcE3750Da237f93B8E339c536989b8978a438',
    name: 'CELO',
    symbol: 'CELO',
    decimals: 18,
    crosschain: true,
    commonKey: 'celo',
    logoURI: 'https://assets.coingecko.com/coins/images/11090/small/celo.png',
    coingeckoId: 'celo',
  ),
];
