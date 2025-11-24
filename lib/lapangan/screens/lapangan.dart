import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LapanganPage extends StatelessWidget {
  const LapanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Lapangan Page',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
