import 'package:flutter/material.dart';

class LapanganPage extends StatelessWidget {
  const LapanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lapangan'),
      ),
      body: const Center(
        child: Text('Halaman Lapangan'),
      ),
    );
  }
}