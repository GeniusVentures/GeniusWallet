import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

// Spike 003/004: webview_all_linux on WebKitGTK 4.0 (Ubuntu 20.04) and the
// getUserMedia permission path. Every event lands in an on-screen log and on
// stdout with a SPIKE prefix so runs can be grepped.

const _cameraPage = '''
<!doctype html><html><head><meta charset="utf-8"><title>gum test</title>
<style>body{font:16px sans-serif;background:#123;color:#fff;padding:12px}</style></head>
<body><h2>getUserMedia test page</h2>
<p id="ctx"></p><p id="out">idle</p>
<script>
document.getElementById('ctx').textContent =
  'isSecureContext=' + window.isSecureContext +
  ' mediaDevices=' + (navigator.mediaDevices ? 'yes' : 'NO');
function report(s){ document.getElementById('out').textContent = s; Spike.postMessage(s); }
async function runGum(kind){
  kind = kind || 'video';
  report('gum(' + kind + '): calling');
  try {
    const s = await navigator.mediaDevices.getUserMedia({[kind]: true});
    report('gum(' + kind + '): RESOLVED tracks=' + s.getTracks().map(t => t.kind + ':' + t.label).join(','));
    s.getTracks().forEach(t => t.stop());
  } catch (e) { report('gum(' + kind + '): REJECTED ' + e.name + ': ' + e.message); }
}
// Proxy probes: WebKitGTK builds without MEDIA_STREAM still route these
// through the same "permission-request" signal.
async function runNotify(){
  try { report('notify: ' + await Notification.requestPermission()); }
  catch (e) { report('notify: ' + e.name + ': ' + e.message); }
}
function runGeo(){
  navigator.geolocation.getCurrentPosition(
    p => report('geo: RESOLVED ' + p.coords.latitude),
    e => report('geo: REJECTED code=' + e.code + ' ' + e.message),
    {timeout: 8000});
}
async function listDevices(){
  try {
    const d = await navigator.mediaDevices.enumerateDevices();
    report('devices: ' + JSON.stringify(d.map(x => x.kind)));
  } catch (e) { report('devices: ' + e.name); }
}
</script></body></html>
''';

void main() => runApp(const MaterialApp(home: SpikePage()));

class LogEntry {
  LogEntry(this.category, this.message) : at = DateTime.now();
  final DateTime at;
  final String category;
  final String message;
  Map<String, String> toJson() => {
    'at': at.toIso8601String(),
    'category': category,
    'message': message,
  };
  @override
  String toString() => '${at.toIso8601String()} [$category] $message';
}

class SpikePage extends StatefulWidget {
  const SpikePage({super.key});
  @override
  State<SpikePage> createState() => _SpikePageState();
}

class _SpikePageState extends State<SpikePage> {
  final List<LogEntry> _log = [];
  late final WebViewController _controller;
  HttpServer? _server;
  bool _grant = Platform.environment['SPIKE_DENY'] != '1';
  // SPIKE_AUTO=1 runs the camera probes unattended once the local page loads,
  // exports the log and exits, so a headless container run needs no clicks.
  final bool _auto = Platform.environment['SPIKE_AUTO'] == '1';
  bool _autoStarted = false;

  Future<void> _autoRun() async {
    _autoStarted = true;
    await Future<void>.delayed(const Duration(seconds: 1));
    await _js('listDevices(); undefined');
    await Future<void>.delayed(const Duration(seconds: 2));
    await _js('runGum("video"); undefined');
    await Future<void>.delayed(const Duration(seconds: 3));
    // WSLg exposes a virtual microphone over PulseAudio, so audio is the one
    // capture kind with a real device here; it exercises the same prompt path.
    await _js('runGum("audio"); undefined');
    await Future<void>.delayed(const Duration(seconds: 5));
    await _export();
    await Future<void>.delayed(const Duration(seconds: 2));
    exit(0);
  }

  Future<void> _js(String script) async {
    try {
      await _controller.runJavaScript(script);
    } on Exception catch (e) {
      _record('error', 'runJavaScript($script): $e');
    }
  }

  void _record(String category, String message) {
    final entry = LogEntry(category, message);
    stdout.writeln('SPIKE $entry');
    if (!mounted) {
      return;
    }
    setState(() => _log.insert(0, entry));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController(
      onPermissionRequest: (WebViewPermissionRequest request) {
        final types = request.types.map((t) => t.name).join(',');
        _record('permission', 'request types=[$types] -> ${_grant ? 'GRANT' : 'DENY'}');
        if (_grant) {
          request.grant();
        } else {
          request.deny();
        }
      },
    );
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Spike',
        onMessageReceived: (m) => _record('js', m.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            final local = uri.host == '127.0.0.1' || uri.host == 'localhost';
            final allowed =
                uri.scheme == 'https' || uri.scheme == 'about' || (uri.scheme == 'http' && local);
            _record('nav', '${allowed ? 'ALLOW' : 'BLOCK'} ${request.url}');
            return allowed ? NavigationDecision.navigate : NavigationDecision.prevent;
          },
          onPageStarted: (url) => _record('page', 'started $url'),
          onPageFinished: (url) {
            _record('page', 'FINISHED $url');
            if (_auto && !_autoStarted && url.contains('127.0.0.1')) {
              _autoRun();
            }
          },
          onWebResourceError: (e) =>
              _record('error', '${e.errorCode} ${e.description} ${e.url ?? ''}'),
        ),
      );
    _startServer();
    final initial = Platform.environment['SPIKE_URL'] ?? 'https://example.com';
    _controller.loadRequest(Uri.parse(initial));
  }

  Future<void> _startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8765);
    _server = server;
    _record('server', 'serving camera page on http://127.0.0.1:8765/');
    server.listen((req) {
      req.response.headers.contentType = ContentType.html;
      req.response.write(_cameraPage);
      req.response.close();
    });
  }

  Future<void> _export() async {
    final counts = <String, int>{};
    for (final e in _log) {
      counts[e.category] = (counts[e.category] ?? 0) + 1;
    }
    final file = File(Platform.environment['SPIKE_LOG'] ?? '/tmp/spike-log.json');
    await file.writeAsString(
      const JsonEncoder.withIndent(' ').convert({
        'summary': counts,
        'events': _log.reversed.map((e) => e.toJson()).toList(),
      }),
    );
    _record('export', 'wrote ${file.path} $counts');
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <(String, VoidCallback)>[
      ('example.com', () => _controller.loadRequest(Uri.parse('https://example.com'))),
      ('cointelegraph', () => _controller.loadRequest(Uri.parse('https://cointelegraph.com'))),
      ('http (block)', () => _controller.loadRequest(Uri.parse('http://neverssl.com'))),
      ('camera page', () => _controller.loadRequest(Uri.parse('http://127.0.0.1:8765/'))),
      ('getUserMedia', () => _controller.runJavaScript('runGum(); undefined')),
      ('devices', () => _controller.runJavaScript('listDevices(); undefined')),
      ('notify', () => _controller.runJavaScript('runNotify(); undefined')),
      ('geo', () => _controller.runJavaScript('runGeo(); undefined')),
      (_grant ? 'mode: GRANT' : 'mode: DENY', () => setState(() => _grant = !_grant)),
      ('export log', _export),
    ];
    return Scaffold(
      body: Column(
        children: [
          Wrap(
            spacing: 4,
            children: [
              for (final (label, onTap) in buttons)
                OutlinedButton(onPressed: onTap, child: Text(label)),
            ],
          ),
          Expanded(
            flex: 3,
            // SPIKE_NOWEB=1 keeps the plugin loaded but never mounts the view.
            child: Platform.environment['SPIKE_NOWEB'] == '1'
                ? const Placeholder()
                : WebViewWidget(controller: _controller),
          ),
          SizedBox(
            height: 170,
            child: ListView(
              children: [
                for (final e in _log)
                  Text(e.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
