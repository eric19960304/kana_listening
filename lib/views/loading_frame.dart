import 'package:flutter/material.dart';

class LoadingFrame extends StatelessWidget {
  const LoadingFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kana Listening')),
      body: const Center(child: Text('Loading...')),
    );
  }
}
