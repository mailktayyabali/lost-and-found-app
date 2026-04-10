import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost and Found'),
      ),
      body: const Center(
        child: Text('Welcome to Lost and Found App! Feature modules will go here.'),
      ),
    );
  }
}
