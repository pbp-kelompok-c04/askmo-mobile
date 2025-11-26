// lib/screens/lapangan_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/lapangan.dart';
import '../widgets/lapangan_card.dart';
import 'lapangan_detail.dart';

class LapanganPage extends StatefulWidget {
  const LapanganPage({super.key});

  @override
  State<LapanganPage> createState() => _LapanganPageState();
}

class _LapanganPageState extends State<LapanganPage> {
  List<Lapangan> _lapanganList = [];
  List<Lapangan> _filteredLapangan = [];
  bool _isLoading = false;
  bool _hasError = false;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocation;
  String? _selectedSport;

  // Full location list from your reference
  // Grouped location options for filter
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
    'Kepulauan Seribu': [
      'Kepulauan Seribu Selatan',
      'Kepulauan Seribu Utara',
    ],
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

  @override
  void initState() {
    super.initState();
    _fetchLapangan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLapangan() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final request = context.read<CookieRequest>();
      // IMPORTANT: Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web/iOS
      // Check your Django endpoint name in main/urls.py (assumed 'show_json' mapped to /json/)
      final response = await request.get(
        'http://127.0.0.1:8000/json/',
      );

      // The /json/ endpoint returns a List<dynamic> directly
      if (response != null) {
        List<Lapangan> listData = [];
        for (var d in response) {
          if (d != null) {
            listData.add(Lapangan.fromJson(d));
          }
        }
        setState(() {
          _lapanganList = listData;
          _filteredLapangan = listData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching lapangan: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF5555),
            content: Text(
              'Gagal mengambil data lapangan. Pastikan server berjalan.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
  setState(() {
    String? trimmedLocation = _selectedLocation?.trim();

    _filteredLapangan = _lapanganList.where((lapangan) {
      // 1. Filter by Name
      bool matchesSearch = _searchController.text.isEmpty ||
          lapangan.nama.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              );

      // 2. Filter by Location (alamat atau kecamatan mengandung lokasi)
      bool matchesLocation =
          trimmedLocation == null ||
          (lapangan.alamat != null &&
              lapangan.alamat!
                  .toLowerCase()
                  .contains(trimmedLocation.toLowerCase())) ||
          (lapangan.kecamatan != null &&
              lapangan.kecamatan!
                  .toLowerCase()
                  .contains(trimmedLocation.toLowerCase()));

      // 3. Filter by Sport
      bool matchesSport = _selectedSport == null ||
          lapangan.olahraga.toLowerCase() == _selectedSport!.toLowerCase();

      return matchesSearch && matchesLocation && matchesSport;
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 25),
                child: Column(
                  children: [
                    Text(
                      'LAPANGAN',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Temukan lapangan olahraga terbaik di sekitarmu!',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Search & Filter Box
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSearchField(),
                          const SizedBox(height: 12),
                          _buildLocationDropdown(),
                          const SizedBox(height: 12),
                          _buildSportDropdown(),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06005E),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Cari',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // List of Lapangan
            _buildLapanganList(),
          ],
        ),
      ],
    ),
  );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Cari nama lapangan',
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF4F4F4F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    List<DropdownMenuItem<String>> locationItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          'Semua Lokasi',
          style: GoogleFonts.plusJakartaSans(),
        ),
      ),
    ];

    _locationOptions.forEach((group, locations) {
      // Header grup (tidak bisa dipilih)
      locationItems.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: group,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              group,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA4E4FF), // biru terang custom
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );

      // Item lokasi di dalam grup
      for (var loc in locations) {
        locationItems.add(
          DropdownMenuItem<String>(
            value: loc,
            child: Text(
              loc,
              style: GoogleFonts.plusJakartaSans(),
            ),
          ),
        );
      }
    });

    return DropdownButtonFormField<String>(
      value: _selectedLocation,
      dropdownColor: const Color(0xFF4F4F4F),
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Pilih lokasi',
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
        prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF4F4F4F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      items: locationItems,
      onChanged: (value) {
        setState(() {
          _selectedLocation = value;
        });
      },
    );
  }


  Widget _buildSportDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSport,
      dropdownColor: const Color(0xFF4F4F4F),
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Pilih cabang olahraga',
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
        prefixIcon: const Icon(Icons.sports_soccer, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF4F4F4F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Semua Olahraga', style: GoogleFonts.plusJakartaSans()),
        ),
        ..._sportOptions.map(
          (sport) => DropdownMenuItem<String>(
            value: sport['value'],
            child: Text(sport['label']!, style: GoogleFonts.plusJakartaSans()),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSport = value;
        });
      },
    );
  }

  Widget _buildLapanganList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF571E88)),
        ),
      );
    }

    if (_hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data lapangan',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchLapangan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF571E88),
                ),
                child: Text('Coba Lagi', style: GoogleFonts.plusJakartaSans()),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredLapangan.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stadium, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                _lapanganList.isEmpty
                    ? 'Belum ada data lapangan'
                    : 'Tidak ada lapangan yang sesuai',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba ubah filter pencarian',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      // CHANGE THIS: Use 'sliver' instead of 'slivers'
      sliver: SliverList( 
        delegate: SliverChildBuilderDelegate((context, index) {
          final lapangan = _filteredLapangan[index];
          return LapanganCard(
            lapangan: lapangan,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LapanganDetailPage(lapangan: lapangan),
                ),
              );
            },
          );
        }, childCount: _filteredLapangan.length),
      ),
    );
  }
}