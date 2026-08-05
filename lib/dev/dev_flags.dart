/// Opt-in switch for developer-only affordances in debug builds.
///
/// These used to key straight off `kDebugMode`, which meant every debug build
/// carried them — the header test buttons crowded (and overflowed) the real
/// action row, and the onboarding screen showed a "Mock" button that injects a
/// fake wallet and fake transactions. That makes reviewing the actual UI in a
/// debug build harder than it needs to be, and mock data can be mistaken for
/// real data.
///
/// They stay one flag away. Enable with:
///   flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true
///
/// Always combine with `kDebugMode` at the call site so these can never ship in
/// a release build, whatever the define says.
const bool kShowDevTools = bool.fromEnvironment('GW_DEV_TOOLS');
