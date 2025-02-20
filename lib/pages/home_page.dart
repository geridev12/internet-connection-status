import 'package:flutter/material.dart';
import 'package:internet_connection_status/providers/internet_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _provider = InternetProvider();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Internet Connection'),
    ),
    body: ListenableBuilder(
      listenable: _provider,
      builder:
          (context, child) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                child!,
                const SizedBox(height: 20),
                if (_provider.hasConnection != null) ...[
                  _InternetStatusMessage(isConnected: _provider.hasConnection!),
                ],
              ],
            ),
          ),
      child: ElevatedButton(
        onPressed: () async => _provider.checkInternetConnection(),
        child: const Text('Check Internet Status'),
      ),
    ),
  );
}

class _InternetStatusMessage extends StatelessWidget {
  const _InternetStatusMessage({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) => Text(
    isConnected
        ? 'You are connected to the internet'
        : 'No internet connection. Please check your settings.',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isConnected ? Colors.green : Colors.red,
    ),
  );
}
