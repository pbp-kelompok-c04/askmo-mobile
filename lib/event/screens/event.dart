import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/event.dart';
import '../widgets/event_card.dart';
import 'event_detail.dart';
import 'event_form.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = false;
  bool _hasError = false;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocation;
  String? _selectedSport;

  // Jakarta location options
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
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final request = context.read<CookieRequest>();
      // Endpoint Django yang benar sesuai urls.py
      final response = await request.get(
        'http://127.0.0.1:8000/get-events-json/',
      );

      if (response != null && response['events'] != null) {
        List<Event> events = [];
        for (var d in response['events']) {
          if (d != null) {
            events.add(Event.fromJson(d));
          }
        }
        setState(() {
          _events = events;
          _filteredEvents = events;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF5555),
            content: Text(
              'Gagal mengambil data event. Pastikan Django server berjalan di http://127.0.0.1:8000',
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
      _filteredEvents = _events.where((event) {
        bool matchesSearch =
            _searchController.text.isEmpty ||
            event.nama.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        bool matchesLocation =
            _selectedLocation == null ||
            event.lokasi.toLowerCase().contains(
              _selectedLocation!.toLowerCase(),
            );

        bool matchesSport =
            _selectedSport == null ||
            event.olahraga.toLowerCase() == _selectedSport!.toLowerCase();

        return matchesSearch && matchesLocation && matchesSport;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content - Full scrollable
        CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Column(
                  children: [
                    Text(
                      'EVENT',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bagikan dan temukan event olahraga di sekitarmu!',
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
            // Event List
            _buildEventList(),
          ],
        ),
        // Floating Action Button
        Positioned(
          right: 16,
          bottom: 90,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventFormPage()),
              );
              if (result == true) {
                _fetchEvents();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Tambah Event',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF571E88),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Cari nama event',
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

  Widget _buildEventList() {
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
                'Gagal memuat event',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchEvents,
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

    if (_filteredEvents.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                _events.isEmpty
                    ? 'Belum ada event tersedia'
                    : 'Tidak ada event yang sesuai',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _events.isEmpty
                    ? 'Tambahkan event pertama Anda!'
                    : 'Coba ubah filter pencarian',
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
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final event = _filteredEvents[index];
          return EventCard(
            event: event,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(event: event),
                ),
              );
            },
          );
        }, childCount: _filteredEvents.length),
      ),
    );
  }
}
