import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askmo/coach/models/coach_model.dart';

class CoachEditFormPage extends StatefulWidget {
  final Coach coach;

  const CoachEditFormPage({super.key, required this.coach});

  @override
  State<CoachEditFormPage> createState() => _CoachEditFormPageState();
}

class _CoachEditFormPageState extends State<CoachEditFormPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _sportBranch;
  late String _location;
  late String _contact;
  late String _experience;
  late String _certifications;
  late String _serviceFee;

  final List<String> _sportOptions = [
    'Sepak Bola',
    'Basket',
    'Voli',
    'Badminton',
    'Tenis',
    'Futsal',
    'Padel',
    'Golf',
    'Lainnya',
  ];

  final List<String> _locationOptions = [
    'Cempaka Putih',
    'Gambir',
    'Johar Baru',
    'Kemayoran',
    'Menteng',
    'Sawah Besar',
    'Senen',
    'Tanah Abang',
    'Cilincing',
    'Kelapa Gading',
    'Koja',
    'Pademangan',
    'Penjaringan',
    'Tanjung Priok',
    'Cakung',
    'Cipayung',
    'Ciracas',
    'Duren Sawit',
    'Jatinegara',
    'Kramat Jati',
    'Makasar',
    'Matraman',
    'Pasar Rebo',
    'Pulo Gadung',
    'Cilandak',
    'Jagakarsa',
    'Kebayoran Baru',
    'Kebayoran Lama',
    'Mampang Prapatan',
    'Pancoran',
    'Pasar Minggu',
    'Pesanggrahan',
    'Setiabudi',
    'Tebet',
    'Cengkareng',
    'Grogol Petamburan',
    'Taman Sari',
    'Tambora',
    'Kebon Jeruk',
    'Kalideres',
    'Palmerah',
    'Kembangan',
    'Kepulauan Seribu Utara',
    'Kepulauan Seribu Selatan',
    'Batuceper',
    'Benda',
    'Cibodas',
    'Ciledug',
    'Cipondoh',
    'Jatiuwung',
    'Karangtengah',
    'Karawaci',
    'Larangan',
    'Neglasari',
    'Periuk',
    'Pinang',
    'Tangerang',
    'Ciputat',
    'Ciputat Timur',
    'Pamulang',
    'Pondok Aren',
    'Serpong',
    'Serpong Utara',
    'Setu',
    'Bantargebang',
    'Bekasi Barat',
    'Bekasi Selatan',
    'Bekasi Timur',
    'Bekasi Utara',
    'Jatiasih',
    'Jatisampurna',
    'Medansatria',
    'Mustikajaya',
    'Pondok Gede',
    'Pondokmelati',
    'Rawalumbu',
    'Bogor Barat',
    'Bogor Selatan',
    'Bogor Tengah',
    'Bogor Timur',
    'Bogor Utara',
    'Bojonggede',
    'Caringin',
    'Ciampea',
    'Ciawi',
    'Cisarua',
    'Gunung Putri',
    'Jonggol',
    'Parung',
    'Beji',
    'Bojongsari',
    'Cilodong',
    'Cimanggis',
    'Cinere',
    'Cipayung',
    'Limo',
    'Sawangan',
    'Sukmajaya',
    'Tapos',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.coach.fields.name;
    _sportBranch = widget.coach.fields.sportBranch;
    _location = widget.coach.fields.location;
    _contact = widget.coach.fields.contact;
    _experience = widget.coach.fields.experience;
    _certifications = widget.coach.fields.certifications;
    _serviceFee = widget.coach.fields.serviceFee;

    if (!_sportOptions.any(
      (s) => s.toLowerCase() == _sportBranch.toLowerCase(),
    )) {
      _sportOptions.add(_sportBranch);
    }
    if (!_locationOptions.any(
      (l) => l.toLowerCase() == _location.toLowerCase(),
    )) {
      _locationOptions.add(_location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.black, // Dasar hitam
      appBar: AppBar(
        title: Text(
          'Edit Coach',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND AURA SAMA DENGAN COACH FORM
          // ============================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.5, -0.5),
                  radius: 1.5,
                  colors: [Color(0x99571E88), Color(0x0006005E)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF571E88).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -400,
            right: -300,
            child: Container(
              width: 1200,
              height: 1200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6F0732).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nama Coach'),
                  TextFormField(
                    initialValue: _name,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _buildInputDecoration('Nama Lengkap'),
                    onChanged: (val) => _name = val,
                    validator: (val) => val == null || val.isEmpty
                        ? "Nama tidak boleh kosong!"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Cabang Olahraga'),
                  DropdownButtonFormField<String>(
                    value: _sportOptions.firstWhere(
                      (e) => e.toLowerCase() == _sportBranch.toLowerCase(),
                      orElse: () => _sportOptions[0],
                    ),
                    dropdownColor: const Color(0xFF4F4F4F),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _buildInputDecoration('Pilih Olahraga'),
                    items: _sportOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _sportBranch = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Lokasi'),
                  DropdownButtonFormField<String>(
                    value: _locationOptions.contains(_location)
                        ? _location
                        : null,
                    dropdownColor: const Color(0xFF4F4F4F),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _buildInputDecoration('Pilih Lokasi'),
                    items: _locationOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _location = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Kontak'),
                  TextFormField(
                    initialValue: _contact,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _buildInputDecoration('08xxxxx'),
                    onChanged: (val) => _contact = val,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Tarif'),
                  TextFormField(
                    initialValue: _serviceFee,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: _buildInputDecoration('Rp...'),
                    onChanged: (val) => _serviceFee = val,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Pengalaman'),
                  TextFormField(
                    initialValue: _experience,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    maxLines: 3,
                    decoration: _buildInputDecoration('Pengalaman...'),
                    onChanged: (val) => _experience = val,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Sertifikasi'),
                  TextFormField(
                    initialValue: _certifications,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    maxLines: 2,
                    decoration: _buildInputDecoration('Sertifikasi...'),
                    onChanged: (val) => _certifications = val,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF571E88),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await request.postJson(
                            "http://127.0.0.1:8000/coach/edit-coach-flutter/${widget.coach.pk}/",
                            jsonEncode(<String, String>{
                              'name': _name,
                              'sport_branch': _sportBranch,
                              'location': _location,
                              'contact': _contact,
                              'service_fee': _serviceFee,
                              'experience': _experience,
                              'certifications': _certifications,
                            }),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF571E88),
                                  content: Text(
                                    "Coach berhasil diupdate!",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFFF5555),
                                  content: Text(
                                    response['message'] ??
                                        "Gagal mengupdate coach.",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        "Simpan Perubahan",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 14),
    ),
  );

  InputDecoration _buildInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white24),
    filled: true,
    fillColor: const Color(0xFF4F4F4F),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}
