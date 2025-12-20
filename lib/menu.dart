import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:askmo/config/api_base.dart';
import 'package:askmo/chatbot/screens/gemini_chat_screen.dart';
import 'package:askmo/right_drawer.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:askmo/authentication/screens/login.dart';

import 'package:askmo/lapangan/models/lapangan.dart';
import 'package:askmo/lapangan/screens/lapangan.dart';
import 'package:askmo/lapangan/screens/lapangan_detail.dart';

import 'package:askmo/coach/models/coach_model.dart';
import 'package:askmo/coach/screens/coach.dart';
import 'package:askmo/coach/screens/coach_detail.dart';

import 'package:askmo/event/models/event.dart';
import 'package:askmo/event/screens/event.dart';
import 'package:askmo/event/screens/event_detail.dart';

const String lapanganEndpoint = '/json/';
const String coachEndpoint = '/coach/json/';
const String eventEndpoint = '/get-events-json/';

String _baseUrl() => apiBase;

class MenuPage extends StatefulWidget {
  final int initialIndex;
  const MenuPage({super.key, this.initialIndex = 0});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;

  late AnimationController _auraCtrl;
  late Animation<double> _auraPulse;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _auraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _auraPulse = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _auraCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _auraCtrl.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    final userState = context.read<UserState>();
    final isLoggedIn = userState.username.isNotEmpty;

    if (index == 0) {
      setState(() {
        // Beranda selalu bisa diakses
        _selectedIndex = index;
      });
    } else {
      // Lapangan, Coach, Event hanya bisa diakses kalau sudah login
      if (!isLoggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(returnToIndex: index),
          ),
        );
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  TextStyle _t(
    double size,
    FontWeight w,
    Color c, {
    double? height,
    double? ls,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: height,
      letterSpacing: ls,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeContent(onTabChange: _onItemTapped),
      const LapanganPage(),
      const CoachPage(),
      const EventPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      endDrawer: RightDrawer(currentIndex: _selectedIndex),

      appBar: AppBar(
        automaticallyImplyLeading: _selectedIndex == 0 ? false : true,
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        title: Text(
          'ASKMO',
          style: _t(18, FontWeight.w800, Colors.white, ls: 0.4),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(child: _AuraBackground(pulse: _auraPulse)),

          SafeArea(
            bottom: false,
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),

      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90.0),
              child: FloatingActionButton(
                onPressed: () {
                  final userState = context.read<UserState>();
                  if (userState.username.isEmpty) {
                    // User belum login, redirect ke login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(returnRoute: const GeminiChatScreen()),
                      ),
                    );
                  } else {
                    // User sudah login, pergi ke chatbot
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeminiChatScreen(),
                      ),
                    );
                  }
                },
                backgroundColor: const Color(0xFFA4E4FF),
                foregroundColor: Colors.black,
                elevation: 4,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFA4E4FF),
                  backgroundImage: const AssetImage(
                    'assets/image/avatar_chatbot.png',
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFFA4E4FF),
              unselectedItemColor: const Color(0xFFFFFFFF),
              selectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              iconSize: 28,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Icon(Icons.home_rounded),
                  ),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Icon(Icons.sports_soccer_rounded),
                  ),
                  label: 'Lapangan',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Icon(Icons.person_rounded),
                  ),
                  label: 'Coach',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Icon(Icons.event_rounded),
                  ),
                  label: 'Event',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Function(int) onTabChange;
  const HomeContent({super.key, required this.onTabChange});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late final PageController _heroCtrl;
  Timer? _heroTimer;

  bool _loading = true;
  String? _error;
  String _searchQuery = "";
  Set<String> _selectedSports = {};

  List<Lapangan> _lapangan = [];
  List<Coach> _coaches = [];
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _heroCtrl = PageController(initialPage: 999);
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_heroCtrl.hasClients) {
        final next = (_heroCtrl.page ?? 999).round() + 1;
        _heroCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchAll();
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroCtrl.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final request = context.read<CookieRequest>();
      final base = _baseUrl();

      final resLap = await request.get('$base$lapanganEndpoint');
      final resCoach = await request.get('$base$coachEndpoint');
      final resEvent = await request.get('$base$eventEndpoint');

      final List<Lapangan> parsedLap = [];
      if (resLap != null) {
        for (var d in resLap) {
          if (d != null) parsedLap.add(Lapangan.fromJson(d));
        }
      }

      final List<Coach> parsedCoach = [];
      if (resCoach != null) {
        for (var d in resCoach) {
          if (d != null) parsedCoach.add(Coach.fromJson(d));
        }
      }

      final List<Event> parsedEvent = [];
      if (resEvent != null && resEvent['events'] != null) {
        for (var d in resEvent['events']) {
          if (d != null) parsedEvent.add(Event.fromJson(d));
        }
      }

      if (!mounted) return;
      setState(() {
        _lapangan = parsedLap;
        _coaches = parsedCoach;
        _events = parsedEvent;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal fetch data: $e';
        _loading = false;
      });
    }
  }

  // Logika search & filter
  // Filter lapangan
  List<Lapangan> get _filteredLapangan {
    var result = _lapangan;

    // Filter cabang olahraga - support multiple selection
    if (_selectedSports.isNotEmpty) {
      result = result.where((item) {
        // Split olahraga yang bisa mengandung beberapa cabang (comma-separated)
        final itemSports = item.olahraga
            .toLowerCase()
            .split(',')
            .map((s) => s.trim())
            .toSet();

        // Check if any of selected sports matches with item's sports
        return _selectedSports.any(
          (selected) => itemSports.any(
            (itemSport) => itemSport == selected.toLowerCase(),
          ),
        );
      }).toList();
    }

    // Filter search query
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (item) =>
                item.nama.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return result;
  }

  // Filter coach
  List<Coach> get _filteredCoaches {
    var result = _coaches;

    // Filter cabang olahraga - support multiple selection
    if (_selectedSports.isNotEmpty) {
      result = result.where((item) {
        return _selectedSports.any(
          (selected) =>
              item.fields.sportBranch.toLowerCase() == selected.toLowerCase(),
        );
      }).toList();
    }

    // Filter search query
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (item) => item.fields.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    return result;
  }

  // Filter event
  List<Event> get _filteredEvents {
    var result = _events;

    // Filter cabang olahraga - support multiple selection
    if (_selectedSports.isNotEmpty) {
      result = result.where((item) {
        return _selectedSports.any(
          (selected) => item.olahraga.toLowerCase() == selected.toLowerCase(),
        );
      }).toList();
    }

    // Filter search query
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (item) =>
                item.nama.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Urutkan event berdasarkan tanggal terdekat dari hari ini
    result.sort((a, b) {
      final now = DateTime.now();
      final diffA = a.tanggal.difference(now).abs();
      final diffB = b.tanggal.difference(now).abs();
      return diffA.compareTo(diffB);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final pad = const EdgeInsets.symmetric(horizontal: 16);
    final bool isSearchActive = _searchQuery.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFFB87CFF),
      backgroundColor: const Color(0xFF121212),
      onRefresh: _fetchAll,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Slide looping
            _Hero(controller: _heroCtrl),

            Padding(
              padding: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Halo, [Username]
                  Consumer<UserState>(
                    builder: (context, userState, _) {
                      final name = (userState.username.isNotEmpty)
                          ? userState.username
                          : 'Kawan ASKMO';
                      return Text(
                        'Halo, $name',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apa yang ingin kamu cari hari ini?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search Engine (Search Bar)
                  _SearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Filter cabang olahraga
                  _SportFilter(
                    selectedSports: _selectedSports,
                    onSportSelected: (sport) {
                      setState(() {
                        if (_selectedSports.contains(sport)) {
                          _selectedSports.remove(sport);
                        } else {
                          _selectedSports.add(sport);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                  if (_loading) const _LoadingBox(),
                  if (_error != null) _ErrorBox(message: _error!),

                  // Bagian Lapangan
                  _SectionHeader(
                    title: 'Cari Lapangan',
                    subtitle:
                        'Temukan lapangan terbaik untuk olahraga favoritmu.',
                  ),
                  const SizedBox(height: 10),
                  if (_filteredLapangan.isNotEmpty)
                    _LapanganHorizontal(
                      list: _filteredLapangan,
                      onSeeMore: () => widget.onTabChange(1),
                      isSearchMode: isSearchActive,
                    )
                  else if (isSearchActive)
                    _NotFoundText(label: 'Lapangan')
                  else
                    const _EmptyData(label: 'Lapangan belum tersedia.'),
                  const SizedBox(height: 22),

                  // Bagian Coach
                  _SectionHeader(
                    title: 'Temui Coach',
                    subtitle: 'Pilih coach yang cocok dan mulai upgrade skill.',
                  ),
                  const SizedBox(height: 10),
                  if (_filteredCoaches.isNotEmpty)
                    _CoachHorizontal(
                      list: _filteredCoaches,
                      onSeeMore: () => widget.onTabChange(2),
                      isSearchMode: isSearchActive,
                    )
                  else if (isSearchActive)
                    _NotFoundText(label: 'Coach')
                  else
                    const _EmptyData(label: 'Coach belum tersedia.'),
                  const SizedBox(height: 22),

                  // Bagian Event
                  _SectionHeader(
                    title: 'Event yang Akan Datang',
                    subtitle: 'Gabung event seru dan temukan komunitas baru.',
                  ),
                  const SizedBox(height: 10),
                  if (_filteredEvents.isNotEmpty)
                    _EventHorizontal(
                      list: _filteredEvents,
                      onSeeMore: () => widget.onTabChange(3),
                      isSearchMode: isSearchActive,
                    )
                  else if (isSearchActive)
                    _NotFoundText(label: 'Event')
                  else
                    const _EmptyData(label: 'Event belum tersedia.'),
                  const SizedBox(height: 28),

                  //  Bagian Promo
                  const _PromoSlideshow(),
                  const SizedBox(height: 40),

                  //  Bagian Testimonial (Glassmorphism)
                  const _TestimonialSection(),
                  const SizedBox(height: 40),

                  _Footer(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Search Bar
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
        cursorColor: const Color(0xFFA4E4FF),
        decoration: InputDecoration(
          hintText: "Cari lapangan, coach, atau event...",
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// Filter cabang olahraga - Updated for multiple selection
class _SportFilter extends StatelessWidget {
  final Set<String> selectedSports;
  final Function(String) onSportSelected;

  const _SportFilter({
    required this.selectedSports,
    required this.onSportSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sports = [
      {'name': 'Futsal', 'icon': 'futsal.png'},
      {'name': 'Sepak Bola', 'icon': 'sepakbola.png'},
      {'name': 'Basket', 'icon': 'basket.png'},
      {'name': 'Badminton', 'icon': 'badminton.png'},
      {'name': 'Voli', 'icon': 'voli.png'},
      {'name': 'Tenis', 'icon': 'tenis.png'},
      {'name': 'Golf', 'icon': 'golf.png'},
      {'name': 'Padel', 'icon': 'padel.png'},
      {'name': 'Lainnya', 'icon': 'lainnya.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedSports.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${selectedSports.length} olahraga dipilih',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA4E4FF),
              ),
            ),
          ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sports.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              final sport = sports[index];
              final sportName = sport['name']!;
              final isSelected = selectedSports.contains(sportName);

              return GestureDetector(
                onTap: () {
                  onSportSelected(sportName);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF571E88)
                                : Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFA4E4FF)
                                  : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF571E88,
                                      ).withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/icon-olahraga/${sport['icon']}',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.sports_soccer,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFA4E4FF),
                                border: Border.all(
                                  color: const Color(0xFF571E88),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Color(0xFF571E88),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sportName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFA4E4FF)
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotFoundText extends StatelessWidget {
  final String label;
  const _NotFoundText({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Tidak ditemukan $label dengan kata kunci tersebut.',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white.withOpacity(0.4),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyData extends StatelessWidget {
  final String label;
  const _EmptyData({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white.withOpacity(0.55),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 3 foto dengan infinit slide
class _Hero extends StatelessWidget {
  const _Hero({required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          // Modulo 3 agar looping 0 -> 1 -> 2 -> 0 dst
          final int i = index % 3;
          return _HeroSlide(asset: 'assets/image/${i + 1}.png');
        },
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
      ),
    );
  }
}

// Background
class _AuraBackground extends StatelessWidget {
  const _AuraBackground({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        return Stack(
          children: [
            Positioned(
              top: -180,
              left: -180,
              child: Transform.scale(
                scale: pulse.value,
                child: _AuraBlob(
                  size: 660,
                  center: const Color(0xFF571E88).withOpacity(0.55),
                  edge: const Color(0xFF06005E).withOpacity(0.0),
                ),
              ),
            ),
            Positioned(
              bottom: -220,
              right: -220,
              child: Transform.scale(
                scale: 2.05 - pulse.value,
                child: _AuraBlob(
                  size: 820,
                  center: const Color(0xFF6F0732).withOpacity(0.45),
                  edge: const Color(0xFF571E88).withOpacity(0.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuraBlob extends StatelessWidget {
  const _AuraBlob({
    required this.size,
    required this.center,
    required this.edge,
  });
  final double size;
  final Color center;
  final Color edge;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [center, edge]),
        ),
      ),
    );
  }
}

// Loading & Error
class _LoadingBox extends StatelessWidget {
  const _LoadingBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Memuat data...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5555).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF5555).withOpacity(0.35)),
      ),
      child: Text(
        message,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.85),
          height: 1.35,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.68),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// Solid Card
class _SolidCard extends StatelessWidget {
  const _SolidCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 18,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Card "Lihat Lebih Banyak"
class _SeeMoreCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF571E88).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Lihat Lebih\nBanyak",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Thumbnail umum
class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.fallbackText});
  final String? url;
  final String fallbackText;

  String? _fixUrl(String? raw) {
    if (raw == null) return null;
    String s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) {
      if (!kIsWeb && s.contains('127.0.0.1')) {
        return s.replaceAll('127.0.0.1', '10.0.2.2');
      }
      if (!kIsWeb && s.contains('localhost')) {
        return s.replaceAll('localhost', '10.0.2.2');
      }
      return s;
    }
    final base = _baseUrl();
    return '$base/media/$s';
  }

  @override
  Widget build(BuildContext context) {
    final fixedUrl = _fixUrl(url);

    Widget fallback() => Center(
      child: Text(
        fallbackText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.55),
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (fixedUrl == null) return fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: const Color(0xFF2A2A2A),
        child: Image.network(
          fixedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback(),
        ),
      ),
    );
  }
}

// Thumbnail Event
class _EventThumb extends StatelessWidget {
  const _EventThumb({required this.url, required this.fallbackText});
  final String? url;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Center(
      child: Text(
        fallbackText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.55),
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (url == null || url!.trim().isEmpty) return fallback();

    final base = _baseUrl();
    final proxyUrl = '$base/proxy-image/?url=${Uri.encodeComponent(url!)}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: const Color(0xFF2A2A2A),
        child: Image.network(
          proxyUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback(),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF06005E), Color(0xFF571E88)],
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Horizontal Lapangan Card List
class _LapanganHorizontal extends StatelessWidget {
  const _LapanganHorizontal({
    required this.list,
    required this.onSeeMore,
    this.isSearchMode = false,
  });
  final List<Lapangan> list;
  final VoidCallback onSeeMore;
  final bool isSearchMode;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();

    final displayList = isSearchMode ? list : list.take(3).toList();

    return SizedBox(
      height: 252,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: isSearchMode ? displayList.length : displayList.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (!isSearchMode && i == displayList.length) {
            return _SeeMoreCard(onTap: onSeeMore);
          }
          return _LapanganCard(item: displayList[i]);
        },
      ),
    );
  }
}

class _LapanganCard extends StatelessWidget {
  const _LapanganCard({required this.item});
  final Lapangan item;

  void _handleTap(BuildContext context) {
    final userState = context.read<UserState>();
    if (userState.username.isEmpty) {
      Navigator.push(
        // User belum log in, redirect ke halaman login
        context,
        MaterialPageRoute(
          builder: (_) =>
              LoginPage(returnRoute: LapanganDetailPage(lapangan: item)),
        ),
      );
    } else {
      Navigator.push(
        // User sudah log in, langsung ke halaman detail
        context,
        MaterialPageRoute(builder: (_) => LapanganDetailPage(lapangan: item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 240,
      child: _SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _Thumb(url: item.thumbnail, fallbackText: 'Foto'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.alamat ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Color(0xFFFACC15),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.rating.toStringAsFixed(1)} / 5.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MiniButton(
                    label: 'Detail',
                    onTap: () => _handleTap(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Horizontal Coach Card List
class _CoachHorizontal extends StatelessWidget {
  const _CoachHorizontal({
    required this.list,
    required this.onSeeMore,
    this.isSearchMode = false,
  });
  final List<Coach> list;
  final VoidCallback onSeeMore;
  final bool isSearchMode;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();

    final displayList = isSearchMode ? list : list.take(3).toList();

    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: isSearchMode ? displayList.length : displayList.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (!isSearchMode && i == displayList.length) {
            return _SeeMoreCard(onTap: onSeeMore);
          }
          return _CoachCard(item: displayList[i]);
        },
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.item});
  final Coach item;

  void _handleTap(BuildContext context) {
    final userState = context.read<UserState>();
    if (userState.username.isEmpty) {
      Navigator.push(
        // User belum log in, redirect ke halaman login
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(returnRoute: CoachDetailPage(coach: item)),
        ),
      );
    } else {
      // User sudah log in, langsung ke halaman detail
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoachDetailPage(coach: item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 260,
      child: _SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _Thumb(url: item.fields.photo, fallbackText: 'Foto'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.fields.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.fields.sportBranch[0].toUpperCase() +
                  item.fields.sportBranch.substring(1).toLowerCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${NumberFormat.currency(
                  locale: 'id', 
                  symbol: 'Rp ', 
                  decimalDigits: 0 
                ).format(double.parse(item.fields.serviceFee))} / Sesi",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4ADE80),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MiniButton(
                    label: 'Detail',
                    onTap: () => _handleTap(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Horizontal Event Card List
class _EventHorizontal extends StatelessWidget {
  const _EventHorizontal({
    required this.list,
    required this.onSeeMore,
    this.isSearchMode = false,
  });
  final List<Event> list;
  final VoidCallback onSeeMore;
  final bool isSearchMode;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();

    final displayList = isSearchMode ? list : list.take(3).toList();

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: isSearchMode ? displayList.length : displayList.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (!isSearchMode && i == displayList.length) {
            return _SeeMoreCard(onTap: onSeeMore);
          }
          return _EventCard(item: displayList[i]);
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.item});
  final Event item;

  void _handleTap(BuildContext context) {
    final userState = context.read<UserState>();
    if (userState.username.isEmpty) {
      Navigator.push(
        // User belum log in, redirect ke halaman login
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(returnRoute: EventDetailPage(event: item)),
        ),
      );
    } else {
      // User sudah log in, langsung ke halaman detail
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailPage(event: item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}';

    return SizedBox(
      width: 200,
      height: 280,
      child: _SolidCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _EventThumb(url: item.thumbnail, fallbackText: 'Foto'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            _MiniLine(icon: Icons.calendar_month_rounded, text: dateStr),
            const SizedBox(height: 2),
            _MiniLine(icon: Icons.location_on_rounded, text: item.lokasi),
            const SizedBox(height: 2),
            _MiniLine(icon: Icons.sports_soccer_rounded, text: item.olahraga),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MiniButton(
                    label: 'Detail',
                    onTap: () => _handleTap(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ),
      ],
    );
  }
}

// Promo Slideshow (Swipe Manual)
class _PromoSlideshow extends StatefulWidget {
  const _PromoSlideshow();

  @override
  State<_PromoSlideshow> createState() => _PromoSlideshowState();
}

class _PromoSlideshowState extends State<_PromoSlideshow> {
  final PageController _ctrl = PageController();
  int _page = 0;

  final List<String> _images = const [
    'assets/image/4.png',
    'assets/image/5.png',
    'assets/image/6.png',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => Image.asset(_images[i], fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) {
            final bool active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: active ? 24 : 16,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFA4E4FF)
                    : Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle p() => GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.65),
      height: 1.45,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ASKMO',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Platform untuk mencari lapangan, coach, dan event olahraga.',
            style: p(),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.10)),
          const SizedBox(height: 10),
          Wrap(
            runSpacing: 6,
            children: [
              Text('© 2025 ASKMO Team. All Rights Reserved.', style: p()),
              Text(' Projek PBP C04', style: p()),
            ],
          ),
        ],
      ),
    );
  }
}

// Bagian Testimoni
class _TestimonialSection extends StatefulWidget {
  const _TestimonialSection();

  @override
  State<_TestimonialSection> createState() => _TestimonialSectionState();
}

class _TestimonialSectionState extends State<_TestimonialSection> {
  final PageController _pageCtrl = PageController();
  int _currIndex = 0;

  final List<Map<String, String>> _testimonials = [
    {
      "name": "Anonymous",
      "role": "User ASKMO",
      "quote":
          "Aku mulai pake ASKMO karena lelah mencari info olahraga yang terpisah-pisah. Di ASKMO gampang banget dapet lapangan bagus, coach berkualitas, dan event seru. Semua hanya dalam satu klik!",
    },
    {
      "name": "A**** F****",
      "role": "User ASKMO",
      "quote":
          "Sebagai penggemar futsal, saya sering frustrasi mencari lapangan kosong. Dengan ASKMO, proses pencarian dan pemesanan lapangan jadi transparan dan bebas repot.",
    },
    {
      "name": "K***** F****",
      "role": "User ASKMO",
      "quote":
          "Pengembangan skill itu penting. Aku pake ASKMO jadi lebih mudah menemukan pelatih berkualitas untuk olahraga apa pun.",
    },
    {
      "name": "A*** M*****",
      "role": "User ASKMO",
      "quote":
          "Di ASKMO, saya jadi gampang dapet info event olahraga. Rispek ASKMO!",
    },
    {
      "name": "Anonymous",
      "role": "User ASKMO",
      "quote":
          "ASKMO nyaman banget digunakan. Desainnya dibuat intuitif agar pengalamannya tetap mulus dan modern. Suka banget deh!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF06005E), Color(0xFF571E88)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              "Testimoni Kawan ASKMO",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Slider Content
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (idx) => setState(() => _currIndex = idx),
              itemCount: _testimonials.length,
              itemBuilder: (context, index) {
                final item = _testimonials[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Picture
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade700,
                          child: Text(
                            item['name']![0],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        item['name']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      // Role
                      const SizedBox(height: 4),
                      Text(
                        item['role']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFA4E4FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Testimoni
                      const SizedBox(height: 20),
                      Text(
                        '"${item['quote']}"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade300,
                          fontSize: 14,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Kontrol
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(_currIndex + 1).toString().padLeft(2, '0')} / ${(_testimonials.length).toString().padLeft(2, '0')}",
                  style: GoogleFonts.robotoMono(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                      ),
                      color: Colors.grey,
                      onPressed: _currIndex > 0
                          ? () => _pageCtrl.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            )
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                      ),
                      color: Colors.white,
                      onPressed: _currIndex < _testimonials.length - 1
                          ? () => _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
