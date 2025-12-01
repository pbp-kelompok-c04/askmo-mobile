import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:askmo/profile/models/user_state.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import 'event_detail.dart';
import 'event_form.dart';
import 'event_edit_form.dart';

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
      final response = await request.get(
        'http://localhost:8000/get-events-json/',
      );

      if (response != null && response['events'] != null) {
        final List<Event> events = [];
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
              'Gagal mengambil data event. Pastikan Django server berjalan di http://localhost:8000',
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
      _filteredEvents = _events.where((event) {
        final matchesSearch =
            _searchController.text.isEmpty ||
            event.nama.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesLocation =
            trimmedLocation == null ||
            event.lokasi.toLowerCase().contains(trimmedLocation.toLowerCase());

        final matchesSport =
            _selectedSport == null ||
            event.olahraga.toLowerCase() == _selectedSport!.toLowerCase();

        return matchesSearch && matchesLocation && matchesSport;
      }).toList();
    });
  }

  Future<void> _editEvent(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventEditFormPage(event: event)),
    );
    if (result == true) {
      _fetchEvents();
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Hapus Event',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus event "${event.nama}"?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          'http://localhost:8000/delete-event-ajax/${event.id}/',
          {},
        );

        if (!context.mounted) return;

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Event berhasil dihapus',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          );
          _fetchEvents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                response['message'] ?? 'Gagal menghapus event',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Terjadi kesalahan: $e',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  bool _isOwner(UserState userState, Event event) {
    if (userState.userId == 0) return false;
    return event.userId == userState.userId;
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
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
            _buildEventList(userState),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 110,
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
    List<DropdownMenuItem<String>> locationItems = [
      const DropdownMenuItem<String>(value: null, child: Text('Semua Lokasi')),
    ];

    _locationOptions.forEach((group, locations) {
      locationItems.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: group,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              group,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA4E4FF),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
      for (var loc in locations) {
        locationItems.add(
          DropdownMenuItem<String>(
            value: loc,
            child: Text(loc, style: GoogleFonts.plusJakartaSans()),
          ),
        );
      }
    });

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
      onChanged: (value) {
        setState(() {
          _selectedSport = value;
        });
      },
    );
  }

  Widget _buildEventList(UserState userState) {
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
          final isOwner = _isOwner(userState, event);

          return EventCard(
            event: event,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(event: event),
                ),
              );

              if (result == true) {
                _fetchEvents();
              }
            },
            onEdit: isOwner ? () => _editEvent(event) : null,
            onDelete: isOwner ? () => _deleteEvent(event) : null,
          );
        }, childCount: _filteredEvents.length),
      ),
    );
  }
}
