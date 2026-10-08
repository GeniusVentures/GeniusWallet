import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_helpers/buy_defaults.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:intl/intl.dart';

enum BuyAvailability { loading, ready, notListed, notConfigured, loadFailed }

enum BuyCtaAction { none, buy, refresh }

class BuyCta {
  const BuyCta(this.label, this.action);

  final String label;
  final BuyCtaAction action;

  bool get enabled => action != BuyCtaAction.none;
}

/// Everything the Buy card shows. It holds no address, order id or checkout
/// URL: the address is read at the tap and the order leaves on a stream.
class BuyGnusState {
  const BuyGnusState({
    this.availability = BuyAvailability.loading,
    this.fiats = const [],
    this.gnus,
    this.fiat,
    this.method,
    this.amountText = '',
    this.quote,
    this.quoting = false,
    this.quoteStale = false,
    this.quoteFetchedAt,
    this.creating = false,
    this.errorMessage = '',
    this.isSandbox = false,
    this.disclaimerAccepted = false,
    this.coin = 'GNUS',
  });

  static const watchOnlyReason =
      "Watch-only wallets can't receive a buy. Change to a wallet you hold the keys for.";

  String get unsupportedAddressReason =>
      '$coin can only be delivered to an Ethereum-style address. Change to another wallet.';

  /// Why [wallet] cannot receive a buy, or null when it can.
  String? blockedReason(Wallet wallet) {
    if (wallet.walletType == WalletType.tracking) {
      return watchOnlyReason;
    }
    if (!isEvmAddress(wallet.address)) {
      return unsupportedAddressReason;
    }
    return null;
  }

  final BuyAvailability availability;
  final List<FiatCurrency> fiats;
  final CryptoCurrency? gnus;
  final FiatCurrency? fiat;
  final PaymentMethod? method;
  final String amountText;
  final Quote? quote;
  final bool quoting;
  final bool quoteStale;
  final DateTime? quoteFetchedAt;
  final bool creating;
  final String errorMessage;
  final bool isSandbox;
  final bool disclaimerAccepted;

  /// The coin being bought and quoted; every coin label on the Buy flow reads
  /// this, so a sandbox build buying a stand-in coin never says GNUS.
  final String coin;

  BuyGnusState copyWith({
    BuyAvailability? availability,
    List<FiatCurrency>? fiats,
    CryptoCurrency? gnus,
    FiatCurrency? fiat,
    PaymentMethod? method,
    String? amountText,
    Quote? quote,
    bool clearQuote = false,
    bool? quoting,
    bool? quoteStale,
    DateTime? quoteFetchedAt,
    bool? creating,
    String? errorMessage,
    bool? isSandbox,
    bool? disclaimerAccepted,
  }) {
    return BuyGnusState(
      availability: availability ?? this.availability,
      fiats: fiats ?? this.fiats,
      gnus: gnus ?? this.gnus,
      fiat: fiat ?? this.fiat,
      method: method ?? this.method,
      amountText: amountText ?? this.amountText,
      quote: clearQuote ? null : (quote ?? this.quote),
      quoting: quoting ?? this.quoting,
      quoteStale: quoteStale ?? this.quoteStale,
      quoteFetchedAt: clearQuote
          ? null
          : (quoteFetchedAt ?? this.quoteFetchedAt),
      creating: creating ?? this.creating,
      errorMessage: errorMessage ?? this.errorMessage,
      isSandbox: isSandbox ?? this.isSandbox,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      coin: coin,
    );
  }

  double? get amount {
    final v = double.tryParse(amountText.trim());
    return (v == null || v.isNaN || v.isInfinite) ? null : v;
  }

  num get min => method?.minimum ?? 0;
  num get max => method?.maximum ?? 0;

  List<num> get presets => presetAmounts(min: min, max: max);

  bool get hasManyMethods => (fiat?.supportedPaymentMethods.length ?? 0) > 1;

  bool get amountInRange {
    final a = amount;
    return a != null && a > 0 && a >= min && (max <= 0 || a <= max);
  }

  String money(num v) {
    final symbol = fiat?.symbol ?? '';
    if (symbol.isEmpty) {
      final plain = NumberFormat.decimalPattern().format(v);
      final code = fiat?.code ?? '';
      return code.isEmpty ? plain : '$plain $code';
    }
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: v == v.roundToDouble() ? 0 : 2,
    ).format(v);
  }

  /// The one label and action of the Buy button, so it cannot disagree with
  /// the numbers above it.
  BuyCta ctaFor(Wallet? wallet) {
    if (wallet == null) {
      return const BuyCta('Add a wallet to buy', BuyCtaAction.none);
    }
    if (blockedReason(wallet) != null) {
      return BuyCta('Buy $coin', BuyCtaAction.none);
    }
    final a = amount;
    if (a == null || a <= 0) {
      return const BuyCta('Enter an amount', BuyCtaAction.none);
    }
    if (a < min) {
      return BuyCta('Enter at least ${money(min)}', BuyCtaAction.none);
    }
    if (max > 0 && a > max) {
      return BuyCta('Enter at most ${money(max)}', BuyCtaAction.none);
    }
    if (creating) {
      return const BuyCta('Opening Banxa checkout', BuyCtaAction.none);
    }
    if (quoteStale) {
      return const BuyCta('Refresh quote', BuyCtaAction.refresh);
    }
    if (quote == null) {
      return const BuyCta('Getting quote...', BuyCtaAction.none);
    }
    return BuyCta('Buy $coin', BuyCtaAction.buy);
  }
}
