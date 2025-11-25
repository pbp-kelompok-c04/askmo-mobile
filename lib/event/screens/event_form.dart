import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _biayaController = TextEditingController();
  final _kontakController = TextEditingController();
  final _thumbnailController = TextEditingController();
  String _selectedOlahraga = 'futsal';
  String _selectedLokasi = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
    _namaController.dispose();
    _deskripsiController.dispose();
    _biayaController.dispose();
    _kontakController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLokasi.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih lokasi terlebih dahulu')),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
        );
        return;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih jam terlebih dahulu')),
        );
        return;
      }

      final request = context.read<CookieRequest>();

      // opsional: cek apakah Flutter merasa sudah login
      if (!request.loggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Belum login di Flutter (CookieRequest).'),
          ),
        );
        return;
      }

      try {
        final tanggalFormatted =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
        final jamFormatted =
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

        final response = await request
            .post('http://localhost:8000/add-event-ajax/', {
              'nama': _namaController.text,
              'lokasi': _selectedLokasi,
              'tanggal': tanggalFormatted,
              'deskripsi': _deskripsiController.text,
              'biaya': _biayaController.text.isEmpty
                  ? '0'
                  : _biayaController.text,
              'kontak': _kontakController.text,
              'jam': jamFormatted,
              'olahraga': _selectedOlahraga,
              'thumbnail': _thumbnailController.text,
            });

        if (!mounted) return;

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF571E88),
              content: Text(
                'Event berhasil ditambahkan!',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFFF5555),
              content: Text(
                'Gagal menambahkan event: ${response['message'] ?? response['errors']}',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
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
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          'Tambah Event',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
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
                          controller: _namaController,
                          label: 'Nama Event',
                          hint: 'Masukkan nama event',
                        ),
                        const SizedBox(height: 16),
                        _buildLocationDropdown(),
                        const SizedBox(height: 16),
                        _buildDatePicker(),
                        const SizedBox(height: 16),
                        _buildTimePicker(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _deskripsiController,
                          label: 'Deskripsi',
                          hint: 'Masukkan deskripsi event',
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _biayaController,
                          label: 'Biaya',
                          hint: '50000',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _kontakController,
                          label: 'Kontak',
                          hint: '081234567890',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _thumbnailController,
                          label: 'URL Thumbnail (opsional)',
                          hint: 'https://example.com/image.jpg',
                          required: false,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06005E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Tambah Event',
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

  Widget _buildDropdown() {
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
            value: _selectedOlahraga,
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
                _selectedOlahraga = value!;
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
            value: _selectedLokasi.isEmpty ? '' : _selectedLokasi,
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
                  _selectedLokasi = value;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
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
          child: ListTile(
            title: Text(
              'Tanggal Event',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              _selectedDate == null
                  ? 'Pilih tanggal'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.calendar_today, color: Colors.white70),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2026),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF571E88),
                        onPrimary: Colors.white,
                        surface: Color(0xFF2A2A2A),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
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
          child: ListTile(
            title: Text(
              'Jam Event',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              _selectedTime == null
                  ? 'Pilih jam'
                  : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.access_time, color: Colors.white70),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime ?? TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF571E88),
                        onPrimary: Colors.white,
                        surface: Color(0xFF2A2A2A),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
          ),
        ),
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
}
