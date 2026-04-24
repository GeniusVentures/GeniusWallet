import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

class SubmitLogsScreen extends StatefulWidget {
  const SubmitLogsScreen({Key? key}) : super(key: key);

  @override
  State<SubmitLogsScreen> createState() => _SubmitLogsScreenState();
}

class _SubmitLogsScreenState extends State<SubmitLogsScreen> {
  static const int _maxAttachmentBytes = 1024 * 1024; // 1 MiB per file.

  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String _statusMessage = 'Ready to send feedback.';
  String? _lastEventId;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

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

  Future<void> _submitFeedback() async {
    final geniusApi = context.read<GeniusApi>();
    final feedbackMessage = _feedbackController.text.trim();

    if (feedbackMessage.isEmpty) {
      setState(() {
        _statusMessage = 'Please type a short feedback message before sending.';
      });
      return;
    }

    if (!geniusApi.isSdkInitialized) {
      setState(() {
        _statusMessage =
            'SDK is not initialized yet. Start the SDK first, then send feedback.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _lastEventId = null;
      _statusMessage = 'Preparing feedback payload...';
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

    try {
      setState(() {
        _statusMessage = existingLogs.isEmpty
            ? 'Sending feedback without SDK log attachments...'
            : 'Sending feedback with ${existingLogs.length} log attachment(s)...';
      });

      final fileSizesByName = <String, int>{};
      final trimmedFiles = <String, int>{};
      final skippedEmptyFiles = <String>[];
      final preparedAttachments = <SentryAttachment>[];

      for (final file in existingLogs) {
        final fileName = file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : 'sdk-log.txt';
        final size = await file.length();
        fileSizesByName[fileName] = size;

        Uint8List payloadBytes;
        if (size <= _maxAttachmentBytes) {
          payloadBytes = await file.readAsBytes();
        } else {
          payloadBytes = await _readTailBytes(file, _maxAttachmentBytes);
          trimmedFiles[fileName] = size;
        }

        // Skip empty files — a zero-byte attachment produces a malformed
        // envelope item header that Android's native SDK rejects.
        if (payloadBytes.isEmpty) {
          skippedEmptyFiles.add(fileName);
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

      final eventId = await Sentry.captureFeedback(
        SentryFeedback(message: feedbackMessage),
        withScope: (scope) {
          scope.level = SentryLevel.warning;
          scope.setTag('source', 'submit_feedback_screen');
          scope.setTag('platform', Platform.operatingSystem);
          scope.setContexts('feedback', {
            'message_length': feedbackMessage.length,
          });
          scope.setContexts('sdk_logs', {
            'base_path': normalizedBasePath,
            'trimmed_files_original_size_bytes': trimmedFiles,
            'file_names': fileSizesByName.keys.toList(),
            'file_sizes_bytes': fileSizesByName,
            'attached_file_names': preparedAttachments
                .map((attachment) => attachment.filename)
                .toList(),
            'skipped_empty_files': skippedEmptyFiles,
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
              'Sentry did not confirm feedback upload (empty event ID). This usually means the payload was dropped or rejected before ingestion.';
          return;
        }

        final skippedText = skippedEmptyFiles.isEmpty
            ? ''
            : ' Skipped empty logs: ${skippedEmptyFiles.join(', ')}.';
        _statusMessage =
            'Feedback sent successfully. Event ID: $eventId.$skippedText';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to send feedback: $e';
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
        title: const Text('Send Feedback'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.feedback_outlined,
                size: 64,
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Send feedback to the team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Type your message below. SDK logs are attached automatically when available.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _feedbackController,
                minLines: 4,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'What happened? What were you trying to do?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label:
                    Text(_isSubmitting ? 'Sending...' : 'Send Feedback'),
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
