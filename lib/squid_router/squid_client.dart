import 'package:dio/dio.dart';
import 'package:squidrouter/squidrouter.dart';

/// Squid integrator ID, supplied at build time:
///   `flutter run --dart-define=GW_SQUID_INTEGRATOR_ID=<the id>`
const String kSquidIntegratorId = String.fromEnvironment(
  'GW_SQUID_INTEGRATOR_ID',
);

/// Whether this build can talk to Squid at all. Without an integrator ID
/// every call comes back 401, so the swap path must refuse rather than try.
const bool squidConfigured = kSquidIntegratorId != '';

/// Built on first use. `setApiKey` is the only injection point there is —
/// the interceptor reads it and writes the `x-integrator-id` header.
final Squidrouter _squid = Squidrouter()
  ..setApiKey('IntegratorId', kSquidIntegratorId);

final DefaultApi _squidApi = _squid.getDefaultApi();

/// The Squid v2 client. The base path comes from the generated client.
DefaultApi squidApi() => _squidApi;

/// The same transport the generated client uses — base path, timeouts and the
/// integrator-ID interceptor included. For the one endpoint whose generated
/// response model cannot parse what the live API returns.
Dio squidDio() => _squid.dio;

/// What the interceptor looks for before it writes the header. Copied from
/// the generated call sites, which set it per request.
const Map<String, dynamic> kSquidAuthExtra = {
  'secure': [
    {
      'type': 'apiKey',
      'name': 'IntegratorId',
      'keyName': 'x-integrator-id',
      'where': 'header',
    },
  ],
};
