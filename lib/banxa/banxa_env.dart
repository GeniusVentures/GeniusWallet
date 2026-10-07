/// Build with --dart-define=GW_BANXA_API_KEY=KEY to enable Banxa; add
/// --dart-define=GW_BANXA_SANDBOX=true (with a sandbox key) to use the sandbox.
/// Both are compile-time constants, so changing one needs a rebuild.
const String kBanxaApiKey = String.fromEnvironment('GW_BANXA_API_KEY');
const bool kBanxaSandbox = bool.fromEnvironment('GW_BANXA_SANDBOX');

/// Sandbox only: buy this coin instead of GNUS, so checkout can be walked
/// while Banxa does not list GNUS. Ignored outside the sandbox.
const String kBanxaTestCoin = String.fromEnvironment('GW_BANXA_TEST_COIN');

const String kBanxaPartnerCode = 'gnus';

String banxaApiBase({required bool sandbox}) {
  final host = sandbox ? 'api.banxa-sandbox.com' : 'api.banxa.com';
  return 'https://$host/$kBanxaPartnerCode/v2';
}
