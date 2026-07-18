import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';
import 'package:genius_wallet/components/inputs/gw_switch.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/scaffold/gw_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

/// SPD log levels exposed in dropdown order (most verbose → silent).
const _spdlogLevels = [
  'trace',
  'debug',
  'info',
  'warn',
  'err',
  'critical',
  'off',
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Log config state ──
  Map<String, String> _loggerLevels = {};
  bool _logLoading = true;

  // ── Network config state ──
  Map<String, dynamic> _networkConfig = {};
  bool _networkLoading = true;

  // ── CRDT config state ──
  Map<String, dynamic> _crdtConfig = {};
  bool _crdtLoading = true;

  // ── Status messages ──
  String? _logStatus;
  String? _networkStatus;
  String? _crdtStatus;

  GeniusApi get _api => context.read<GeniusApi>();

  @override
  void initState() {
    super.initState();
    _loadAllConfigs();
  }

  Future<void> _loadAllConfigs() async {
    await Future.wait([
      _loadLogConfig(),
      _loadNetworkConfig(),
      _loadCrdtConfig(),
    ]);
  }

  /// Reads a merged config file from the SDK directory.
  Future<Map<String, dynamic>> _readSdkJson(String fileName) async {
    final file = File('${_api.jsonFilePath}$fileName');
    if (!await file.exists()) return {};
    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  /// Writes overrides to `overridesDir/$fileName`.
  Future<void> _writeOverrides(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final dir = Directory(_api.overridesDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<void> _loadLogConfig() async {
    setState(() => _logLoading = true);
    final json = await _readSdkJson('log_config.json');
    final loggers = json['loggers'];
    if (loggers is Map<String, dynamic>) {
      _loggerLevels = loggers.map((k, v) => MapEntry(k, v.toString()));
    } else {
      _loggerLevels = {};
    }
    setState(() => _logLoading = false);
  }

  Future<void> _applyLogConfig() async {
    setState(() => _logStatus = 'Applying log changes...');
    try {
      // Write overrides
      await _writeOverrides('log_config.json', {'loggers': _loggerLevels});
      // Re-merge and write to SDK dir
      await _api.prepareConfigFiles();
      // Reload in native SDK
      _api.reloadLogConfig();
      setState(() => _logStatus = 'Log levels applied ✅');
    } catch (e) {
      setState(() => _logStatus = 'Error: $e');
    }
  }

  Future<void> _loadNetworkConfig() async {
    setState(() => _networkLoading = true);
    final json = await _readSdkJson('network_config.json');
    final whitelist = _api.networkConfigOverrideKeys;
    _networkConfig = Map.fromEntries(
      json.entries.where((e) => whitelist.contains(e.key)),
    );
    setState(() => _networkLoading = false);
  }

  Future<void> _saveNetworkConfig() async {
    setState(() => _networkStatus = 'Saving...');
    try {
      await _writeOverrides('network_config.json', _networkConfig);
      setState(() => _networkStatus = 'Saved ✅ — Restart required for changes');
    } catch (e) {
      setState(() => _networkStatus = 'Error: $e');
    }
  }

  Future<void> _loadCrdtConfig() async {
    setState(() => _crdtLoading = true);
    _crdtConfig = await _readSdkJson('crdt_config.json');
    setState(() => _crdtLoading = false);
  }

  Future<void> _saveCrdtConfig() async {
    setState(() => _crdtStatus = 'Saving...');
    try {
      await _writeOverrides('crdt_config.json', _crdtConfig);
      setState(() => _crdtStatus = 'Saved ✅ — Restart required for changes');
    } catch (e) {
      setState(() => _crdtStatus = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen wrapper choice: GWScreen (not AppScreenView) — see SUMMARY for
    // rationale (this screen owns a Scaffold+AppBar today, matching the
    // sibling /logs route's SubmitLogsScreen pattern; AppScreenView has no
    // appBar slot at all, so picking it would drop the "Settings" title —
    // a structural change, not a re-skin).
    return GWScreen(
      appBar: AppBar(title: const Text('Settings')),
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      maxContentWidth: GeniusBreakpoints.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: GeniusWalletConsts.space12,
        children: [
          _buildLogSection(),
          _buildNetworkSection(),
          _buildCrdtSection(),
        ],
      ),
    );
  }

  Widget _buildLogSection() {
    return _buildSectionCard(
      title: 'Log Config',
      icon: Icons.terminal,
      status: _logStatus,
      loading: _logLoading,
      action: GWButton(
        variant: GWButtonVariant.primary,
        label: 'Apply Log Changes',
        leading: const Icon(Icons.play_arrow),
        onPressed: _applyLogConfig,
      ),
      child: _loggerLevels.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No loggers loaded. SDK may not be initialized.'),
            )
          : Column(
              children: _loggerLevels.entries.map(_buildLoggerRow).toList(),
            ),
    );
  }

  Widget _buildLoggerRow(MapEntry<String, String> entry) {
    final currentLevel = _spdlogLevels.contains(entry.value)
        ? entry.value
        : 'err'; // default if unknown
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              entry.key,
              style: const TextStyle(fontFamily: 'JetBrainsMono'),
            ),
          ),
          Expanded(
            flex: 2,
            child: GWSelect<String>(
              value: currentLevel,
              items: _spdlogLevels
                  .map((l) => GWSelectItem(value: l, label: l))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _loggerLevels[entry.key] = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSection() {
    return _buildSectionCard(
      title: 'Network Config',
      icon: Icons.lan,
      status: _networkStatus,
      loading: _networkLoading,
      action: GWButton(
        variant: GWButtonVariant.secondary,
        label: 'Save Network Overrides',
        leading: const Icon(Icons.save),
        onPressed: _saveNetworkConfig,
      ),
      child: _configFieldsTable(
        config: _networkConfig,
        keyLabels: const {
          'pubsub_port': 'PubSub Port',
          'pubsub_bind_address': 'Bind Address',
          'upnp_enabled': 'UPnP',
          'high_water': 'High Water',
          'low_water': 'Low Water',
        },
        boolKeys: const {'upnp_enabled'},
        numberKeys: const {'high_water', 'low_water'},
      ),
    );
  }

  Widget _buildCrdtSection() {
    return _buildSectionCard(
      title: 'CRDT Config',
      icon: Icons.backup,
      status: _crdtStatus,
      loading: _crdtLoading,
      action: GWButton(
        variant: GWButtonVariant.secondary,
        label: 'Save CRDT Overrides',
        leading: const Icon(Icons.save),
        onPressed: _saveCrdtConfig,
      ),
      child: _configFieldsTable(
        config: _crdtConfig,
        keyLabels: const {
          'backup_enabled': 'Backup Enabled',
          'backup_interval_minutes': 'Interval (min)',
          'backup_keep_count': 'Keep Count',
          'backup_auto_restore_on_repair_failure': 'Auto Restore',
        },
        boolKeys: const {
          'backup_enabled',
          'backup_auto_restore_on_repair_failure',
        },
        numberKeys: const {'backup_interval_minutes', 'backup_keep_count'},
      ),
    );
  }

  // ── Reusable Widgets ──

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String? status,
    required bool loading,
    required Widget action,
    required Widget child,
  }) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this screen to re-skin on a LIVE appearance toggle (04-02 D-02) — never
    // read GeniusWalletColors' static getters for this screen's own chrome.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GWIcon.material(icon, size: 20, color: gw.textPrimary),
              const SizedBox(width: GeniusWalletConsts.space4),
              Text(
                title,
                style: GeniusWalletTypography.titleMd.copyWith(
                  color: gw.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // M3's default Divider color (colorScheme.outlineVariant) applies
          // now that 04-01 dropped dividerTheme (04-RESEARCH §1/§4.1); set an
          // explicit appearance-aware color here rather than leave it to the
          // default so contrast against GWCard's surfaceElevated fill is
          // deterministic in both modes — confirm at the Task 3 walk and
          // swap to gw.borderStrong if borderSubtle reads too faint.
          Divider(color: gw.borderSubtle),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            child,
          const SizedBox(height: GeniusWalletConsts.space4),
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(bottom: GeniusWalletConsts.space4),
              child: Text(
                status,
                // ✅/Error logic unchanged (§7 strings preserved verbatim);
                // only the color mapping changes. statusSuccess/statusError
                // are mode-invariant (stay on the static getter); the
                // neutral state MUST come from the extension (gw) so it
                // flips on a live toggle instead of rendering stale.
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: status.contains('✅')
                      ? GeniusWalletColors.statusSuccess
                      : status.contains('Error')
                      ? GeniusWalletColors.statusError
                      : gw.textSecondary,
                ),
              ),
            ),
          Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    );
  }

  /// Builds a table of config fields with smart editors per type.
  Widget _configFieldsTable({
    required Map<String, dynamic> config,
    required Map<String, String> keyLabels,
    required Set<String> boolKeys,
    Set<String> numberKeys = const {},
  }) {
    if (config.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No config loaded.'),
      );
    }

    return Column(
      spacing: GeniusWalletConsts.space4,
      children: config.entries.map((entry) {
        final label = keyLabels[entry.key] ?? entry.key;
        if (boolKeys.contains(entry.key)) {
          // GWSwitch renders its own label + 48px-tap-target toggle in a
          // Row -- dropping the ListTile wrapper per §3.1's mapping table.
          return GWSwitch(
            label: label,
            value: entry.value == true,
            onChanged: (v) => setState(() => config[entry.key] = v),
          );
        }
        return Row(
          children: [
            Expanded(child: Text(label)),
            Expanded(
              child: GWTextField(
                initialValue: entry.value.toString(),
                keyboardType: numberKeys.contains(entry.key)
                    ? TextInputType.number
                    : TextInputType.text,
                onChanged: (v) {
                  if (numberKeys.contains(entry.key)) {
                    final parsed = int.tryParse(v);
                    if (parsed != null) {
                      setState(() => config[entry.key] = parsed);
                    }
                  } else {
                    setState(() => config[entry.key] = v);
                  }
                },
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
