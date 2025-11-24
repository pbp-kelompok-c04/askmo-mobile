import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoachPage extends StatelessWidget {
  const CoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Coach Page',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
