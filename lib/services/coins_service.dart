import 'package:genius_api/assets/read_asset.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';

class CoinService {
  Future<Coin?> fetchGnusBalance(String walletAddress, Network network) async {
    return await fetchCoinBalance(
      walletAddress: walletAddress,
      network: network,
      coinName: 'GNUS',
    );
  }

  Future<Token?> fetchGnusInfo(Network network) async {
    return await getTokenFromNetworkByName(name: 'GNUS', network: network);
  }
}
