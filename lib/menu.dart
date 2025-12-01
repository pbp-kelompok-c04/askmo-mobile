import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:askmo/right_drawer.dart';
// Import UserState untuk cek login/username
import 'package:askmo/profile/models/user_state.dart';

// IMPORTS MODEL & SCREENS
import 'package:askmo/lapangan/models/lapangan.dart';
import 'package:askmo/lapangan/screens/lapangan.dart';
import 'package:askmo/lapangan/screens/lapangan_detail.dart';

import 'package:askmo/coach/models/coach_model.dart';
import 'package:askmo/coach/screens/coach.dart';
import 'package:askmo/coach/screens/coach_detail.dart';

import 'package:askmo/event/models/event.dart';
import 'package:askmo/event/screens/event.dart';
import 'package:askmo/event/screens/event_detail.dart';

/// ===============================
/// CONFIG
/// ===============================
const String lapanganEndpoint = '/json/';
const String coachEndpoint = '/coach/json/';
const String eventEndpoint = '/get-events-json/';

String _baseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  return 'http://10.0.2.2:8000';
}

/// ===============================
/// MENU PAGE (MAIN SHELL)
/// ===============================
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
    setState(() {
      _selectedIndex = index;
    });
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

/// ===============================
/// HOME CONTENT
/// ===============================
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

  List<Lapangan> _lapangan = [];
  List<Coach> _coaches = [];
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    // HERO Infinite Slide Logic
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

  // --- Search Logic Helpers ---
  List<Lapangan> get _filteredLapangan {
    if (_searchQuery.isEmpty) return _lapangan;
    return _lapangan
        .where(
          (item) =>
              item.nama.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<Coach> get _filteredCoaches {
    if (_searchQuery.isEmpty) return _coaches;
    return _coaches
        .where(
          (item) => item.fields.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  List<Event> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events
        .where(
          (item) =>
              item.nama.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pad = const EdgeInsets.symmetric(horizontal: 16);
    // Cek apakah user sedang mencari
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
            // 1. Hero Infinite Slide
            _Hero(controller: _heroCtrl),

            Padding(
              padding: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // 2. Halo, [Username]
                  Consumer<UserState>(
                    builder: (context, userState, _) {
                      final name = (userState.username.isNotEmpty)
                          ? userState.username
                          : 'Guest';
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

                  // 3. Search Engine (Search Bar)
                  _SearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                  if (_loading) const _LoadingBox(),
                  if (_error != null) _ErrorBox(message: _error!),

                  // ===== LAPANGAN (Filtered) =====
                  if (_filteredLapangan.isNotEmpty || _loading) ...[
                    _SectionHeader(
                      title: 'Cari Lapangan',
                      subtitle:
                          'Temukan lapangan terbaik untuk olahraga favoritmu.',
                    ),
                    const SizedBox(height: 10),
                    _LapanganHorizontal(
                      list: _filteredLapangan,
                      onSeeMore: () => widget.onTabChange(1),
                      isSearchMode: isSearchActive,
                    ),
                    const SizedBox(height: 22),
                  ] else if (isSearchActive) ...[
                    _NotFoundText(label: 'Lapangan'),
                    const SizedBox(height: 22),
                  ],

                  // ===== COACH (Filtered) =====
                  if (_filteredCoaches.isNotEmpty || _loading) ...[
                    _SectionHeader(
                      title: 'Temui Coach',
                      subtitle:
                          'Pilih coach yang cocok dan mulai upgrade skill.',
                    ),
                    const SizedBox(height: 10),
                    _CoachHorizontal(
                      list: _filteredCoaches,
                      onSeeMore: () => widget.onTabChange(2),
                      isSearchMode: isSearchActive,
                    ),
                    const SizedBox(height: 22),
                  ] else if (isSearchActive) ...[
                    _NotFoundText(label: 'Coach'),
                    const SizedBox(height: 22),
                  ],

                  // ===== EVENT (Filtered) =====
                  if (_filteredEvents.isNotEmpty || _loading) ...[
                    _SectionHeader(
                      title: 'Event yang Akan Datang',
                      subtitle: 'Gabung event seru dan temukan komunitas baru.',
                    ),
                    const SizedBox(height: 10),
                    _EventHorizontal(
                      list: _filteredEvents,
                      onSeeMore: () => widget.onTabChange(3),
                      isSearchMode: isSearchActive,
                    ),
                    const SizedBox(height: 40),
                  ] else if (isSearchActive) ...[
                    _NotFoundText(label: 'Event'),
                    const SizedBox(height: 40),
                  ],

                  // ===== FITUR (FLIP CARDS) =====
                  const _FeaturesSection(),
                  const SizedBox(height: 40),

                  // ===== TESTIMONIAL (GLASSMORPHISM) =====
                  const _TestimonialSection(),
                  const SizedBox(height: 40),

                  // ===== STATISTICS (ANIMATED ON SCROLL) =====
                  _StatsSection(
                    scrollController: _scrollController,
                    lapanganCount: _lapangan.length,
                    coachCount: _coaches.length,
                    eventCount: _events.length,
                  ),
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

/// ===============================
/// WIDGETS & COMPONENTS
/// ===============================

// CUSTOM SEARCH BAR WIDGET
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

// HERO SECTION (INFINITE SLIDER)
class _Hero extends StatelessWidget {
  const _Hero({required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Tinggi banner
      // PERUBAHAN: Gunakan PageView.builder untuk infinite scroll
      child: PageView.builder(
        controller: controller,
        // Tidak ada itemCount, jadi infinite
        itemBuilder: (context, index) {
          // Ambil sisa bagi 3 agar looping 0 -> 1 -> 2 -> 0 dst
          final int i = index % 3;
          // Map ke nama file: 1.png, 2.png, 3.png
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

// AURA BACKGROUND
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

// LOADING & ERROR
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

// SOLID CARD
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

// CARD FOR "SEE MORE"
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
        margin: const EdgeInsets.symmetric(vertical: 8),
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

// THUMBNAIL
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
      return s;
    }
    return 'http://10.0.2.2:8000/media/$s';
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

// ===============================
// HORIZONTAL LISTS
// ===============================

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
    // Handling list kosong
    if (list.isEmpty) return const SizedBox.shrink();

    // JIKA SEARCH MODE: Tampilkan semua list. JIKA TIDAK: Ambil 3 teratas.
    final displayList = isSearchMode ? list : list.take(3).toList();

    return SizedBox(
      height: 252,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // JIKA SEARCH MODE: count = length. JIKA TIDAK: length + 1 (buat See More)
        itemCount: isSearchMode ? displayList.length : displayList.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          // Hanya tampilkan See More jika BUKAN search mode
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LapanganDetailPage(lapangan: item),
                        ),
                      );
                    },
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
              item.fields.sportBranch,
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
              item.fields.serviceFee,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoachDetailPage(coach: item),
                        ),
                      );
                    },
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
                child: _Thumb(url: item.thumbnail, fallbackText: 'Foto'),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailPage(event: item),
                        ),
                      );
                    },
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
              Text('Projek PBP C Kelompok 04', style: p()),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================
// NEW SECTIONS: FEATURES, TESTIMONIALS, STATISTICS
// =========================================================

/// --------------------------------------------------------
/// 1. FEATURES SECTION (FLIP CARDS)
/// --------------------------------------------------------
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Keuntungan Bergabung',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Semua yang Anda butuhkan untuk pengalaman olahraga terbaik.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: Colors.white.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 24),
        // Kartu disusun vertikal (Column)
        const _FlipCard(
          frontIcon: Icons.layers_rounded,
          frontTitle: 'Satu Platform',
          backTitle: 'Satu Platform Terintegrasi',
          backDesc:
              'Semua kebutuhan olahragamu—lapangan, coach, dan event—ada di satu tempat. Tidak perlu ganti-ganti aplikasi.',
          gradientColors: [Color(0xFF571E88), Color(0xFF06005E)],
        ),
        const SizedBox(height: 16),
        const _FlipCard(
          frontIcon: Icons.map_rounded,
          frontTitle: 'Lokasi Akurat',
          backTitle: 'Navigasi Mudah',
          backDesc:
              'Tidak perlu bingung mencari lokasi. Lihat peta interaktif di setiap detail lapangan untuk navigasi yang mudah dan akurat.',
          gradientColors: [Color(0xFF6F0732), Color(0xFF571E88)],
        ),
        const SizedBox(height: 16),
        const _FlipCard(
          frontIcon: Icons.bolt_rounded,
          frontTitle: 'Kembangkan Skill',
          backTitle: 'Kembangkan Skill Anda',
          backDesc:
              'Cari coach profesional untuk meningkatkan level permainanmu. Lihat portofolio dan tarif mereka secara transparan.',
          gradientColors: [Color(0xFF06005E), Color(0xFF2E1065)],
        ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  final IconData frontIcon;
  final String frontTitle;
  final String backTitle;
  final String backDesc;
  final List<Color> gradientColors;

  const _FlipCard({
    required this.frontIcon,
    required this.frontTitle,
    required this.backTitle,
    required this.backDesc,
    required this.gradientColors,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation angle (0 to pi)
          final angle = _animation.value * 3.14159;

          // Determine which side is visible
          final isFrontVisible = angle <= 3.14159 / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // Gradient styling
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: isFrontVisible
                  ? _buildFront()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(3.14159), // Mirror back
                      child: _buildBack(),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.frontIcon, size: 48, color: const Color(0xFFA4E4FF)),
        const SizedBox(height: 16),
        Text(
          widget.frontTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '(Tap untuk membalik)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.backTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            widget.backDesc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// --------------------------------------------------------
/// 2. TESTIMONIAL SECTION (GLASS MORPHISM)
/// --------------------------------------------------------
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
      "name": "Syafiq Faqih",
      "role": "Admin ASKMO",
      "quote":
          "Kami membangun ASKMO karena lelahnya mencari info olahraga yang terpisah-pisah. Temukan lapangan bagus, coach berkualitas, dan event seru jadi semudah beberapa klik.",
    },
    {
      "name": "Ahmad Fauzan",
      "role": "Admin ASKMO",
      "quote":
          "Sebagai penggemar futsal, saya sering frustrasi mencari lapangan kosong. Dengan ASKMO, kami ingin proses pencarian dan pemesanan lapangan jadi transparan dan bebas repot.",
    },
    {
      "name": "Kamali Pirade",
      "role": "Admin ASKMO",
      "quote":
          "Pengembangan skill itu penting. Makanya, kami buat ASKMO agar semua orang bisa mudah menemukan pelatih berkualitas untuk olahraga apa pun.",
    },
    {
      "name": "Matthew Wijaya",
      "role": "Admin ASKMO",
      "quote":
          "Olahraga itu soal komunitas. Kami menciptakan ASKMO untuk jadi jembatan; tempat siapa saja bisa berbagi info event dan memudahkan orang lain untuk bergabung.",
    },
    {
      "name": "Nisrina Alya",
      "role": "Admin ASKMO",
      "quote":
          "Kami ingin ASKMO tidak hanya fungsional, tapi juga nyaman digunakan. Desainnya kami buat intuitif agar pengalamannya tetap mulus dan modern.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Menggunakan Container dengan style Glass Morphism (seperti _SolidCard)
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
          // Header (Gradient Title but refined for glass look)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              // Optional: slight gradient overlay for the header part
              gradient: LinearGradient(
                colors: [Color(0xFF06005E), Color(0xFF571E88)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              "Kenapa ASKMO?",
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
            height: 350, // Height increased for vertical layout
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
                      // 1. Profile Picture (Large & Round & Centered)
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
                          radius: 40, // Agak gede
                          backgroundColor: Colors.grey.shade700,
                          // Menggunakan logic load image seperti sebelumnya
                          foregroundImage: AssetImage(
                            'assets/image/${item['name']!.replaceAll(' ', '').toLowerCase()}.png',
                          ),
                          // Jika gagal load asset, fallback ke inisial nama
                          onForegroundImageError: (_, __) {},
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

                      // 2. Name
                      Text(
                        item['name']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),

                      // 3. Role
                      const SizedBox(height: 4),
                      Text(
                        item['role']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFA4E4FF), // Aksen warna
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // 4. Detail/Quote
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

          // Indicators / Controls
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

/// --------------------------------------------------------
/// 3. STATS SECTION (ANIMATED ON SCROLL)
/// --------------------------------------------------------
class _StatsSection extends StatefulWidget {
  final int lapanganCount;
  final int coachCount;
  final int eventCount;
  final ScrollController scrollController;

  const _StatsSection({
    required this.lapanganCount,
    required this.coachCount,
    required this.eventCount,
    required this.scrollController,
  });

  @override
  State<_StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<_StatsSection> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    final RenderObject? box = context.findRenderObject();
    if (box is! RenderBox) return;

    final position = box.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.of(context).size.height;

    final topY = position.dy;
    final bottomY = topY + box.size.height;

    final bool visible = topY < viewportHeight - 50 && bottomY > 50;

    if (visible != _isVisible) {
      setState(() {
        _isVisible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Statistik ASKMO',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // Disusun Horizontal (Row)
        Row(
          children: [
            Expanded(
              child: _StatCard(
                count: widget.lapanganCount,
                label: 'Lapangan',
                animate: _isVisible,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                count: widget.coachCount,
                label: 'Coach',
                animate: _isVisible,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                count: widget.eventCount,
                label: 'Event',
                animate: _isVisible,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final bool animate;

  const _StatCard({
    required this.count,
    required this.label,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06005E), Color(0xFF571E88)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: animate ? count : 0),
              duration: animate
                  ? const Duration(seconds: 2)
                  : const Duration(milliseconds: 0),
              curve: Curves.easeOutExpo,
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
