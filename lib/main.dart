import 'package:flutter/material.dart';
import 'menu.dart'; // Import the menu we created in Step 2

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AskMo Mobile',
      debugShowCheckedModeBanner: false, // Removes the 'debug' banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Set the home to our MenuPage which contains the navigation bar
      home: const MenuPage(),
    );
  }
}