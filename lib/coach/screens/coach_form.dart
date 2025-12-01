import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askmo/coach/screens/coach.dart';
import 'dart:ui';

class CoachFormPage extends StatefulWidget {
  const CoachFormPage({super.key});

  @override
  State<CoachFormPage> createState() => _CoachFormPageState();
}

class _CoachFormPageState extends State<CoachFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _serviceFeeController = TextEditingController();
  final _thumbnailController = TextEditingController();

  String _selectedSportBranch = 'futsal';
  String _selectedLocation = '';

  final List<Map<String, String>> _sportOptions = [
    {'value': 'sepakbola', 'label': 'Sepak Bola'},
    {'value': 'basket', 'label': 'Basket'},
    {'value': 'voli', 'label': 'Voli'},
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'tenis', 'label': 'Tenis'},
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'padel', 'label': 'Padel'},
    {'value': 'golf', 'label': 'Golf'},
    {'value': 'lainnya', 'label': 'Lainnya'},
  ];

  final Map<String, List<String>> _locationOptions = {
    'Jakarta Pusat': [
      'Cempaka Putih',
      'Gambir',
      'Johar Baru',
      'Kemayoran',
      'Menteng',
      'Sawah Besar',
      'Senen',
      'Tanah Abang',
    ],
    'Jakarta Utara': [
      'Cilincing',
      'Kelapa Gading',
      'Koja',
      'Pademangan',
      'Penjaringan',
      'Tanjung Priok',
    ],
    'Jakarta Timur': [
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
    ],
    'Jakarta Selatan': [
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
    ],
    'Jakarta Barat': [
      'Cengkareng',
      'Grogol Petamburan',
      'Kalideres',
      'Kebon Jeruk',
      'Kembangan',
      'Palmerah',
      'Taman Sari',
      'Tambora',
    ],
    'Kepulauan Seribu': ['Kepulauan Seribu Selatan', 'Kepulauan Seribu Utara'],
    'Tangerang Kota': [
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
    ],
    'Tangerang Selatan': [
      'Ciputat',
      'Ciputat Timur',
      'Pamulang',
      'Pondok Aren',
      'Serpong',
      'Serpong Utara',
      'Setu',
    ],
    'Bekasi': [
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
    ],
    'Bogor': [
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
    ],
    'Depok': [
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
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _serviceFeeController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient - full screen
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
          // Aura circles - extended to cover full screen
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
          // Content
          Column(
            children: [
              // Custom AppBar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Tambah Coach',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nama Coach',
                          hint: 'Masukkan nama coach',
                        ),
                        const SizedBox(height: 16),
                        _buildSportDropdown(),
                        const SizedBox(height: 16),
                        _buildLocationDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _contactController,
                          label: 'Kontak (No. HP/Email)',
                          hint: '081234567890',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _experienceController,
                          label: 'Pengalaman',
                          hint: 'Masukkan pengalaman Anda',
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _certificationsController,
                          label: 'Sertifikasi',
                          hint: 'Masukkan sertifikasi Anda',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _serviceFeeController,
                          label: 'Tarif Jasa',
                          hint: 'Contoh: Rp 100.000 / Jam',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _thumbnailController,
                          label: 'URL Foto Profil (opsional)',
                          hint: 'https://example.com/photo.jpg',
                          required: false,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 12),
                        // Preview foto jika URL ada
                        if (_thumbnailController.text.isNotEmpty)
                          _buildThumbnailPreview(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedLocation.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pilih lokasi terlebih dahulu',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  // Kirim URL lengkap foto, bukan hanya nama file
                                  String photoValue = _thumbnailController.text;

                                  final requestData = <String, String>{
                                    'name': _nameController.text,
                                    'sport_branch': _selectedSportBranch,
                                    'location': _selectedLocation,
                                    'contact': _contactController.text,
                                    'experience': _experienceController.text,
                                    'certifications':
                                        _certificationsController.text,
                                    'service_fee': _serviceFeeController.text,
                                    'photo': photoValue, // Kirim URL lengkap
                                  };

                                  print(
                                    'DEBUG: Sending request data: $requestData',
                                  );

                                  final response = await request.postJson(
                                    "http://localhost:8000/coach/create-flutter/",
                                    jsonEncode(requestData),
                                  );

                                  print('DEBUG: Response: $response');

                                  if (!mounted) return;

                                  if (response['status'] == 'success') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(
                                          0xFF571E88,
                                        ),
                                        content: Text(
                                          'Coach berhasil ditambahkan!',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CoachPage(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(
                                          0xFFFF5555,
                                        ),
                                        content: Text(
                                          'Gagal menambahkan coach: ${response['message'] ?? response['errors']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFFFF5555),
                                      content: Text(
                                        'Terjadi kesalahan: $e',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06005E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Tambah Coach',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
    Function(String)? onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.3),
              ),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Field ini wajib diisi';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSportDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSportBranch,
            dropdownColor: const Color(0xFF2A2A2A),
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Cabang Olahraga',
              labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            items: _sportOptions.map((sport) {
              return DropdownMenuItem<String>(
                value: sport['value'],
                child: Text(
                  sport['label']!,
                  style: GoogleFonts.plusJakartaSans(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSportBranch = value!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem<String>(value: '', child: Text('Pilih lokasi')),
    ];

    _locationOptions.forEach((group, locations) {
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: null,
          child: Text(
            group,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA4E4FF),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
      for (var loc in locations) {
        items.add(DropdownMenuItem<String>(value: loc, child: Text(loc)));
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedLocation.isEmpty ? '' : _selectedLocation,
            dropdownColor: const Color(0xFF2A2A2A),
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Lokasi',
              labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
            items: items,
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                setState(() {
                  _selectedLocation = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih lokasi terlebih dahulu';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview Foto',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: Image.network(
                    _thumbnailController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 30,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gagal memuat',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF571E88),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
