import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// ---------------------------------------------------------------------------
// Flutter-free helpers (top-level so the pure runnable check can import them
// without pumping a widget — mirrors the test/markets_sort_test.dart idiom).
// ---------------------------------------------------------------------------

/// The guided feedback kind. Guidance is honest: [tag] becomes a filterable
/// `feedback_type` dimension in Sentry, [placeholder] frames the message field,
/// [label] names the segment.
enum FeedbackType {
  bug,
  idea,
  question;

  /// The Sentry tag value — a fixed enum, never free text (T-19-03).
  String get tag {
    switch (this) {
      case FeedbackType.bug:
        return 'bug';
      case FeedbackType.idea:
        return 'idea';
      case FeedbackType.question:
        return 'question';
    }
  }

  /// Segment label in the chooser.
  String get label {
    switch (this) {
      case FeedbackType.bug:
        return 'Bug';
      case FeedbackType.idea:
        return 'Idea';
      case FeedbackType.question:
        return 'Question';
    }
  }

  /// Message-field hint that adapts to the chosen kind.
  String get placeholder {
    switch (this) {
      case FeedbackType.bug:
        return 'Describe what broke and the steps to reproduce it.';
      case FeedbackType.idea:
        return "Describe what you'd like to see and why it would help.";
      case FeedbackType.question:
        return 'Ask what you need help with and what you have already tried.';
    }
  }
}

/// What happens to a candidate log when the report is built.
enum AttachmentDisposition { whole, tail, skipEmpty }

/// Single source of truth for how each log is handled — used by BOTH the send
/// path and the Ready-state receipt chips, so the chips can never disagree with
/// what actually ships. `payloadLength == 0` is skipped first (a zero-byte
/// attachment produces a malformed envelope Android's native SDK rejects,
/// M-01); otherwise the whole file rides along when it fits, else the last
/// `maxBytes` are tail-trimmed.
AttachmentDisposition attachmentDispositionFor({
  required int size,
  required int maxBytes,
  required int payloadLength,
}) {
  if (payloadLength == 0) return AttachmentDisposition.skipEmpty;
  return size <= maxBytes
      ? AttachmentDisposition.whole
      : AttachmentDisposition.tail;
}

/// The attachment filename for a disposition: original name when sent whole,
/// `<name>.tail.log` when tail-trimmed.
String attachmentNameFor(String fileName, AttachmentDisposition disposition) {
  return disposition == AttachmentDisposition.tail
      ? '$fileName.tail.log'
      : fileName;
}

/// The two candidate SDK logs, in order. Kept as a const so the send path and
/// the receipt probe list the exact same files.
const List<String> _candidateLogNames = ['sgnslog.log', 'sgnslog2.log'];

class SubmitLogsScreen extends StatefulWidget {
  const SubmitLogsScreen({super.key});

  @override
  State<SubmitLogsScreen> createState() => _SubmitLogsScreenState();
}

/// A Ready-state probe of one candidate log — what the receipt chip shows and
/// what the send path will do, derived from the same disposition helper.
class _AttachmentProbe {
  const _AttachmentProbe(this.fileName, this.size, this.disposition);
  final String fileName;
  final int size;
  final AttachmentDisposition disposition;
}

class _SubmitLogsScreenState extends State<SubmitLogsScreen> {
  static const int _maxAttachmentBytes = 1024 * 1024; // 1 MiB per file.

  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _statusIsError = false;
  String _statusMessage = 'Ready to send feedback.';
  String? _lastEventId;
  FeedbackType _selectedType = FeedbackType.bug;

  /// Null while probing; a (possibly empty) list once the disk read completes.
  List<_AttachmentProbe>? _probes;

  @override
  void initState() {
    super.initState();
    _probeAttachments();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  bool _isSuccessfulSentryId(SentryId eventId) {
    return eventId != const SentryId.empty();
  }

  String _normalizedBasePath(String basePath) {
    return basePath.endsWith(Platform.pathSeparator) || basePath.endsWith('/')
        ? basePath
        : '$basePath${Platform.pathSeparator}';
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

  /// Reads the candidate logs' sizes and asks [attachmentDispositionFor] what
  /// would ship — so the receipt row is an honest preview of the send path. No
  /// file picker; the user never selects files.
  Future<void> _probeAttachments() async {
    final geniusApi = context.read<GeniusApi>();
    if (!geniusApi.isSdkInitialized) {
      if (mounted) setState(() => _probes = const []);
      return;
    }

    final base = _normalizedBasePath(geniusApi.jsonFilePath);
    final probes = <_AttachmentProbe>[];
    for (final name in _candidateLogNames) {
      final file = File('$base$name');
      if (!await file.exists()) continue;
      final size = await file.length();
      // The probe only knows the size, so it approximates the payload length:
      // 0 stays 0 (skipEmpty), a whole file is its size, a tail is maxBytes.
      // ponytail: a file that is non-empty on disk but reads back empty is a
      // race we don't preview; the send path re-reads and skips it for real.
      final payloadLength =
          size == 0 ? 0 : (size <= _maxAttachmentBytes ? size : _maxAttachmentBytes);
      probes.add(
        _AttachmentProbe(
          name,
          size,
          attachmentDispositionFor(
            size: size,
            maxBytes: _maxAttachmentBytes,
            payloadLength: payloadLength,
          ),
        ),
      );
    }

    if (mounted) setState(() => _probes = probes);
  }

  void _resetToReady() {
    setState(() {
      _feedbackController.clear();
      _lastEventId = null;
      _isSubmitting = false;
      _statusIsError = false;
      _statusMessage = 'Ready to send feedback.';
      _probes = null;
    });
    _probeAttachments();
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied reference number.')));
  }

  Future<void> _submitFeedback() async {
    final geniusApi = context.read<GeniusApi>();
    final feedbackMessage = _feedbackController.text.trim();

    if (feedbackMessage.isEmpty) {
      setState(() {
        _statusIsError = false;
        _statusMessage = 'Please type a short feedback message before sending.';
      });
      return;
    }

    if (!geniusApi.isSdkInitialized) {
      setState(() {
        _statusIsError = false;
        _statusMessage =
            'SDK is not initialized yet. Start the SDK first, then send feedback.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusIsError = false;
      _lastEventId = null;
      _statusMessage = 'Preparing feedback payload...';
    });

    final normalizedBasePath = _normalizedBasePath(geniusApi.jsonFilePath);

    final candidateLogs =
        _candidateLogNames.map((name) => File('$normalizedBasePath$name'));

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

        final Uint8List payloadBytes = size <= _maxAttachmentBytes
            ? await file.readAsBytes()
            : await _readTailBytes(file, _maxAttachmentBytes);

        // Route through the shared disposition helper so the send path and the
        // receipt chips (Ready state) can never disagree.
        final disposition = attachmentDispositionFor(
          size: size,
          maxBytes: _maxAttachmentBytes,
          payloadLength: payloadBytes.length,
        );

        if (disposition == AttachmentDisposition.tail) {
          trimmedFiles[fileName] = size;
        }

        // Skip empty files — a zero-byte attachment produces a malformed
        // envelope item header that Android's native SDK rejects (M-01).
        if (disposition == AttachmentDisposition.skipEmpty) {
          skippedEmptyFiles.add(fileName);
          continue;
        }

        preparedAttachments.add(
          SentryAttachment.fromUint8List(
            payloadBytes,
            attachmentNameFor(fileName, disposition),
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
          scope.setTag('feedback_type', _selectedType.tag);
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
          // Distinct, more-specific failure: the upload was not confirmed.
          _statusIsError = true;
          _statusMessage =
              'Sentry did not confirm feedback upload (empty event ID). This usually means the payload was dropped or rejected before ingestion.';
          return;
        }

        _statusIsError = false;
        final skippedText = skippedEmptyFiles.isEmpty
            ? ''
            : ' Skipped empty logs: ${skippedEmptyFiles.join(', ')}.';
        _statusMessage = 'Feedback sent.$skippedText';
      });
    } catch (e) {
      setState(() {
        // Distinct failure: an exception was thrown before/within capture.
        _statusIsError = true;
        _statusMessage = 'Failed to send feedback: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency so this subtree
    // rebuilds on a live appearance toggle (matches the other tab screens).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final sdkReady = context.read<GeniusApi>().isSdkInitialized;
    final isSuccess = _lastEventId != null;

    return Scaffold(
      // No AppBar: this is a shell tab (/logs), so the shared navbar is the top
      // chrome, exactly as on Transactions/Markets/News/Swap. The title is a
      // left-aligned in-body GWPageHeader, not a Material app-bar title.
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          // topCenter + space32 top: the navbar→title gap, unified with the
          // other tabs (transactions_screen.dart). Scroll so the card never
          // clips on a short window or with the keyboard up.
          padding: const EdgeInsets.fromLTRB(
            16,
            GeniusWalletConsts.space32,
            16,
            16,
          ),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: GeniusBreakpoints.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const GWPageHeader(title: 'Send Feedback'),
                GWCard(
                  padding: const EdgeInsets.all(GeniusWalletConsts.space12),
                  child: isSuccess
                      ? _buildSuccess(gw)
                      : _buildComposer(gw, sdkReady),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Ready / Sending / No-SDK / Failed composer --------------------------

  Widget _buildComposer(GWColors gw, bool sdkReady) {
    final canSend = sdkReady && !_isSubmitting;

    final Color statusColor;
    final String statusText;
    if (_isSubmitting) {
      statusColor = gw.textSecondary;
      statusText = _statusMessage;
    } else if (!sdkReady) {
      statusColor = gw.textSecondary;
      statusText =
          'Start the SDK first - feedback needs it running to attach logs and send.';
    } else {
      statusColor = _statusIsError ? gw.statusError : gw.textSecondary;
      statusText = _statusMessage;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTypeChooser(gw),
        const SizedBox(height: GeniusWalletConsts.space12),
        Text(
          'Describe what\'s happening in as much detail as you can - the more specific, the faster we can help.',
          style: GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        TextField(
          controller: _feedbackController,
          minLines: 4,
          maxLines: 8,
          maxLength: 2000,
          enabled: !_isSubmitting,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            labelText: 'Message',
            hintText: _selectedType.placeholder,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        _buildReceipt(gw, sdkReady),
        const SizedBox(height: GeniusWalletConsts.space12),
        Divider(color: gw.borderSubtle, height: 1),
        const SizedBox(height: GeniusWalletConsts.space12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                statusText,
                style: GeniusWalletTypography.bodySm.copyWith(color: statusColor),
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space8),
            GWButton(
              label: 'Send feedback',
              leading: const Icon(Icons.send),
              isLoading: _isSubmitting,
              onPressed: canSend ? _submitFeedback : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChooser(GWColors gw) {
    return Container(
      padding: const EdgeInsets.all(GeniusWalletConsts.space2),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: Border.all(color: gw.borderSubtle),
      ),
      child: Row(
        children: [
          for (final type in FeedbackType.values)
            Expanded(child: _buildTypeSegment(gw, type)),
        ],
      ),
    );
  }

  Widget _buildTypeSegment(GWColors gw, FeedbackType type) {
    final active = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
          onTap: _isSubmitting
              ? null
              : () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(
              vertical: GeniusWalletConsts.space4,
            ),
            decoration: BoxDecoration(
              // Mint-tinted active fill + border; label stays on the primary
              // text ladder so the pairing holds AA in both themes.
              color: active
                  ? GeniusWalletColors.brandSecondaryMuted
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
              border: Border.all(
                color: active
                    ? GeniusWalletColors.brandSecondary
                    : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              type.label,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: active ? gw.textPrimary : gw.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceipt(GWColors gw, bool sdkReady) {
    final probes = _probes;

    final List<Widget> chips = [];
    if (!sdkReady) {
      chips.add(_metaChip(
        gw,
        'Attachments unavailable - SDK stopped',
        dotColor: gw.textSecondary,
      ));
    } else if (probes == null) {
      chips.add(_metaChip(gw, 'Checking for logs...', dotColor: gw.textSecondary));
    } else {
      final attachable = probes
          .where((p) => p.disposition != AttachmentDisposition.skipEmpty)
          .toList();
      if (attachable.isEmpty) {
        chips.add(_metaChip(gw, 'No logs found yet', dotColor: gw.textSecondary));
      }
      for (final probe in probes) {
        chips.add(_logChip(gw, probe));
      }
    }

    // Neutral meta chips: SDK status + platform.
    chips.add(_metaChip(
      gw,
      sdkReady ? 'SDK Running' : 'SDK Stopped',
      dotColor: sdkReady ? gw.statusSuccess : gw.textSecondary,
    ));
    chips.add(_metaChip(gw, Platform.operatingSystem));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SDK logs attached automatically',
          style: GeniusWalletTypography.labelMd.copyWith(color: gw.textPrimary),
        ),
        const SizedBox(height: GeniusWalletConsts.space2),
        Text(
          'last 1 MB of each, empty ones skipped',
          style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        Wrap(
          spacing: GeniusWalletConsts.space4,
          runSpacing: GeniusWalletConsts.space4,
          children: chips,
        ),
      ],
    );
  }

  Widget _logChip(GWColors gw, _AttachmentProbe probe) {
    final skipped = probe.disposition == AttachmentDisposition.skipEmpty;
    final tail = probe.disposition == AttachmentDisposition.tail;
    final label = '${probe.fileName}  ${_friendlySize(probe.size)}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space3,
      ),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        border: Border.all(color: gw.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skipped ? '${probe.fileName}  skipped (empty)' : label,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: skipped ? gw.textSecondary : gw.textPrimary,
              decoration: skipped ? TextDecoration.lineThrough : null,
            ),
          ),
          if (tail) ...[
            const SizedBox(width: GeniusWalletConsts.space3),
            _tailBadge(gw),
          ],
        ],
      ),
    );
  }

  Widget _tailBadge(GWColors gw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: GeniusWalletColors.brandSecondaryMuted,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusXs),
      ),
      child: Text(
        'TAIL',
        style: GeniusWalletTypography.bodySm.copyWith(
          color: gw.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _metaChip(GWColors gw, String label, {Color? dotColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space3,
      ),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        border: Border.all(color: gw.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: GeniusWalletConsts.space3),
          ],
          Text(
            label,
            style:
                GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
          ),
        ],
      ),
    );
  }

  // --- Success -------------------------------------------------------------

  Widget _buildSuccess(GWColors gw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                // brandSecondaryMuted is a runtime withAlpha value, so the
                // decoration cannot be const.
                color: GeniusWalletColors.brandSecondaryMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: GeniusWalletColors.brandSecondaryStrong,
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space8),
            Expanded(
              child: Text(
                'Feedback sent',
                style: GeniusWalletTypography.headlineMd
                    .copyWith(color: gw.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        Text(
          'Thanks for your feedback - every bit helps us make GeniusWallet better.',
          style: GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        Text(
          'Reference number',
          style: GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary),
        ),
        const SizedBox(height: GeniusWalletConsts.space3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(GeniusWalletConsts.space6),
          decoration: BoxDecoration(
            color: gw.surfaceSunken,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
            border: Border.all(color: gw.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _lastEventId ?? '',
                  style: GeniusWalletTypography.bodyMd
                      .copyWith(color: gw.textPrimary),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              GWButton(
                variant: GWButtonVariant.tertiary,
                size: GWButtonSize.sm,
                label: 'Copy',
                leading: const Icon(Icons.copy),
                onPressed: _copyEventId,
              ),
            ],
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space3),
        Text(
          'Keep it handy in case you follow up with support.',
          style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        GWButton(
          variant: GWButtonVariant.gradientOutline,
          label: 'Send another',
          leading: const Icon(Icons.refresh),
          onPressed: _resetToReady,
        ),
      ],
    );
  }

  String _friendlySize(int bytes) {
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    }
    if (bytes >= kb) {
      return '${(bytes / kb).round()} KB';
    }
    return '$bytes B';
  }
}
