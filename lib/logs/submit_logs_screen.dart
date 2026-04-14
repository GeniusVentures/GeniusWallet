import 'package:flutter/material.dart';

class SubmitLogsScreen extends StatelessWidget {
  const SubmitLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Logs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bug_report, size: 64, color: Colors.greenAccent),
            SizedBox(height: 24),
            Text(
              'Submit logs from GeniusSDK',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This screen will allow you to send logs to Sentry.io.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
