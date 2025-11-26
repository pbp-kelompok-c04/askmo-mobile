import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askmo/coach/screens/coach.dart';

class CoachFormPage extends StatefulWidget {
  const CoachFormPage({super.key});

  @override
  State<CoachFormPage> createState() => _CoachFormPageState();
}

class _CoachFormPageState extends State<CoachFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = "";
  String _sportBranch = "";
  String _location = "";
  String _contact = "";
  String _experience = "";
  String _certifications = "";
  String _serviceFee = "";

  // Opsi yang sama dengan filter agar konsisten
  final List<String> _sportOptions = [
    "Sepak Bola", "Basket", "Voli", "Badminton", 
    "Tenis", "Futsal", "Padel", "Golf", "Lainnya"
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.black, // Background hitam sesuai tema
      appBar: AppBar(
        title: Text(
          'Tambah Coach', 
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Nama Coach", (value) => _name = value),
              const SizedBox(height: 16),
              
              // Dropdown untuk Cabang Olahraga
              Text("Cabang Olahraga", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1A1A1A),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
                items: _sportOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _sportBranch = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Pilih cabang olahraga!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField("Lokasi (Kota/Daerah)", (value) => _location = value),
              const SizedBox(height: 16),
              _buildTextField("Kontak (No. HP/Email)", (value) => _contact = value),
              const SizedBox(height: 16),
              _buildTextField("Pengalaman", (value) => _experience = value, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField("Sertifikasi", (value) => _certifications = value, maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField("Tarif Jasa (Contoh: Rp 100.000 / Jam)", (value) => _serviceFee = value),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF571E88),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Kirim data ke Django
                      final response = await request.postJson(
                        "http://127.0.0.1:8000/coach/create-flutter/", // Sesuaikan URL
                        jsonEncode(<String, String>{
                          'name': _name,
                          'sport_branch': _sportBranch,
                          'location': _location,
                          'contact': _contact,
                          'experience': _experience,
                          'certifications': _certifications,
                          'service_fee': _serviceFee,
                        }),
                      );
                      
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Coach berhasil ditambahkan!")),
                          );
                          // Kembali ke halaman list dan refresh
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CoachPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gagal menambahkan coach, silakan coba lagi.")),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    "Simpan",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF571E88)),
            ),
          ),
          onChanged: onChanged,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "$label tidak boleh kosong!";
            }
            return null;
          },
        ),
      ],
    );
  }
}