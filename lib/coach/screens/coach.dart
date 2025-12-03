import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Untuk ImageFilter
import 'package:askmo/coach/models/coach_model.dart';
import 'package:askmo/coach/screens/coach_detail.dart';
import 'package:askmo/coach/screens/coach_form.dart';
import 'package:askmo/coach/screens/coach_edit_form.dart'; // Pastikan file ini ada
import 'package:askmo/user_info.dart'; // Import UserInfo

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  List<Coach> _coachList = [];
  List<Coach> _filteredCoach = [];
  bool _isLoading = false;
  bool _hasError = false;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocation;
  String? _selectedSport;

  // Data Lokasi
  final List<Map<String, String>> _locationGroups = [
    {'group': 'Jakarta Pusat', 'value': 'Cempaka Putih'},
    {'group': 'Jakarta Pusat', 'value': 'Gambir'},
    {'group': 'Jakarta Pusat', 'value': 'Johar Baru'},
    {'group': 'Jakarta Pusat', 'value': 'Kemayoran'},
    {'group': 'Jakarta Pusat', 'value': 'Menteng'},
    {'group': 'Jakarta Pusat', 'value': 'Sawah Besar'},
    {'group': 'Jakarta Pusat', 'value': 'Senen'},
    {'group': 'Jakarta Pusat', 'value': 'Tanah Abang'},
    {'group': 'Jakarta Utara', 'value': 'Cilincing'},
    {'group': 'Jakarta Utara', 'value': 'Kelapa Gading'},
    {'group': 'Jakarta Utara', 'value': 'Koja'},
    {'group': 'Jakarta Utara', 'value': 'Pademangan'},
    {'group': 'Jakarta Utara', 'value': 'Penjaringan'},
    {'group': 'Jakarta Utara', 'value': 'Tanjung Priok'},
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
    {'group': 'Jakarta Barat', 'value': 'Cengkareng'},
    {'group': 'Jakarta Barat', 'value': 'Grogol Petamburan'},
    {'group': 'Jakarta Barat', 'value': 'Taman Sari'},
    {'group': 'Jakarta Barat', 'value': 'Tambora'},
    {'group': 'Jakarta Barat', 'value': 'Kebon Jeruk'},
    {'group': 'Jakarta Barat', 'value': 'Kalideres'},
    {'group': 'Jakarta Barat', 'value': 'Palmerah'},
    {'group': 'Jakarta Barat', 'value': 'Kembangan'},
    {'group': 'Kepulauan Seribu', 'value': 'Kepulauan Seribu Utara'},
    {'group': 'Kepulauan Seribu', 'value': 'Kepulauan Seribu Selatan'},
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
    {'group': 'Tangerang Selatan', 'value': 'Ciputat'},
    {'group': 'Tangerang Selatan', 'value': 'Ciputat Timur'},
    {'group': 'Tangerang Selatan', 'value': 'Pamulang'},
    {'group': 'Tangerang Selatan', 'value': 'Pondok Aren'},
    {'group': 'Tangerang Selatan', 'value': 'Serpong'},
    {'group': 'Tangerang Selatan', 'value': 'Serpong Utara'},
    {'group': 'Tangerang Selatan', 'value': 'Setu'},
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

  // Data Olahraga (Value = lowercase database, Label = Tampilan User)
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
    _fetchCoach();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper untuk memformat nama olahraga agar rapi (Contoh: "tenis" -> "Tenis")
  String _formatSportLabel(String rawValue) {
    // 1. Cek apakah value ada di map _sportOptions, jika ada kembalikan Label-nya
    for (var option in _sportOptions) {
      if (option['value']!.toLowerCase() == rawValue.toLowerCase()) {
        return option['label']!;
      }
    }
    // 2. Jika tidak ada di map (misal data kustom), lakukan Capitalize setiap kata
    if (rawValue.isEmpty) return rawValue;
    return rawValue
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _fetchCoach() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final request = context.read<CookieRequest>();
      // Pastikan URL ini benar dan server Django berjalan
      final response = await request.get('http://127.0.0.1:8000/coach/json/');

      if (response != null) {
        List<Coach> listData = [];
        for (var d in response) {
          if (d != null) {
            listData.add(Coach.fromJson(d));
          }
        }
        setState(() {
          _coachList = listData;
          _filteredCoach = listData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching coach: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCoach = _coachList.where((coach) {
        // Filter by Name
        bool matchesSearch =
            _searchController.text.isEmpty ||
            coach.fields.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        // Filter by Location
        bool matchesLocation =
            _selectedLocation == null ||
            coach.fields.location.toLowerCase().contains(
              _selectedLocation!.toLowerCase(),
            );

        // Filter by Sport
        bool matchesSport =
            _selectedSport == null ||
            coach.fields.sportBranch.toLowerCase() ==
                _selectedSport!.toLowerCase();

        return matchesSearch && matchesLocation && matchesSport;
      }).toList();
    });
  }

  // Fungsi Hapus Coach langsung dari Card (Icon Sampah)
  Future<void> _deleteCoachFromCard(Coach coach) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A), // Background Gelap
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Hapus Coach',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white, // Title Putih
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus "${coach.fields.name}"?',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
          ), // Content Putih/Abu terang
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
              ), // Button text putih
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFFFF5555,
              ), // Warna Merah sesuai Event Detail
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ), // Text putih
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final request = context.read<CookieRequest>();
      try {
        final response = await request.post(
          'http://127.0.0.1:8000/coach/delete-coach-ajax/${coach.pk}/',
          {},
        );
        if (context.mounted && response['status'] == 'success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
          _fetchCoach();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
        }
      }
    }
  }

  /// Build photo URL dari berbagai format
  String _buildPhotoUrl(String photoPath) {
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }
    if (photoPath.isEmpty) return '';
    return 'http://127.0.0.1:8000/media/$photoPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // Floating Action Button (Hanya Admin)
      floatingActionButton: UserInfo.isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF571E88),
                onPressed: () async {
                  // Navigasi ke form tambah coach
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoachFormPage(),
                    ),
                  );
                  // Refresh jika berhasil tambah
                  if (result == true) {
                    _fetchCoach();
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Column(
                  children: [
                    Text(
                      'COACH',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Temukan pelatih olahraga di sekitarmu!',
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

            // List of Coach
            _buildCoachList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Cari nama coach',
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
      initialValue: _selectedLocation,
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
      onChanged: (value) => setState(() => _selectedLocation = value),
    );
  }

  Widget _buildSportDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSport,
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
      onChanged: (value) => setState(() => _selectedSport = value),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildCoachList() {
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
                'Gagal memuat data coach',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchCoach,
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

    if (_filteredCoach.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                _coachList.isEmpty
                    ? 'Belum ada data coach'
                    : 'Tidak ada coach yang sesuai',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final coach = _filteredCoach[index];

          return GestureDetector(
            onTap: () async {
              // Menuju Detail Page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoachDetailPage(coach: coach),
                ),
              );
              // Jika result == true (ada perubahan), refresh list
              if (result == true) {
                _fetchCoach();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800],
                      image:
                          coach.fields.photo != null &&
                              coach.fields.photo!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                _buildPhotoUrl(coach.fields.photo!),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        coach.fields.photo == null ||
                            coach.fields.photo!.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.fields.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF571E88),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatSportLabel(coach.fields.sportBranch),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                coach.fields.location,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (UserInfo.isAdmin)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          tooltip: 'Edit Coach',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CoachEditFormPage(coach: coach),
                              ),
                            );
                            if (result == true) {
                              _fetchCoach();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Hapus Coach',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _deleteCoachFromCard(coach),
                        ),
                      ],
                    )
                  else
                    const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
          );
        }, childCount: _filteredCoach.length),
      ),
    );
  }
}
