import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

// Spike 007: one bundle, WebKitGTK loaded at runtime. Logs go on screen and to
// stdout as "SPIKE <time> [category] message" so container runs can be grepped.

const _localPage = '''
<!doctype html><html><head><meta charset="utf-8"><title>spike007 local</title>
<style>body{font:20px sans-serif;background:#1b4d3e;color:#fff;padding:16px}</style></head>
<body><h2>spike 007: rendered in-app</h2><p id="ua"></p>
<script>document.getElementById('ua').textContent = navigator.userAgent;</script>
</body></html>
''';

void main() => runApp(const MaterialApp(home: SpikePage()));

class SpikePage extends StatefulWidget {
  const SpikePage({super.key});
  @override
  State<SpikePage> createState() => _SpikePageState();
}

class _SpikePageState extends State<SpikePage> {
  final List<String> _log = [];
  WebViewController? _controller;
  bool? _available;
  HttpServer? _server;
  final String _remote = Platform.environment['SPIKE_URL'] ?? 'https://example.com/';

  void _record(String category, String message) {
    final line = '${DateTime.now().toIso8601String()} [$category] $message';
    stdout.writeln('SPIKE $line');
    if (mounted) {
      setState(() => _log.insert(0, line));
    }
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final available = await LinuxWebViewPlatform.isAvailable();
    _record('avail', 'isAvailable=$available');
    if (!available) {
      _record('fallback', 'would open $_remote in the system browser');
      setState(() => _available = false);
      return;
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8765);
    _server = server;
    server.listen((req) async {
      final body = await utf8.decoder.bind(req).join();
      req.response.headers.contentType = ContentType.html;
      // POST goes through the plugin's own libsoup request path, not WebKit's.
      req.response.write(
        req.method == 'POST'
            ? '<title>post ${req.method} ${req.headers.value('x-spike')} $body</title><h2>libsoup POST ok</h2>'
            : _localPage,
      );
      await req.response.close();
    });
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _record('page', 'started $url'),
          onPageFinished: _onFinished,
          onWebResourceError: (e) => _record('error', '${e.errorCode} ${e.description} ${e.url ?? ''}'),
        ),
      );
    setState(() {
      _available = true;
      _controller = controller;
    });
    await controller.loadRequest(Uri.parse('http://127.0.0.1:8765/'));
  }

  Future<void> _onFinished(String url) async {
    _record('page', 'FINISHED $url');
    try {
      final result = await _controller!.runJavaScriptReturningResult(
        'document.title + " | " + (6 * 7)',
      );
      _record('jseval', 'result=$result');
    } on Exception catch (e) {
      _record('jseval', 'FAILED $e');
    }
    if (url == 'http://127.0.0.1:8765/') {
      await _controller!.loadRequest(
        Uri.parse('http://127.0.0.1:8765/post'),
        method: LoadRequestMethod.post,
        headers: {'X-Spike': 'hdr1'},
        body: Uint8List.fromList(utf8.encode('a=1')),
      );
    } else if (url.contains('127.0.0.1')) {
      await _controller!.loadRequest(Uri.parse(_remote));
    }
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_available) {
      null => const Center(child: Text('checking WebKitGTK...')),
      false => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('In-app browser unavailable on this system', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _record('fallback', 'open $_remote in system browser'),
                  child: const Text('Open in system browser'),
                ),
              ],
            ),
          ),
        ),
      ),
      true => WebViewWidget(controller: _controller!),
    };
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.indigo,
            padding: const EdgeInsets.all(8),
            child: const Text('Flutter header (spike 007)', style: TextStyle(color: Colors.white)),
          ),
          Expanded(flex: 3, child: body),
          SizedBox(
            height: 150,
            child: ListView(
              children: [
                for (final line in _log)
                  Text(line, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
