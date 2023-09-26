
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:test/test.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';

void main() {

  group('Trust Wallet FFI', () {
    
    test('Trust Wallet Creation', () {
      final tWallet = FFIBridgePrebuilt();
      expect(tWallet.getValueFromNative(),  12.0);

    });
    test('Trust Wallet HRP', () {
      final tWallet = FFIBridgePrebuilt();

      expect(tWallet.wallet_lib.HRP_BITCOIN.cast<Utf8>().toDartString(), 'bc');
      expect(tWallet.wallet_lib.HRP_LITECOIN.cast<Utf8>().toDartString(), 'ltc');
      expect(tWallet.wallet_lib.HRP_VIACOIN.cast<Utf8>().toDartString(), 'via');
      expect(tWallet.wallet_lib.HRP_GROESTLCOIN.cast<Utf8>().toDartString(), 'grs');
      expect(tWallet.wallet_lib.HRP_DIGIBYTE.cast<Utf8>().toDartString(), 'dgb');
      expect(tWallet.wallet_lib.HRP_MONACOIN.cast<Utf8>().toDartString(), 'mona');
      expect(tWallet.wallet_lib.HRP_COSMOS.cast<Utf8>().toDartString(), 'cosmos');
      expect(tWallet.wallet_lib.HRP_BITCOINCASH.cast<Utf8>().toDartString(), 'bitcoincash');
      expect(tWallet.wallet_lib.HRP_BITCOINGOLD.cast<Utf8>().toDartString(), 'btg');
      expect(tWallet.wallet_lib.HRP_IOTEX.cast<Utf8>().toDartString(), 'io');
      expect(tWallet.wallet_lib.HRP_NERVOS.cast<Utf8>().toDartString(), 'ckb');
      expect(tWallet.wallet_lib.HRP_ZILLIQA.cast<Utf8>().toDartString(), 'zil');
      expect(tWallet.wallet_lib.HRP_TERRA.cast<Utf8>().toDartString(), 'terra');
      expect(tWallet.wallet_lib.HRP_CRYPTOORG.cast<Utf8>().toDartString(), 'cro');
      expect(tWallet.wallet_lib.HRP_KAVA.cast<Utf8>().toDartString(), 'kava');
      expect(tWallet.wallet_lib.HRP_OASIS.cast<Utf8>().toDartString(), 'oasis');
      expect(tWallet.wallet_lib.HRP_BLUZELLE.cast<Utf8>().toDartString(), 'bluzelle');
      expect(tWallet.wallet_lib.HRP_BAND.cast<Utf8>().toDartString(), 'band');
      expect(tWallet.wallet_lib.HRP_ELROND.cast<Utf8>().toDartString(), 'erd');
      expect(tWallet.wallet_lib.HRP_SECRET.cast<Utf8>().toDartString(), 'secret');
      expect(tWallet.wallet_lib.HRP_AGORIC.cast<Utf8>().toDartString(), 'agoric');
      expect(tWallet.wallet_lib.HRP_BINANCE.cast<Utf8>().toDartString(), 'bnb');
      expect(tWallet.wallet_lib.HRP_ECASH.cast<Utf8>().toDartString(), 'ecash');
      expect(tWallet.wallet_lib.HRP_THORCHAIN.cast<Utf8>().toDartString(), 'thor');
      expect(tWallet.wallet_lib.HRP_HARMONY.cast<Utf8>().toDartString(), 'one');
      expect(tWallet.wallet_lib.HRP_CARDANO.cast<Utf8>().toDartString(), 'addr');
      expect(tWallet.wallet_lib.HRP_QTUM.cast<Utf8>().toDartString(), 'qc');
      expect(tWallet.wallet_lib.HRP_NATIVEINJECTIVE.cast<Utf8>().toDartString(), 'inj');
      expect(tWallet.wallet_lib.HRP_OSMOSIS.cast<Utf8>().toDartString(), 'osmo');
      expect(tWallet.wallet_lib.HRP_TERRAV2.cast<Utf8>().toDartString(), 'terra');
      expect(tWallet.wallet_lib.HRP_COREUM.cast<Utf8>().toDartString(), 'core');
      expect(tWallet.wallet_lib.HRP_NATIVECANTO.cast<Utf8>().toDartString(), 'canto');
      expect(tWallet.wallet_lib.HRP_SOMMELIER.cast<Utf8>().toDartString(), 'somm');
      expect(tWallet.wallet_lib.HRP_FETCHAI.cast<Utf8>().toDartString(), 'fetch');
      expect(tWallet.wallet_lib.HRP_MARS.cast<Utf8>().toDartString(), 'mars');
      expect(tWallet.wallet_lib.HRP_UMEE.cast<Utf8>().toDartString(), 'umee');
      expect(tWallet.wallet_lib.HRP_QUASAR.cast<Utf8>().toDartString(), 'quasar');
      expect(tWallet.wallet_lib.HRP_PERSISTENCE.cast<Utf8>().toDartString(), 'persistence');
      expect(tWallet.wallet_lib.HRP_AKASH.cast<Utf8>().toDartString(), 'akash');
      expect(tWallet.wallet_lib.HRP_NOBLE.cast<Utf8>().toDartString(), 'noble');
      expect(tWallet.wallet_lib.HRP_STARGAZE.cast<Utf8>().toDartString(), 'stars');
      expect(tWallet.wallet_lib.HRP_NATIVEEVMOS.cast<Utf8>().toDartString(), 'evmos');
      expect(tWallet.wallet_lib.HRP_JUNO.cast<Utf8>().toDartString(), 'juno');
      expect(tWallet.wallet_lib.HRP_STRIDE.cast<Utf8>().toDartString(), 'stride');
      expect(tWallet.wallet_lib.HRP_AXELAR.cast<Utf8>().toDartString(), 'axelar');
      expect(tWallet.wallet_lib.HRP_CRESCENT.cast<Utf8>().toDartString(), 'cre');
      expect(tWallet.wallet_lib.HRP_KUJIRA.cast<Utf8>().toDartString(), 'kujira');
      expect(tWallet.wallet_lib.HRP_COMDEX.cast<Utf8>().toDartString(), 'comdex');
      expect(tWallet.wallet_lib.HRP_NEUTRON.cast<Utf8>().toDartString(), 'neutron');

      expect(tWallet.wallet_lib.stringForHRP(TWHRP.TWHRPStride).cast<Utf8>().toDartString(), 'stride');
      
    });
  });
}