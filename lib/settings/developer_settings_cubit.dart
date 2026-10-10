import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/settings/developer_mode.dart';

class DeveloperSettingsState extends Equatable {
  const DeveloperSettingsState({
    this.net = SgnsNet.dev,
    this.busy = false,
    this.status,
    this.netStatus,
  });

  final SgnsNet net;

  /// A Developer mode change is still being persisted.
  final bool busy;

  /// Shown under the Developer mode switch.
  final String? status;

  /// Shown under the SDK network select.
  final String? netStatus;

  @override
  List<Object?> get props => [net, busy, status, netStatus];
}

/// Owns the Developer mode switch and the SDK network choice.
class DeveloperSettingsCubit extends Cubit<DeveloperSettingsState> {
  DeveloperSettingsCubit({
    required Future<SgnsNet> Function() readNet,
    required Future<bool> Function(SgnsNet) writeNet,
  }) : _readNet = readNet,
       _writeNet = writeNet,
       super(const DeveloperSettingsState());

  final Future<SgnsNet> Function() _readNet;
  final Future<bool> Function(SgnsNet) _writeNet;

  bool? _requested;
  int _pending = 0;

  Future<void> load() async {
    final net = await _readNet();
    if (isClosed) {
      return;
    }
    _emit(net: net);
  }

  Future<void> selectNet(SgnsNet net) async {
    try {
      final changed = await _writeNet(net);
      if (isClosed) {
        return;
      }
      _emit(
        net: net,
        netStatus: changed
            ? 'Saved ✅ — Restart required for changes'
            : state.netStatus,
      );
    } catch (e) {
      if (isClosed) {
        return;
      }
      _emit(netStatus: 'Error: $e');
    }
  }

  /// Returns true only when this call turned Developer mode off and it is
  /// still off, so the caller may move the wallet off an EVM testnet.
  Future<bool> setDeveloperMode(bool on) async {
    _requested = on;
    _pending++;
    _emit(status: on ? null : state.status);
    try {
      await DeveloperMode.instance.setEnabled(on);
      if (_superseded(on)) {
        return false;
      }
      // Leaving developer mode must not leave the SDK on a non-default net.
      final changed = await _writeNet(SgnsNet.dev);
      if (isClosed) {
        return false;
      }
      _emit(
        net: SgnsNet.dev,
        netStatus: null,
        status: changed
            ? 'SDK network reset to Dev net ✅ — Restart required for changes'
            : null,
      );
      return !_superseded(on);
    } catch (e) {
      if (!isClosed) {
        _emit(status: 'Error: $e');
      }
      return false;
    } finally {
      _pending--;
      if (!isClosed) {
        _emit();
      }
    }
  }

  bool _superseded(bool on) =>
      on || _requested != false || DeveloperMode.isOn || isClosed;

  static const _keep = Object();

  void _emit({
    SgnsNet? net,
    Object? status = _keep,
    Object? netStatus = _keep,
  }) {
    emit(
      DeveloperSettingsState(
        net: net ?? state.net,
        busy: _pending > 0,
        status: identical(status, _keep) ? state.status : status as String?,
        netStatus: identical(netStatus, _keep)
            ? state.netStatus
            : netStatus as String?,
      ),
    );
  }
}
