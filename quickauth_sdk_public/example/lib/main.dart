import 'package:flutter/material.dart';
import 'package:quick_auth_sdk/quick_auth_sdk.dart';

void main() {
  QuickAuthSDK.init(
    apiKey: 'client_123',
    apiBaseUrl: 'https://your-backend-domain.com',
    ipificationClientId: 'ipification_client_id',
    redirectUri: 'https://yourdomain.com/callback',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: QuickAuthExampleScreen());
  }
}

class QuickAuthExampleScreen extends StatefulWidget {
  const QuickAuthExampleScreen({super.key});

  @override
  State<QuickAuthExampleScreen> createState() => _QuickAuthExampleScreenState();
}

class _QuickAuthExampleScreenState extends State<QuickAuthExampleScreen> {
  String _status = 'Tap login to start';

  Future<void> _login() async {
    final result = await QuickAuthSDK.login('919876543210');
    setState(() {
      _status = '${result.success} - ${result.message}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuickAuth SDK Example')),
      body: Center(child: Text(_status)),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        child: const Icon(Icons.login),
      ),
    );
  }
}
