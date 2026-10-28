import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';

String? _canonical(String raw) =>
    GnusOrigin.tryParse(GnusTransport.webview, raw)?.value;

void main() {
  test('one origin, however it is spelled', () {
    for (final raw in [
      'https://dash.example',
      'HTTPS://DASH.EXAMPLE',
      'https://dash.example:443',
      'https://dash.example/',
      'https://dash.example/path?q=1#frag',
      'https://dash%2eexample',
    ]) {
      expect(_canonical(raw), 'https://dash.example', reason: raw);
    }
    expect(_canonical('http://LocalHost:8080/x'), 'http://localhost:8080');
    expect(_canonical('http://dash.example:443'), 'http://dash.example:443');
    expect(_canonical('https://[::1]:8443'), 'https://[::1]:8443');
  });

  test('rejects what is not a plain http or https origin', () {
    for (final raw in [
      '',
      'null',
      'dash.example',
      'https:dash.example',
      'file:///etc/passwd',
      'javascript:alert(1)',
      'wss://dash.example',
      'https://user@dash.example',
      'https://dash.example@evil.example',
      'https://dash\n.example',
      'https://dásh.example',
      'https://dash.example:0',
      'https://${'a' * 2048}.example',
    ]) {
      expect(_canonical(raw), isNull, reason: raw);
    }
  });

  test('the transport is part of the identity', () {
    final web = GnusOrigin.parse(GnusTransport.webview, 'https://dash.example');
    final wc = GnusOrigin.parse(
      GnusTransport.walletconnect,
      'https://dash.example',
    );

    expect(web.value, wc.value);
    expect(web, isNot(wc));
    expect(
      web,
      GnusOrigin.parse(GnusTransport.webview, 'HTTPS://dash.example'),
    );
  });

  test('parse answers 4100 for an origin it cannot identify', () {
    expect(
      () => GnusOrigin.parse(GnusTransport.walletconnect, 'null'),
      throwsA(
        isA<GnusRpcError>().having(
          (e) => e.code,
          'code',
          GnusRpcCode.unauthorized,
        ),
      ),
    );
  });
}
