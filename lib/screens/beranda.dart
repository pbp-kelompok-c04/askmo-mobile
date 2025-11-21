import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AskMo Beranda'),
      ),
      body: const Center(
        child: Text('Halaman Beranda'),
      ),
    );
  }
}