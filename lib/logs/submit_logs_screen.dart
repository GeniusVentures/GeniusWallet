import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:io';

class SubmitLogsScreen extends StatefulWidget {
  const SubmitLogsScreen({Key? key}) : super(key: key);

  @override
  State<SubmitLogsScreen> createState() => _SubmitLogsScreenState();
}

class _SubmitLogsScreenState extends State<SubmitLogsScreen> {
  bool _isSubmitting = false;
  String _statusMessage = 'Ready to submit SDK logs.';
  String? _lastEventId;

  Future<void> _copyEventId() async {
    final eventId = _lastEventId;
    if (eventId == null || eventId.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: eventId));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied Sentry event ID.')),
    );
  }

  Future<void> _submitSdkLogs() async {
    final geniusApi = context.read<GeniusApi>();

    if (!geniusApi.isSdkInitialized) {
      setState(() {
        _statusMessage =
            'SDK is not initialized yet. Start the SDK first, then submit logs.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _lastEventId = null;
      _statusMessage = 'Locating log files...';
    });

    final basePath = geniusApi.jsonFilePath;
    final normalizedBasePath =
        basePath.endsWith(Platform.pathSeparator) || basePath.endsWith('/')
            ? basePath
            : '$basePath${Platform.pathSeparator}';

    final candidateLogs = [
      File('${normalizedBasePath}sgnslog.log'),
      File('${normalizedBasePath}sgnslog2.log'),
    ];

    final existingLogs = <File>[];
    for (final file in candidateLogs) {
      if (await file.exists()) {
        existingLogs.add(file);
      }
    }

    if (existingLogs.isEmpty) {
      setState(() {
        _isSubmitting = false;
        _statusMessage =
            'No SDK log files found in $normalizedBasePath (expected sgnslog.log / sgnslog2.log).';
      });
      return;
    }

    try {
      setState(() {
        _statusMessage = 'Submitting ${existingLogs.length} log file(s) to Sentry...';
      });

      final eventId = await Sentry.captureMessage(
        'Manual SDK log submission',
        withScope: (scope) {
          scope.level = SentryLevel.info;
          scope.setTag('source', 'submit_logs_screen');
          scope.setContexts('sdk_logs', {
            'base_path': normalizedBasePath,
            'files': existingLogs.map((file) => file.path).toList(),
          });
          for (final file in existingLogs) {
            final fileName = file.uri.pathSegments.isNotEmpty
                ? file.uri.pathSegments.last
                : 'sdk-log.txt';
            scope.addAttachment(
              SentryAttachment.fromLoader(
                loader: file.readAsBytes,
                filename: fileName,
                contentType: 'text/plain',
              ),
            );
          }
        },
      );

      setState(() {
        _lastEventId = eventId.toString().isNotEmpty ? eventId.toString() : null;
        _statusMessage = eventId.toString().isNotEmpty
            ? 'Logs submitted successfully. Event ID: $eventId'
            : 'Logs submitted, but no Event ID was returned.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to submit logs: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Logs'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bug_report, size: 64, color: Colors.greenAccent),
              const SizedBox(height: 24),
              const Text(
                'Submit logs from GeniusSDK',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Uploads sgnslog.log and sgnslog2.log from the SDK base path to Sentry.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitSdkLogs,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit SDK Logs'),
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
              ),
              if (_lastEventId != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _copyEventId,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Event ID'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
