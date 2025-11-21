import 'package:flutter/material.dart';

class CoachPage extends StatelessWidget {
  const CoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach List'),
      ),
      body: const Center(
        child: Text('Halaman Coach'),
      ),
    );
  }
}