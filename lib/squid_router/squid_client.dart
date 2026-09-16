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
final DefaultApi _squidApi =
    (Squidrouter()..setApiKey('IntegratorId', kSquidIntegratorId))
        .getDefaultApi();

/// The Squid v2 client. The base path comes from the generated client.
DefaultApi squidApi() => _squidApi;
