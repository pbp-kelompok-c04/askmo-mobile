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
  final List<Map<String, String>> _locationGroups = [
    // Jakarta Pusat
    {'group': 'Jakarta Pusat', 'value': 'Cempaka Putih'},
    {'group': 'Jakarta Pusat', 'value': 'Gambir'},
    {'group': 'Jakarta Pusat', 'value': 'Johar Baru'},
    {'group': 'Jakarta Pusat', 'value': 'Kemayoran'},
    {'group': 'Jakarta Pusat', 'value': 'Menteng'},
    {'group': 'Jakarta Pusat', 'value': 'Sawah Besar'},
    {'group': 'Jakarta Pusat', 'value': 'Senen'},
    {'group': 'Jakarta Pusat', 'value': 'Tanah Abang'},
    // Jakarta Utara
    {'group': 'Jakarta Utara', 'value': 'Cilincing'},
    {'group': 'Jakarta Utara', 'value': 'Kelapa Gading'},
    {'group': 'Jakarta Utara', 'value': 'Koja'},
    {'group': 'Jakarta Utara', 'value': 'Pademangan'},
    {'group': 'Jakarta Utara', 'value': 'Penjaringan'},
    {'group': 'Jakarta Utara', 'value': 'Tanjung Priok'},
    // Jakarta Timur
    {'group': 'Jakarta Timur', 'value': 'Cakung'},
    {'group': 'Jakarta Timur', 'value': 'Cipayung'},
    {'group': 'Jakarta Timur', 'value': 'Ciracas'},
    {'group': 'Jakarta Timur', 'value': 'Duren Sawit'},
    {'group': 'Jakarta Timur', 'value': 'Jatinegara'},
    {'group': 'Jakarta Timur', 'value': 'Kramat Jati'},
    {'group': 'Jakarta Timur', 'value': 'Makasar'},
    {'group': 'Jakarta Timur', 'value': 'Matraman'},
    {'group': 'Jakarta Timur', 'value': 'Pasar Rebo'},
    {'group': 'Jakarta Timur', 'value': 'Pulo Gadung'},
    // Jakarta Selatan
    {'group': 'Jakarta Selatan', 'value': 'Cilandak'},
    {'group': 'Jakarta Selatan', 'value': 'Jagakarsa'},
    {'group': 'Jakarta Selatan', 'value': 'Kebayoran Baru'},
    {'group': 'Jakarta Selatan', 'value': 'Kebayoran Lama'},
    {'group': 'Jakarta Selatan', 'value': 'Mampang Prapatan'},
    {'group': 'Jakarta Selatan', 'value': 'Pancoran'},
    {'group': 'Jakarta Selatan', 'value': 'Pasar Minggu'},
    {'group': 'Jakarta Selatan', 'value': 'Pesanggrahan'},
    {'group': 'Jakarta Selatan', 'value': 'Setiabudi'},
    {'group': 'Jakarta Selatan', 'value': 'Tebet'},
    // Jakarta Barat
    {'group': 'Jakarta Barat', 'value': 'Cengkareng'},
    {'group': 'Jakarta Barat', 'value': 'Grogol Petamburan'},
    {'group': 'Jakarta Barat', 'value': 'Taman Sari'},
    {'group': 'Jakarta Barat', 'value': 'Tambora'},
    {'group': 'Jakarta Barat', 'value': 'Kebon Jeruk'},
    {'group': 'Jakarta Barat', 'value': 'Kalideres'},
    {'group': 'Jakarta Barat', 'value': 'Palmerah'},
    {'group': 'Jakarta Barat', 'value': 'Kembangan'},
    // Kepulauan Seribu
    {'group': 'Kepulauan Seribu', 'value': 'Kepulauan Seribu Utara'},
    {'group': 'Kepulauan Seribu', 'value': 'Kepulauan Seribu Selatan'},
    // Tangerang Kota
    {'group': 'Tangerang Kota', 'value': 'Batuceper'},
    {'group': 'Tangerang Kota', 'value': 'Benda'},
    {'group': 'Tangerang Kota', 'value': 'Cibodas'},
    {'group': 'Tangerang Kota', 'value': 'Ciledug'},
    {'group': 'Tangerang Kota', 'value': 'Cipondoh'},
    {'group': 'Tangerang Kota', 'value': 'Jatiuwung'},
    {'group': 'Tangerang Kota', 'value': 'Karangtengah'},
    {'group': 'Tangerang Kota', 'value': 'Karawaci'},
    {'group': 'Tangerang Kota', 'value': 'Larangan'},
    {'group': 'Tangerang Kota', 'value': 'Neglasari'},
    {'group': 'Tangerang Kota', 'value': 'Periuk'},
    {'group': 'Tangerang Kota', 'value': 'Pinang'},
    {'group': 'Tangerang Kota', 'value': 'Tangerang'},
    // Tangerang Selatan
    {'group': 'Tangerang Selatan', 'value': 'Ciputat'},
    {'group': 'Tangerang Selatan', 'value': 'Ciputat Timur'},
    {'group': 'Tangerang Selatan', 'value': 'Pamulang'},
    {'group': 'Tangerang Selatan', 'value': 'Pondok Aren'},
    {'group': 'Tangerang Selatan', 'value': 'Serpong'},
    {'group': 'Tangerang Selatan', 'value': 'Serpong Utara'},
    {'group': 'Tangerang Selatan', 'value': 'Setu'},
    // Bekasi
    {'group': 'Bekasi', 'value': 'Bantargebang'},
    {'group': 'Bekasi', 'value': 'Bekasi Barat'},
    {'group': 'Bekasi', 'value': 'Bekasi Selatan'},
    {'group': 'Bekasi', 'value': 'Bekasi Timur'},
    {'group': 'Bekasi', 'value': 'Bekasi Utara'},
    {'group': 'Bekasi', 'value': 'Jatiasih'},
    {'group': 'Bekasi', 'value': 'Jatisampurna'},
    {'group': 'Bekasi', 'value': 'Medansatria'},
    {'group': 'Bekasi', 'value': 'Mustikajaya'},
    {'group': 'Bekasi', 'value': 'Pondok Gede'},
    {'group': 'Bekasi', 'value': 'Pondokmelati'},
    {'group': 'Bekasi', 'value': 'Rawalumbu'},
    // Bogor
    {'group': 'Bogor', 'value': 'Bogor Barat'},
    {'group': 'Bogor', 'value': 'Bogor Selatan'},
    {'group': 'Bogor', 'value': 'Bogor Tengah'},
    {'group': 'Bogor', 'value': 'Bogor Timur'},
    {'group': 'Bogor', 'value': 'Bogor Utara'},
    {'group': 'Bogor', 'value': 'Bojonggede'},
    {'group': 'Bogor', 'value': 'Caringin'},
    {'group': 'Bogor', 'value': 'Ciampea'},
    {'group': 'Bogor', 'value': 'Ciawi'},
    {'group': 'Bogor', 'value': 'Cisarua'},
    {'group': 'Bogor', 'value': 'Gunung Putri'},
    {'group': 'Bogor', 'value': 'Jonggol'},
    {'group': 'Bogor', 'value': 'Parung'},
    // Depok
    {'group': 'Depok', 'value': 'Beji'},
    {'group': 'Depok', 'value': 'Bojongsari'},
    {'group': 'Depok', 'value': 'Cilodong'},
    {'group': 'Depok', 'value': 'Cimanggis'},
    {'group': 'Depok', 'value': 'Cinere'},
    {'group': 'Depok', 'value': 'Cipayung'},
    {'group': 'Depok', 'value': 'Limo'},
    {'group': 'Depok', 'value': 'Sawangan'},
    {'group': 'Depok', 'value': 'Sukmajaya'},
    {'group': 'Depok', 'value': 'Tapos'},
  ];

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
      _filteredLapangan = _lapanganList.where((lapangan) {
        // 1. Filter by Name
        bool matchesSearch = _searchController.text.isEmpty ||
            lapangan.nama.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

        // 2. Filter by Location
        // Checks if alamat or kecamatan contains the selected value
        bool matchesLocation = _selectedLocation == null ||
            (lapangan.alamat != null &&
                lapangan.alamat!
                    .toLowerCase()
                    .contains(_selectedLocation!.toLowerCase())) ||
            (lapangan.kecamatan != null &&
                lapangan.kecamatan!
                    .toLowerCase()
                    .contains(_selectedLocation!.toLowerCase()));

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
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Semua Lokasi', style: GoogleFonts.plusJakartaSans()),
        ),
        ..._locationGroups.map(
          (loc) => DropdownMenuItem<String>(
            value: loc['value'],
            child: Text(loc['value']!, style: GoogleFonts.plusJakartaSans()),
          ),
        ),
      ],
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