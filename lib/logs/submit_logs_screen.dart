import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class SubmitLogsScreen extends StatefulWidget {
  const SubmitLogsScreen({Key? key}) : super(key: key);

  @override
  State<SubmitLogsScreen> createState() => _SubmitLogsScreenState();
}

class _SubmitLogsScreenState extends State<SubmitLogsScreen> {
  static const int _maxAttachmentBytes = 1024 * 1024; // 1 MiB per file.
  static const int _maxInlineLogChars = 8000;

  bool _isSubmitting = false;
  String _statusMessage = 'Ready to submit SDK logs.';
  String? _lastEventId;

  bool _isSuccessfulSentryId(SentryId eventId) {
    return eventId != const SentryId.empty();
  }

  Future<Uint8List> _readTailBytes(File file, int maxBytes) async {
    final totalLength = await file.length();
    if (totalLength <= maxBytes) {
      return file.readAsBytes();
    }

    final handle = await file.open();
    try {
      await handle.setPosition(totalLength - maxBytes);
      return await handle.read(maxBytes);
    } finally {
      await handle.close();
    }
  }

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
        _statusMessage =
            'Submitting ${existingLogs.length} log file(s) to Sentry...';
      });

      final fileSizesByName = <String, int>{};
      final trimmedFiles = <String, int>{};
      final logPreviewsByName = <String, String>{};
      final preparedAttachments = <SentryAttachment>[];
      const useAttachments = true;

      for (final file in existingLogs) {
        final fileName = file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : 'sdk-log.txt';
        final size = await file.length();
        fileSizesByName[fileName] = size;

        final Uint8List payloadBytes;
        if (size <= _maxAttachmentBytes) {
          payloadBytes = await file.readAsBytes();
        } else {
          payloadBytes = await _readTailBytes(file, _maxAttachmentBytes);
          trimmedFiles[fileName] = size;
        }

        final previewText = utf8.decode(payloadBytes, allowMalformed: true);
        if (previewText.length > _maxInlineLogChars) {
          logPreviewsByName[fileName] =
              previewText.substring(previewText.length - _maxInlineLogChars);
        } else {
          logPreviewsByName[fileName] = previewText;
        }

        // Skip empty files — a zero-byte attachment produces a malformed
        // envelope item header that Android's native SDK rejects.
        if (payloadBytes.isEmpty) {
          continue;
        }

        final attachmentName =
            size <= _maxAttachmentBytes ? fileName : '$fileName.tail.log';
        preparedAttachments.add(
          SentryAttachment.fromUint8List(
            payloadBytes,
            attachmentName,
            contentType: 'text/plain',
            attachmentType: SentryAttachment.typeAttachmentDefault,
          ),
        );
      }

      final eventId = await Sentry.captureMessage(
        'Manual SDK log submission',
        withScope: (scope) {
          scope.level = SentryLevel.warning;
          scope.setTag('source', 'submit_logs_screen');
          scope.setTag('platform', Platform.operatingSystem);
          scope.setContexts('sdk_logs', {
            'trimmed_files_original_size_bytes': trimmedFiles,
            'file_names': fileSizesByName.keys.toList(),
            'file_sizes_bytes': fileSizesByName,
            'inline_log_previews': logPreviewsByName,
            'attachments_enabled': useAttachments,
          });
          for (final attachment in preparedAttachments) {
            scope.addAttachment(attachment);
          }
        },
      );

      final hasSuccessfulEventId = _isSuccessfulSentryId(eventId);

      setState(() {
        _lastEventId = hasSuccessfulEventId ? eventId.toString() : null;
        if (!hasSuccessfulEventId) {
          _statusMessage =
              'Sentry did not confirm upload (empty event ID). This usually means the event was dropped or rejected before ingestion.';
          return;
        }

        _statusMessage = 'Logs submitted successfully. Event ID: $eventId';
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
                label:
                    Text(_isSubmitting ? 'Submitting...' : 'Submit SDK Logs'),
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
