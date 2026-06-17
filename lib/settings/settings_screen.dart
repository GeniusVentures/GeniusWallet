import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

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

  // ────────────────────────────────────────────────────────────
  // Log Config
  // ────────────────────────────────────────────────────────────

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

  // ────────────────────────────────────────────────────────────
  // Network Config
  // ────────────────────────────────────────────────────────────

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

  // ────────────────────────────────────────────────────────────
  // CRDT Config
  // ────────────────────────────────────────────────────────────

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

  // ────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogSection(),
            const SizedBox(height: 24),
            _buildNetworkSection(),
            const SizedBox(height: 24),
            _buildCrdtSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Log Config Section ──

  Widget _buildLogSection() {
    return _buildSectionCard(
      title: 'Log Config',
      icon: Icons.terminal,
      status: _logStatus,
      loading: _logLoading,
      action: _buildApplyButton(
        label: 'Apply Log Changes',
        onPressed: _applyLogConfig,
        isPrimary: true,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              entry.key,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: currentLevel,
              isExpanded: true,
              underline: const SizedBox(),
              items: _spdlogLevels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
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

  // ── Network Config Section ──

  Widget _buildNetworkSection() {
    return _buildSectionCard(
      title: 'Network Config',
      icon: Icons.lan,
      status: _networkStatus,
      loading: _networkLoading,
      action: _buildApplyButton(
        label: 'Save Network Overrides',
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

  // ── CRDT Config Section ──

  Widget _buildCrdtSection() {
    return _buildSectionCard(
      title: 'CRDT Config',
      icon: Icons.backup,
      status: _crdtStatus,
      loading: _crdtLoading,
      action: _buildApplyButton(
        label: 'Save CRDT Overrides',
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
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              child,
            const SizedBox(height: 8),
            if (status != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: status.contains('✅')
                        ? Colors.greenAccent
                        : status.contains('Error')
                        ? Colors.redAccent
                        : Colors.grey,
                  ),
                ),
              ),
            Align(alignment: Alignment.centerRight, child: action),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton({
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(isPrimary ? Icons.play_arrow : Icons.save, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? Colors.green
            : Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
      children: config.entries.map((entry) {
        final label = keyLabels[entry.key] ?? entry.key;
        if (boolKeys.contains(entry.key)) {
          return SwitchListTile(
            title: Text(label),
            value: entry.value == true,
            onChanged: (v) => setState(() => config[entry.key] = v),
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: entry.value.toString(),
                  keyboardType: numberKeys.contains(entry.key)
                      ? TextInputType.number
                      : TextInputType.text,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    if (numberKeys.contains(entry.key)) {
                      final parsed = int.tryParse(v);
                      if (parsed != null)
                        setState(() => config[entry.key] = parsed);
                    } else {
                      setState(() => config[entry.key] = v);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
