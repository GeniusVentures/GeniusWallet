import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
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
  if (payloadLength == 0) {
    return AttachmentDisposition.skipEmpty;
  }
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
  const SubmitLogsScreen({super.key, this.initialMessage});

  /// Pre-fills the message field, e.g. from the job flow's `Get help`
  /// button on its `bridgedNotProcessed` terminal (`14-09-PLAN.md` Task
  /// 3c). Null for every other entry point (nav bar, direct navigation) -
  /// this is a courtesy, not a requirement; every existing behaviour below,
  /// including the empty-message guard in `_submitFeedback`, is unaffected
  /// and simply gets satisfied by the prefill when present.
  final String? initialMessage;

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

  // 153-B "Focused frame". The composer keeps `small`; the rail's floor and
  // the two-column threshold are DERIVED from it, so the breakpoint cannot
  // drift away from the widths it is about. The sketch's "1040" is a mockup
  // number — `large` (1024) is a real token and 640 + 20 + 360 fits inside it.
  static const double _composerWidth = GeniusBreakpoints.small;
  static const double _railMinWidth = 360;
  static const double _twoColumnMin =
      _composerWidth + GeniusWalletConsts.space10 + _railMinWidth;

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
    if (widget.initialMessage != null) {
      _feedbackController.text = widget.initialMessage!;
    }
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
      if (mounted) {
        setState(() => _probes = const []);
      }
      return;
    }

    final base = _normalizedBasePath(geniusApi.jsonFilePath);
    final probes = <_AttachmentProbe>[];
    for (final name in _candidateLogNames) {
      final file = File('$base$name');
      if (!await file.exists()) {
        continue;
      }
      final size = await file.length();
      // The probe only knows the size, so it approximates the payload length:
      // 0 stays 0 (skipEmpty), a whole file is its size, a tail is maxBytes.
      // ponytail: a file that is non-empty on disk but reads back empty is a
      // race we don't preview; the send path re-reads and skips it for real.
      final payloadLength = size == 0
          ? 0
          : (size <= _maxAttachmentBytes ? size : _maxAttachmentBytes);
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

    if (mounted) {
      setState(() => _probes = probes);
    }
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

    final candidateLogs = _candidateLogNames.map(
      (name) => File('$normalizedBasePath$name'),
    );

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
      // page-frame GWPageHeader (left edge, same X as the other tabs), not a
      // Material app-bar title.
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          // topCenter + the shared gap/gutter (`GeniusBreakpoints`), so the
          // title lands at the same X as the other tabs. Scroll so the card
          // never clips on a short window or with the keyboard up.
          padding: EdgeInsets.fromLTRB(
            GeniusBreakpoints.pageGutter(context),
            GeniusBreakpoints.pageTitleGap(context),
            GeniusBreakpoints.pageGutter(context),
            8,
          ),
          child: ConstrainedBox(
            // `large`, not `xxl` (D-01). A 560 column inside a 1536 frame left
            // ~430px of dead page on each side, and the title had been pushed
            // inside that column to hide the mismatch. 153-B narrows the FRAME
            // instead of the content, so the leftover reads as margin.
            constraints: const BoxConstraints(
              maxWidth: GeniusBreakpoints.large,
            ),
            child: Column(
              // stretch: the header takes the full capped width instead of
              // shrink-wrapping and getting centred (transactions_screen.dart
              // does the same).
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // D-02: the title is a direct child of the frame's
                // Column(stretch) — no Center, no second ConstrainedBox
                // between them — so it lands on the frame's left edge like
                // every other tab. `centered` stays on GWPageHeader (it is
                // additive and tested); only this call site stops passing it.
                const GWPageHeader(
                  title: 'Send Feedback',
                  subtitle:
                      'Bug reports, ideas and questions go straight to the team.',
                ),
                // D-03. LayoutBuilder sits INSIDE the ConstrainedBox, so
                // `constraints.maxWidth` is the frame's CONTENT width, not the
                // window's — measuring the window here would put the page in
                // two columns while the content was still narrow.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final composer = GWCard(
                      padding: const EdgeInsets.all(GeniusWalletConsts.space12),
                      child: isSuccess
                          ? _buildSuccess(gw)
                          : _buildComposer(gw, sdkReady),
                    );
                    final rail = GWCard(
                      padding: const EdgeInsets.all(GeniusWalletConsts.space12),
                      child: _buildRail(gw, sdkReady),
                    );

                    if (constraints.maxWidth >= _twoColumnMin) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: _composerWidth, child: composer),
                          const SizedBox(width: GeniusWalletConsts.space10),
                          Expanded(child: rail),
                        ],
                      );
                    }
                    // The rail is mounted in BOTH branches. Mounting it only
                    // in the wide one would make it vanish on a narrow window
                    // — the facts it carries are not a wide-screen luxury.
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        composer,
                        const SizedBox(height: GeniusWalletConsts.space10),
                        rail,
                      ],
                    );
                  },
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
        // space16, not space12: the chooser lost its box, so the only thing
        // separating it from the description below is air. At 24 the two read
        // as one block; the tabs need to finish before the copy starts.
        const SizedBox(height: GeniusWalletConsts.space16),
        Text(
          'Describe what\'s happening in as much detail as you can - the more specific, the faster we can help.',
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        // The label sits ABOVE the field, not floating on its border. That is
        // this app's own standard — `GWTextField` renders it exactly this way
        // (labelMd / textSecondary, space4 below) and Settings, the Markets
        // search, the account manager and onboarding all inherit it. This
        // screen used a raw `TextField(labelText:)`, which picks up
        // `theme.dart`'s `floatingLabelBehavior: always` and notches the label
        // into the outline — the one place in the app that reads that way.
        Text(
          'Message',
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        // Same focus behaviour as the Swap amount field: quiet at rest, brand
        // gradient on focus. `GWFocusRing` keeps its 1.5px in BOTH states, so
        // clicking into the message never nudges the card.
        GWFocusRing(
          radius: GeniusWalletConsts.radiusLg,
          background: gw.surfaceMenu,
          enabled: !_isSubmitting,
          child: TextField(
            controller: _feedbackController,
            minLines: 4,
            maxLines: 8,
            maxLength: 2000,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: _selectedType.placeholder,
              // Without an explicit style the hint inherits near-body colour
              // and reads as text the user already typed. Muted AND italic:
              // either alone still looked like content in the walk.
              hintStyle: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textPrimary38,
                fontStyle: FontStyle.italic,
              ),
              // All four silenced — the ring is the border now, and the
              // theme's app-wide focusedBorder would paint a second, flat one
              // inside it.
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space6,
                vertical: GeniusWalletConsts.space6,
              ),
            ),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        Divider(color: gw.borderSubtle, height: 1),
        const SizedBox(height: GeniusWalletConsts.space12),
        // D-06. The status line and the button used to share one Row with
        // `center` alignment. The empty-event-ID failure message is 130
        // characters and wraps to several lines in a 640 column, which parked
        // the button in the MIDDLE of that block — it read as belonging to the
        // second line of an error rather than to the form.
        //
        // Stacked, the arrangement is unconditional: the button is below the
        // status in every state, so the one-line states look the same as they
        // did and the multi-line ones stop breaking.
        Text(
          statusText,
          style: GeniusWalletTypography.bodySm.copyWith(color: statusColor),
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        Align(
          alignment: Alignment.centerRight,
          child: GWButton(
            label: 'Send feedback',
            leading: const Icon(Icons.send),
            isLoading: _isSubmitting,
            onPressed: canSend ? _submitFeedback : null,
          ),
        ),
      ],
    );
  }

  /// Sketch 064-B: the nav bar's active-tab language, brought down to a
  /// segmented control. The track loses its box — a filled, bordered pill
  /// around tabs that already mark themselves is a second frame saying the
  /// same thing — and keeps only the hairline the underline sits on.
  Widget _buildTypeChooser(GWColors gw) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: gw.borderSubtle, width: 1)),
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

    // Hover state per segment, in a StatefulBuilder — the same shape
    // responsive_overlay.dart uses for the nav tabs, so the two controls do
    // not drift apart.
    //
    // ponytail: this state lives in the builder, so a rebuild of the screen
    // drops a mid-hover highlight. Rare and harmless; the nav tabs carry the
    // identical caveat. Upgrade path is a shared hoverable wrapper.
    bool hovered = false;
    return StatefulBuilder(
      builder: (context, setHover) {
        final lifted = hovered && !active;
        // WHITE on active OR hover, muted otherwise. The gradient is the
        // underline ONLY — it never touches the label (nav-tab rule).
        final labelColor = (active || lifted)
            ? gw.textPrimary
            : gw.textSecondary;

        return InkWell(
          onTap: _isSubmitting
              ? null
              : () => setState(() => _selectedType = type),
          onHover: (h) => setHover(() => hovered = h),
          // The tab paints its own hover; Material's splash would be a second,
          // disagreeing one on top of it.
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            // THE app-wide hover recipe (sketch 044 variant 3): brand tint +
            // brand hairline, no geometry. Read from GWDecorations so this
            // control cannot drift from the nav bar.
            // The border is present in BOTH states, transparent when idle.
            // A BoxDecoration with a border INSETS its child by the border
            // width, so animating from "no border" to "1px border" shifts the
            // label a pixel down and right on every hover — small, constant,
            // and exactly the twitch a hover must not have.
            decoration: BoxDecoration(
              color: lifted ? GWDecorations.hoverFill : null,
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.borderRadiusCard,
              ),
              border: Border.all(
                color: lifted ? GWDecorations.hoverEdge : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // width: infinity is load-bearing. A Stack gives its
                // non-positioned children LOOSE constraints, so the Text was
                // shrink-wrapping and `textAlign: center` had no box to centre
                // within — every label sat flush left inside its third.
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: GeniusWalletConsts.space6,
                    ),
                    child: Text(
                      type.label,
                      textAlign: TextAlign.center,
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: labelColor,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // 3px gradient bar, rounded top, soft brandPrimaryStrong glow
                // — the nav bar's exact underline (002-B), down to the 200ms.
                // A BoxDecoration cannot set both color and gradient, so each
                // state uses exactly one.
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: active ? GeniusWalletGradient.brandCta : null,
                      color: active ? null : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: context.gw.brandPrimaryStrong.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// D-04: the receipt rail. Every line is a fact `_probes` already computes —
  /// no new data, no new network call, no new shared component.
  ///
  /// `_candidateLogNames` is a two-element const, so this is four rows on a
  /// good day and two with the SDK stopped. It is sized for that and given no
  /// growth affordance: a list that can never be long does not need one.
  Widget _buildRail(GWColors gw, bool sdkReady) {
    final probes = _probes;
    final rows = <Widget>[];

    if (!sdkReady) {
      // Says WHY there are no log rows rather than showing an empty space the
      // user has to interpret.
      rows.add(_railRow(gw, 'Logs', 'Unavailable - SDK stopped'));
    } else if (probes == null) {
      rows.add(_railRow(gw, 'Logs', 'Checking...'));
    } else if (probes.isEmpty) {
      rows.add(_railRow(gw, 'Logs', 'None found yet'));
    } else {
      for (final probe in probes) {
        final skipped = probe.disposition == AttachmentDisposition.skipEmpty;
        rows.add(
          _railRow(
            gw,
            probe.fileName,
            skipped ? 'skipped (empty)' : _friendlySize(probe.size),
            strike: skipped,
            tail: probe.disposition == AttachmentDisposition.tail,
          ),
        );
      }
    }

    rows.add(
      _railRow(
        gw,
        'SDK',
        sdkReady ? 'Running' : 'Stopped',
        valueColor: sdkReady ? gw.statusSuccess : null,
      ),
    );
    rows.add(_railRow(gw, 'Platform', Platform.operatingSystem));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          // "What gets sent" read like a customs form and, more importantly,
          // never said the thing the user cannot know: that they do not have
          // to do anything. This recovers the sense of the deleted
          // "SDK logs attached automatically" header without the word "SDK",
          // which means nothing to someone reporting a bug.
          'Attached automatically',
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        ...rows,
        const SizedBox(height: GeniusWalletConsts.space6),
        Text(
          'last 1 MB of each, empty ones skipped',
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textSecondary,
          ),
        ),
      ],
    );
  }

  /// One key/value line of the rail. [strike] marks a file that will NOT be
  /// attached — struck through rather than hidden, because "we looked and it
  /// was empty" is different from "we did not look".
  Widget _railRow(
    GWColors gw,
    String label,
    String value, {
    bool strike = false,
    bool tail = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
                decoration: strike ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space4),
          if (tail) ...[_tailBadge(gw), const SizedBox(width: 6)],
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: valueColor ?? gw.textPrimary,
                decoration: strike ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tailBadge(GWColors gw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: context.gw.brandSecondaryMuted,
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
                color: context.gw.brandSecondaryMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: gw.brandSecondaryStrong),
            ),
            const SizedBox(width: GeniusWalletConsts.space8),
            Expanded(
              child: Text(
                'Feedback sent',
                style: GeniusWalletTypography.headlineMd.copyWith(
                  color: gw.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        Text(
          'Thanks for your feedback - every bit helps us make GeniusWallet better.',
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        Text(
          'Reference number',
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textSecondary,
          ),
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
                  style: GeniusWalletTypography.bodyMd.copyWith(
                    color: gw.textPrimary,
                  ),
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
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textSecondary,
          ),
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
