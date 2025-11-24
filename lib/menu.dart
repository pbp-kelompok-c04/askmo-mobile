import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// import relatif dari lib/
import 'lapangan/screens/lapangan.dart';
import 'coach/screens/coach.dart';
import 'event/screens/event.dart';
import 'right_drawer.dart';

class MenuPage extends StatefulWidget {
  final int initialIndex;

  const MenuPage({super.key, this.initialIndex = 0});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBackgroundAura() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -150,
              left: -150,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 700,
                  height: 700,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF571E88).withOpacity(0.7),
                        const Color(0xFF06005E).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -200,
              right: -200,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 800,
                  height: 800,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6F0732).withOpacity(0.7),
                        const Color(0xFF571E88).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBeranda() {
    return Center(
      child: Text(
        'Beranda Page',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildBeranda(),
      const LapanganPage(),
      const CoachPage(),
      const EventPage(),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, size: 28),
                color: const Color(0xFFFFFFFF),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      endDrawer: RightDrawer(currentIndex: _selectedIndex),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundAura()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: IndexedStack(index: _selectedIndex, children: pages),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(top: 0),
        child: ClipRRect(
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
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sports_soccer_rounded),
                    label: 'Lapangan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Coach',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_rounded),
                    label: 'Event',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
