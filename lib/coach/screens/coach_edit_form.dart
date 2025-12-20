import 'dart:convert';
import 'package:askmo/config/api_base.dart';
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
      backgroundColor: Colors.black,
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
                  _buildGlassContainer(
                    child: TextFormField(
                      initialValue: _name,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('Masukkan nama coach'),
                      onChanged: (val) => _name = val,
                      validator: (val) => val == null || val.isEmpty
                          ? "Nama tidak boleh kosong!"
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Cabang Olahraga'),
                  _buildGlassContainer(
                    child: DropdownButtonFormField<String>(
                      value: _sportOptions.firstWhere(
                        (e) => e.toLowerCase() == _sportBranch.toLowerCase(),
                        orElse: () => _sportOptions[0],
                      ),
                      dropdownColor: const Color(0xFF2A2A2A), // Warna pop-up gelap
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('Pilih Olahraga'),
                      items: _sportOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _sportBranch = val!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Lokasi'),
                  _buildGlassContainer(
                    child: DropdownButtonFormField<String>(
                      value: _locationOptions.firstWhere(
                          (e) => e.toLowerCase() == _location.toLowerCase(),
                          orElse: () => _locationOptions[0],
                        ),
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('Pilih Lokasi'),
                      items: _locationOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _location = val!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Kontak (No. HP/Email)'),
                  _buildGlassContainer(
                    child: TextFormField(
                      initialValue: _contact,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('081234567890'),
                      onChanged: (val) => _contact = val,
                      validator: (val) => val == null || val.isEmpty
                          ? "Kontak tidak boleh kosong!"
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Tarif Jasa'),
                  _buildGlassContainer(
                    child: TextFormField(
                      initialValue: _serviceFee,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('Contoh: 100000'),
                      onChanged: (val) => _serviceFee = val,
                      validator: (val) => val == null || val.isEmpty
                          ? "Tarif jasa tidak boleh kosong!"
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Pengalaman'),
                  _buildGlassContainer(
                    child: TextFormField(
                      initialValue: _experience,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('Masukkan pengalaman Anda'),
                      onChanged: (val) => _experience = val,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Sertifikasi'),
                  _buildGlassContainer(
                    child: TextFormField(
                      initialValue: _certifications,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      decoration: _buildInputDecoration('Masukkan sertifikasi Anda'),
                      onChanged: (val) => _certifications = val,
                      validator: (val) => val == null || val.isEmpty
                          ? "Sertifikasi tidak boleh kosong!"
                          : null,
                    ),
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
                            "$apiBase/coach/edit-coach-flutter/${widget.coach.pk}/",
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
    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.3)),
    filled: false,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}
