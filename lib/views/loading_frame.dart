import 'package:flutter/material.dart';

class LoadingFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kana Listening'),
      ),
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
