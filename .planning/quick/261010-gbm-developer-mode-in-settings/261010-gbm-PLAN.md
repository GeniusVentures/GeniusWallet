---
quick_id: 261010-gbm
phase: quick-261010-gbm
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [GBM-01, GBM-02, GBM-03, GBM-04, GBM-05, GBM-06]
files_modified: [lib/hive/constants/cache.dart, lib/settings/developer_mode.dart, lib/main.dart, lib/settings/settings_screen.dart, test/settings/developer_mode_test.dart, packages/genius_api/lib/src/genius_api.dart, lib/logs/submit_logs_screen.dart, test/settings/sgns_net_test.dart, lib/providers/network_provider.dart, lib/bloc/app_bloc.dart, lib/network/network_dropdown_selector.dart, test/account/account_drawer_network_section_test.dart]
estimate:
  tokens: 80000
  raw_tokens: 80000
  tasks: 3
  confidence: low
must_haves:
  truths:
    - "D-01: Settings has an Advanced card with a 'Developer mode' switch, OFF on a fresh install, persisted in the preferences box and restored on restart."
    - "D-02: OFF hides Log/Network/CRDT Config; ON shows them unchanged under a Developer heading."
    - "D-03: under Developer, SDK network Dev/Test/Main net (144/963/369) writes overrides/sgns_config.json; the next start's sgns_config.json carries that net_id and every other key from the bundle; Dev net deletes the override; status says restart required."
    - "D-04: switching OFF resets the SDK network to Dev net, saying restart required only if it changed."
    - "D-05: OFF hides the picker's Testnet group, a persisted testnet restores as the first mainnet, and switching OFF on a testnet moves the selection (and the desktop header chip) to the first mainnet."
    - "D-06: opening Settings before the SDK initialises (no wallet) no longer throws LateInitializationError."
  artifacts: [lib/settings/developer_mode.dart, test/settings/developer_mode_test.dart, test/settings/sgns_net_test.dart]
  key_links:
    - "main.dart DeveloperMode.instance.load() runs before runApp, so AppBloc's network restore sees the persisted value"
    - "prepareConfigFiles -> mergeSgnsConfig -> <appData>/sgns_config.json, written before GeniusSDKInit reads it"
    - "NetworkPicker + restoreSelectedNetwork + Settings OFF handler all read DeveloperMode.isOn"
---

<objective>
Add a persisted Developer mode switch to Settings that gates the SDK diagnostics sections, adds an
SDK net_id choice applied on next start, and gates EVM testnets. All six locked decisions (D-01..D-06)
are implemented as specified. One commit per task on feat/developer-mode.
</objective>

<context>
@AGENTS.md @lib/settings/settings_screen.dart @lib/network/network_dropdown_selector.dart
@lib/theme/gw_appearance.dart (store pattern); test/theme/gw_appearance_preference_test.dart (in-memory Hive box)
@packages/genius_api/lib/src/genius_api.dart lines 308-346, 416-440, 760-877; lib/bloc/app_bloc.dart 185-195
@test/account/account_drawer_network_section_test.dart (fixture: 3 mainnets + testnet _netTest between them).
Facts checked: networks.json lists Ethereum first; WalletDetailsCubit and NetworkProvider are provided app-wide
(main.dart ~186, ~437); jsonFilePath has exactly 4 callers: settings_screen.dart:76, :94 and
submit_logs_screen.dart:203, :290; no test references it.
Flutter: FL=/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter (not on PATH).
</context>

<tasks>

<task type="tracer">
  <name>Task 1: Developer mode switch end-to-end: Settings switch -> store -> Hive -> restored on start</name>
  <files>lib/hive/constants/cache.dart, lib/settings/developer_mode.dart, lib/main.dart, lib/settings/settings_screen.dart, test/settings/developer_mode_test.dart</files>
  <action>Per D-01: add developerModeKey = 'developer_mode' beside appearanceModeKey in cache.dart. Create
  DeveloperMode in lib/settings/developer_mode.dart: a ValueNotifier of bool singleton mirroring GWAppearance
  (private ctor seeded false, static instance, static isOn getter, load() sets value to whether the preferences
  box holds true under developerModeKey, setEnabled(bool) returns early when unchanged, sets value first, then
  awaits the Hive put). No new dependency. Call DeveloperMode.instance.load() in main.dart directly after
  GWAppearance.instance.load() (~line 167).
  Per D-01/D-02 in settings_screen.dart build: after the Appearance card add an 'Advanced' section card holding
  a new _DeveloperModeSwitch StatelessWidget (GWSwitch, label 'Developer mode', one-line description). Wrap the
  Developer part in a ValueListenableBuilder on DeveloperMode.instance: when true, render GWKicker('Developer')
  then the existing Log, Network and CRDT sections unchanged; when false render none of them. New UI must be
  StatelessWidgets (no new _buildX methods); the existing _buildSectionCard may host them as child. Colours and
  spacing only from GWColors / GeniusWalletConsts. Do not refactor existing helpers.
  Test (test/settings/developer_mode_test.dart, in-memory box exactly like the appearance test): no key loads
  false; setEnabled(true) stores true under developerModeKey and a fresh load() reads true; reset in teardown.</action>
  <verify><automated>FL=/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter; $FL test test/settings/developer_mode_test.dart && $FL analyze lib/settings lib/main.dart lib/hive</automated></verify>
  <done>Switch persists across restart; diagnostics sections appear only while ON; test green; committed.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: SDK network choice applied via overrides/sgns_config.json; reset on OFF; pre-init guard</name>
  <files>packages/genius_api/lib/src/genius_api.dart, lib/settings/settings_screen.dart, lib/logs/submit_logs_screen.dart, test/settings/sgns_net_test.dart</files>
  <behavior>
    - No override file: mergeSgnsConfig returns the bundled string unchanged (default 144 for everyone).
    - Override with net_id 963 plus a node_type key: merged net_id is 963, node_type stays the bundled value.
    - Override net_id 999 or non-int: ignored, merged net_id stays 144.
    - writeSgnsNet(main) returns true and readSgnsNet then returns main; writeSgnsNet(dev) returns true and
      deletes the file; a second writeSgnsNet(dev) returns false. Works when the overrides dir does not exist yet.
  </behavior>
  <action>Per D-03, top-level in genius_api.dart (exported by the existing barrel): enum SgnsNet with dev(144),
  test(963), main(369) and an int netId (values from SuperGenius sgns_version.hpp). readSgnsNet(Directory
  overridesDir) returns the SgnsNet whose netId equals overrides/sgns_config.json's net_id, else dev.
  writeSgnsNet(Directory, SgnsNet) creates the dir if missing, writes only the net_id key, or deletes the file for
  dev (the bundled default), and returns whether the effective net changed. mergeSgnsConfig(String bundledJson,
  Directory overridesDir) returns bundledJson verbatim when readSgnsNet is dev, else the bundled map with only
  net_id replaced; no other override key is ever read (this is the net_id-only whitelist). In prepareConfigFiles
  (~837-840) write mergeSgnsConfig's result instead of the verbatim asset. Add GeniusApi wrappers sgnsNet() and
  setSgnsNet(SgnsNet) over Directory(await overridesDirPath) so the widget never touches File/Directory.
  Per D-06: make jsonFilePath and overridesDirPath Future of String getters built from appDataDirectory() (the
  same folder prepareConfigFiles returns), drop the late base-path field and keep the init path in a local in
  _initSDK; add await at the 4 callers listed in context.
  Settings: per D-03 a 'SDK Network' section card first under the Developer heading, holding an _SdkNetSelect
  StatelessWidget (GWSelect, labels 'Dev net', 'Test net', 'Main net'); state field loaded in _loadAllConfigs;
  on change call _api.setSgnsNet and show 'Saved ✅ — Restart required for changes' when it changed, 'Error: e'
  on failure (the status colour logic keys on those markers). Per D-04: the switch's OFF path awaits
  setEnabled(false) then _api.setSgnsNet(SgnsNet.dev); if it changed, the Advanced card's status reads 'SDK
  network reset to Dev net ✅ — Restart required for changes'. ON clears that status. Check mounted after awaits.
  Test file test/settings/sgns_net_test.dart uses a temp Directory (no GeniusApi instance, no path_provider).</action>
  <verify><automated>FL=/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter; $FL test test/settings/sgns_net_test.dart && $FL analyze lib/settings lib/logs packages/genius_api/lib</automated></verify>
  <done>Behaviour cases pass; a non-default choice reaches sgns_config.json on the next start; OFF resets it;
  Settings opens without a wallet; committed.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Testnets only in Developer mode (picker, restore, OFF move, header chip)</name>
  <files>lib/providers/network_provider.dart, lib/bloc/app_bloc.dart, lib/network/network_dropdown_selector.dart, lib/settings/settings_screen.dart, test/account/account_drawer_network_section_test.dart</files>
  <behavior>
    - restoreSelectedNetwork(_networks, chainId/rpcUrl of _netTest, allowTestnets: false) is _netEth; with true it is _netTest; unknown ids give _netEth.
    - Picker with Developer mode OFF: no testnet-section key, and searching 'delta' shows GWEmptyState.
    - Existing picker tests still pass with Developer mode ON (setUp sets DeveloperMode.instance.value = true, tearDown false).
  </behavior>
  <action>Per D-05: add top-level restoreSelectedNetwork(List of Network, {int? chainId, String? rpcUrl, required
  bool allowTestnets}) in network_provider.dart: the persisted match when it is allowed, else the first mainnet
  (networks.first if none). app_bloc.dart ~190-195 uses it with allowTestnets: DeveloperMode.isOn. NetworkPicker
  build: filter widget.networks to mainnets before the search when DeveloperMode.isOn is false, so the empty
  state stays correct. NetworkDropdownSelector: derive the shown network from context.select on
  WalletDetailsCubit's state.selectedNetwork, falling back to restoreSelectedNetwork(networks, allowTestnets:
  DeveloperMode.isOn); delete its own Hive read, saved fields, local selected state and the unused
  initialSelected param, since local state would keep showing a testnet after the move below.
  Settings OFF path (after the D-04 reset): read WalletDetailsCubit and NetworkProvider before the first await;
  if the cubit's selectedNetwork is a testnet, call NetworkSelection.apply with restoreSelectedNetwork(networks,
  allowTestnets: false). Add the behaviour cases to the existing picker test file using its fixture.</action>
  <verify><automated>FL=/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter; $FL test test/account/account_drawer_network_section_test.dart && $FL analyze lib</automated></verify>
  <done>Testnets invisible and unrestorable while OFF; OFF on a testnet lands on the first mainnet; committed.</done>
</task>

</tasks>

<threat_model>
| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-gbm-01 | Tampering | overrides/sgns_config.json (user-writable disk) | medium | mitigate | only net_id is read, only 144/963/369 accepted, anything else falls back to the bundle |
| T-gbm-02 | Elevation | Developer mode left with a non-default net or a testnet | medium | mitigate | OFF deletes the override and moves a testnet selection to the first mainnet; restore refuses testnets while OFF |
| T-gbm-03 | Info disclosure | DeveloperMode store | low | accept | holds one bool; no key, mnemonic or address enters it |
</threat_model>

<verification>
Before the first commit run git config user.email and confirm it is braianwegmann@gmail.com. Commit per task on
feat/developer-mode, conventional message, no Co-Authored-By or Claude lines. Do not touch repo-root banxa/ or
squidrouter/. At the end, quote real output of: dart format on changed files; $FL analyze (exit 0); full $FL test
(baseline 2532 pass / 6 skipped, expect that plus the new tests, zero failures); bash tool/check_brace_style.sh;
bash tool/check_raw_colors.sh. Source comments: why-only, doc comments 3 lines max, no plan or decision ids.
</verification>
<success_criteria>All six truths hold, the three test files are green, full-suite count quoted against 2532/6.</success_criteria>
<output>
Create .planning/quick/261010-gbm-developer-mode-in-settings/261010-gbm-SUMMARY.md (40 lines max).
</output>
