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

  /// A Developer mode or SDK network change is queued or running.
  final bool busy;

  /// Shown under the Developer mode switch.
  final String? status;

  /// Shown under the SDK network select.
  final String? netStatus;

  @override
  List<Object?> get props => [net, busy, status, netStatus];
}

/// Owns the Developer mode switch and the SDK network choice. Every operation
/// runs in call order, and runs to the end even if the screen closes first.
class DeveloperSettingsCubit extends Cubit<DeveloperSettingsState> {
  DeveloperSettingsCubit({
    required Future<SgnsNet> Function() readNet,
    required Future<bool> Function(SgnsNet) writeNet,
    required Future<void> Function() leaveTestnets,
  }) : _readNet = readNet,
       _writeNet = writeNet,
       _leaveTestnets = leaveTestnets,
       super(const DeveloperSettingsState());

  final Future<SgnsNet> Function() _readNet;
  final Future<bool> Function(SgnsNet) _writeNet;
  final Future<void> Function() _leaveTestnets;

  Future<void> _queue = Future.value();
  int _pending = 0;

  Future<void> load() => _enqueue(() async {
    _emit(net: await _readNet());
  });

  Future<void> selectNet(SgnsNet net) => _enqueue(() async {
    try {
      final changed = await _writeNet(net);
      _emit(
        net: net,
        netStatus: changed
            ? 'Saved ✅ — Restart required for changes'
            : state.netStatus,
      );
    } catch (e) {
      _emit(netStatus: 'Error: $e');
    }
  });

  /// Off persists the switch, resets the SDK net to dev, then leaves EVM
  /// testnets. A failed reset turns Developer mode back on instead, so a
  /// non-default SDK net is never left behind with the switch off.
  Future<void> setDeveloperMode(bool on) => _enqueue(() async {
    try {
      await DeveloperMode.instance.setEnabled(on);
    } catch (e) {
      _emit(status: 'Error: $e');
      return;
    }
    if (on) {
      _emit(status: null);
      return;
    }
    final bool changed;
    try {
      changed = await _writeNet(SgnsNet.dev);
    } catch (e) {
      _emit(status: 'Error: $e');
      try {
        await DeveloperMode.instance.setEnabled(true);
      } catch (rollback) {
        _emit(status: 'Error: $e; could not restore Developer mode: $rollback');
      }
      return;
    }
    _emit(
      net: SgnsNet.dev,
      netStatus: null,
      status: changed
          ? 'SDK network reset to Dev net ✅ — Restart required for changes'
          : null,
    );
    try {
      await _leaveTestnets();
    } catch (e) {
      _emit(status: 'Error: $e');
    }
  });

  Future<T> _enqueue<T>(Future<T> Function() op) {
    _pending++;
    _emit();
    final result = _queue.then((_) async {
      try {
        return await op();
      } finally {
        _pending--;
        _emit();
      }
    });
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  static const _keep = Object();

  void _emit({
    SgnsNet? net,
    Object? status = _keep,
    Object? netStatus = _keep,
  }) {
    if (isClosed) {
      return;
    }
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
