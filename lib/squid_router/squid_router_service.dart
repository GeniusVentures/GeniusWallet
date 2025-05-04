import 'package:genius_wallet/squid_router/squid_token_info.dart';

class SquidTokenService {
  static Future<List<SquidTokenInfo>> fetchTokens() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return a hardcoded list of tokens
    return [
      SquidTokenInfo(
        address: '0x0000000000000000000000000000000000000000',
        symbol: 'ETH',
        name: 'Ethereum',
        decimals: 18,
        chainId: 1,
        logoURI: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
      ),
      SquidTokenInfo(
        address: '0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
        symbol: 'USDC',
        name: 'USD Coin',
        decimals: 6,
        chainId: 1,
        logoURI: 'https://cryptologos.cc/logos/usd-coin-usdc-logo.png',
      ),
      SquidTokenInfo(
        address: '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        symbol: 'DAI',
        name: 'Dai Stablecoin',
        decimals: 18,
        chainId: 1,
        logoURI:
            'https://cryptologos.cc/logos/multi-collateral-dai-dai-logo.png',
      ),
    ];
  }
}
