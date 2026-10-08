import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/buy_gnus_state.dart';

import 'fake_banxa_api.dart';
import 'fixtures.dart';

const _a = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
const _b = '0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359';

final _card = PaymentMethod(
  id: 'card',
  name: 'Card',
  minimum: 20,
  maximum: 15000,
);
final _usd = FiatCurrency(
  code: 'USD',
  name: 'US Dollar',
  symbol: '\$',
  supportedPaymentMethods: [_card],
);
final _eur = FiatCurrency(
  code: 'EUR',
  name: 'Euro',
  symbol: 'E',
  supportedPaymentMethods: [
    PaymentMethod(id: 'sepa', name: 'SEPA', minimum: 10, maximum: 5000),
    PaymentMethod(id: 'eurcard', name: 'Card', minimum: 10, maximum: 5000),
  ],
);

CryptoCurrency _crypto(String code) => CryptoCurrency(
  code: code,
  name: code,
  blockchains: [
    Blockchain(
      id: 'MATIC',
      description: 'Polygon',
      isDefault: true,
      minimum: 0,
    ),
  ],
);

Quote _quote(String crypto) => Quote(
  paymentMethodId: 'card',
  cryptoAmount: crypto,
  fiatAmount: '100.00',
  processingFee: '2',
  networkFee: '1',
);

FakeBanxaApi _api({List<CryptoCurrency>? cryptos}) => FakeBanxaApi(
  fiats: [_eur, _usd],
  cryptos: cryptos ?? [_crypto('BTC'), _crypto('gnus')],
  quote: _quote('12.5'),
  createResult: OrderResponse(
    orderId: 'ord-123',
    checkoutUrl: 'https://checkout.example/secret-path',
  ),
);

void _run(
  String name,
  void Function(FakeAsync async, BuyGnusCubit cubit, FakeBanxaApi api) body, {
  FakeBanxaApi? api,
  bool load = true,
  bool disclaimer = false,
  Future<void> Function()? save,
  String testCoin = '',
}) {
  test(name, () {
    fakeAsync((async) {
      final fake = api ?? _api();
      final cubit = BuyGnusCubit(
        fake,
        testCoin: testCoin,
        readDisclaimerAccepted: () => disclaimer,
        saveDisclaimerAccepted: save ?? () async {},
        now: async.getClock(DateTime.utc(2026)).now,
      );
      if (load) {
        unawaited(cubit.load(localeName: 'en_US'));
        async.flushMicrotasks();
      }
      body(async, cubit, fake);
      unawaited(cubit.close());
      async.flushMicrotasks();
    });
  });
}

void main() {
  group('load', () {
    _run('opens on locale fiat, first method and the second preset', (
      async,
      cubit,
      api,
    ) {
      final s = cubit.state;
      expect(s.availability, BuyAvailability.ready);
      expect(s.fiat!.code, 'USD');
      expect(s.method!.id, 'card');
      expect(s.amountText, '100');
      expect(api.quoteRequests, hasLength(1));
      expect(api.quoteRequests.single['fiatAmount'], '100');
      expect(api.quoteRequests.single['crypto'], 'gnus');
      expect(s.quote, isNotNull);
    });

    _run(
      'with no GNUS listed it is notListed and asks for no quote',
      (async, cubit, api) {
        expect(cubit.state.availability, BuyAvailability.notListed);
        expect(api.quoteRequests, isEmpty);
      },
      api: _api(cryptos: [_crypto('BTC')]),
    );

    _run(
      'with no key it is notConfigured and calls nothing',
      (async, cubit, api) {
        expect(cubit.state.availability, BuyAvailability.notConfigured);
        expect(api.listCalls, 0);
        expect(api.quoteRequests, isEmpty);
        expect(api.createRequests, isEmpty);
      },
      api: _api()..isConfigured = false,
    );

    _run(
      'a failing list call is loadFailed',
      (async, cubit, api) {
        expect(cubit.state.availability, BuyAvailability.loadFailed);
      },
      api: _api()..listError = Exception('down'),
    );

    _run(
      'the sandbox flag comes from the client',
      (async, cubit, api) => expect(cubit.state.isSandbox, isTrue),
      api: _api()..isSandbox = true,
    );

    _run(
      'a sandbox test coin is what gets quoted and labelled',
      (async, cubit, api) {
        expect(cubit.state.coin, 'ETH');
        expect(api.quoteRequests.single['crypto'], 'eth');
        expect(cubit.state.ctaFor(testWallet(_a)).label, 'Buy ETH');
      },
      api: _api(cryptos: [_crypto('gnus'), _crypto('eth')])..isSandbox = true,
      testCoin: 'eth',
    );

    _run(
      'outside the sandbox the test coin is ignored',
      (async, cubit, api) {
        expect(cubit.state.coin, 'GNUS');
        expect(api.quoteRequests.single['crypto'], 'gnus');
        expect(cubit.state.ctaFor(testWallet(_a)).label, 'Buy GNUS');
      },
      api: _api(cryptos: [_crypto('gnus'), _crypto('eth')]),
      testCoin: 'eth',
    );
  });

  group('quote', () {
    _run('refreshes every 10 seconds', (async, cubit, api) {
      async.elapse(const Duration(seconds: 9));
      expect(api.quoteRequests, hasLength(1));
      async.elapse(const Duration(seconds: 1));
      expect(api.quoteRequests, hasLength(2));
    });

    _run('typing waits 600 ms and asks once, for the last amount', (
      async,
      cubit,
      api,
    ) {
      cubit.setAmountText('1');
      cubit.setAmountText('15');
      cubit.setAmountText('150');
      async.elapse(const Duration(milliseconds: 599));
      expect(api.quoteRequests, hasLength(1));
      async.elapse(const Duration(milliseconds: 1));
      expect(api.quoteRequests, hasLength(2));
      expect(api.quoteRequests.last['fiatAmount'], '150');
    });

    _run('keeps the last numbers while it refreshes', (async, cubit, api) {
      final held = Completer<Quote>();
      api.quoteHandler = () => held.future;
      async.elapse(const Duration(seconds: 10));
      expect(cubit.state.quoting, isTrue);
      expect(cubit.state.quote, isNotNull);
      held.complete(_quote('13'));
      async.flushMicrotasks();
      expect(cubit.state.quoting, isFalse);
      expect(cubit.state.quote!.cryptoAmount, '13');
    });

    _run('an older answer never overwrites a newer one', (async, cubit, api) {
      final first = Completer<Quote>();
      final second = Completer<Quote>();
      final queue = [first, second];
      api.quoteHandler = () => queue.removeAt(0).future;
      unawaited(cubit.refreshQuote());
      unawaited(cubit.refreshQuote());
      async.flushMicrotasks();
      second.complete(_quote('newer'));
      async.flushMicrotasks();
      first.complete(_quote('older'));
      async.flushMicrotasks();
      expect(cubit.state.quote!.cryptoAmount, 'newer');
    });

    _run('a failed refresh keeps the old quote and marks it stale', (
      async,
      cubit,
      api,
    ) {
      final before = cubit.state.quote;
      api.quoteError = const BanxaRequestException(500);
      async.elapse(const Duration(seconds: 10));
      expect(cubit.state.quote, same(before));
      expect(cubit.state.quoteStale, isTrue);
      api.quoteError = null;
      async.elapse(const Duration(seconds: 10));
      expect(cubit.state.quoteStale, isFalse);
    });

    _run('pause stops refreshes and resume asks at once', (async, cubit, api) {
      cubit.pause();
      async.elapse(const Duration(seconds: 60));
      expect(api.quoteRequests, hasLength(1));
      cubit.resume();
      async.flushMicrotasks();
      expect(api.quoteRequests, hasLength(2));
    });

    _run('below the minimum clears the quote and asks for nothing', (
      async,
      cubit,
      api,
    ) {
      cubit.setAmountText('10');
      async.elapse(const Duration(seconds: 60));
      expect(cubit.state.quote, isNull);
      expect(api.quoteRequests, hasLength(1));
      final cta = cubit.state.ctaFor(testWallet(_a));
      expect(cta.label, 'Enter at least \$20');
      expect(cta.enabled, isFalse);
    });

    _run('picking another fiat resets method and amount, then re-quotes', (
      async,
      cubit,
      api,
    ) {
      cubit.selectFiat(_eur);
      async.flushMicrotasks();
      expect(cubit.state.method!.id, 'sepa');
      expect(cubit.state.amountText, '50');
      expect(cubit.state.hasManyMethods, isTrue);
      expect(api.quoteRequests.last['fiat'], 'EUR');
      expect(api.quoteRequests.last['fiatAmount'], '50');
    });
  });

  group('ctaFor', () {
    final ready = BuyGnusState(
      availability: BuyAvailability.ready,
      fiat: _usd,
      method: _card,
      amountText: '100',
      quote: _quote('12.5'),
    );
    final wallet = testWallet(_a);

    test('walks the ladder in order', () {
      var cta = ready.ctaFor(null);
      expect([cta.label, cta.enabled], ['Add a wallet to buy', false]);

      cta = ready.ctaFor(testWallet(_a, type: WalletType.tracking));
      expect([cta.label, cta.enabled], ['Buy GNUS', false]);

      cta = ready.ctaFor(testWallet('0x123'));
      expect(cta.enabled, isFalse);

      cta = ready.copyWith(amountText: '').ctaFor(wallet);
      expect([cta.label, cta.enabled], ['Enter an amount', false]);

      cta = ready.copyWith(amountText: '20000').ctaFor(wallet);
      expect([cta.label, cta.enabled], ['Enter at most \$15,000', false]);

      cta = ready.copyWith(creating: true).ctaFor(wallet);
      expect([cta.label, cta.enabled], ['Opening Banxa checkout', false]);

      cta = ready.copyWith(quoteStale: true).ctaFor(wallet);
      expect(cta.label, 'Refresh quote');
      expect(cta.action, BuyCtaAction.refresh);

      cta = ready.copyWith(clearQuote: true).ctaFor(wallet);
      expect([cta.label, cta.enabled], ['Getting quote...', false]);

      cta = ready.ctaFor(wallet);
      expect(cta.label, 'Buy GNUS');
      expect(cta.action, BuyCtaAction.buy);
    });
  });

  group('createOrder', () {
    _run('sends the wallet handed in at the tap, not the one quoted with', (
      async,
      cubit,
      api,
    ) {
      unawaited(cubit.createOrder(testWallet(_b)));
      async.flushMicrotasks();
      final sent = api.createRequests.single;
      expect(sent['walletAddress'], _b);
      expect(sent['externalCustomerId'], 'gw-${_b.toLowerCase()}');
    });

    _run('a paused quote is stale and never becomes an order', (
      async,
      cubit,
      api,
    ) {
      cubit.pause();
      expect(cubit.state.quoteStale, isTrue);
      unawaited(cubit.createOrder(testWallet(_a)));
      async.flushMicrotasks();
      expect(api.createRequests, isEmpty);
    });

    _run('a quote older than two refresh intervals is refreshed, not used', (
      async,
      cubit,
      api,
    ) {
      api.quoteHandler = () => Completer<Quote>().future;
      async.elapse(const Duration(seconds: 25));
      unawaited(cubit.createOrder(testWallet(_a)));
      async.flushMicrotasks();
      expect(api.createRequests, isEmpty);
      expect(cubit.state.quoteStale, isTrue);
    });

    _run('a watch-only wallet or a non-EVM address sends nothing', (
      async,
      cubit,
      api,
    ) {
      unawaited(cubit.createOrder(testWallet(_a, type: WalletType.tracking)));
      unawaited(cubit.createOrder(testWallet('bc1qexample')));
      unawaited(cubit.createOrder(null));
      async.flushMicrotasks();
      expect(api.createRequests, isEmpty);
    });

    _run('success emits the order once and keeps it out of state', (
      async,
      cubit,
      api,
    ) {
      final events = <BuyOrderStarted>[];
      cubit.orderStarted.listen(events.add);
      unawaited(cubit.createOrder(testWallet(_a)));
      async.flushMicrotasks();
      expect(events, hasLength(1));
      expect(events.single.orderId, 'ord-123');
      expect(events.single.checkoutUrl, 'https://checkout.example/secret-path');
      expect(cubit.state.creating, isFalse);
      final text = cubit.state.toString();
      expect(text, isNot(contains('ord-123')));
      expect(text, isNot(contains('secret-path')));
    });

    _run('a rejected order leaves a plain error and quotes keep coming', (
      async,
      cubit,
      api,
    ) {
      final events = <BuyOrderStarted>[];
      cubit.orderStarted.listen(events.add);
      api.createError = const BanxaRequestException(422);
      unawaited(cubit.createOrder(testWallet(_a)));
      async.flushMicrotasks();
      expect(cubit.state.errorMessage, BuyGnusCubit.createFailedMessage);
      expect(cubit.state.errorMessage, isNot(contains('422')));
      expect(cubit.state.creating, isFalse);
      expect(events, isEmpty);
      final before = api.quoteRequests.length;
      async.elapse(const Duration(seconds: 10));
      expect(api.quoteRequests.length, before + 1);
    });
  });

  group('disclaimer', () {
    _run(
      'state reads the injected reader',
      (async, cubit, api) => expect(cubit.state.disclaimerAccepted, isTrue),
      disclaimer: true,
    );

    var saved = 0;
    _run(
      'accepting calls the saver once',
      (async, cubit, api) {
        expect(cubit.state.disclaimerAccepted, isFalse);
        unawaited(cubit.acceptDisclaimer());
        async.flushMicrotasks();
        expect(saved, 1);
        expect(cubit.state.disclaimerAccepted, isTrue);
      },
      save: () async {
        saved++;
      },
    );
  });
}
