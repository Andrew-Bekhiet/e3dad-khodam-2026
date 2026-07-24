import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

/// Root widget of the application.
class App extends StatelessWidget {
  /// Creates the root widget of the application.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(),
    );
  }
}
