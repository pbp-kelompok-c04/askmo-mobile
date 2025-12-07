import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _teamMembers = [
    {
      'name': 'Syafiq Faqih',
      'role': 'Admin ASKMO',
      'image': 'assets/image/syafiqfaqih.png',
      'description':
          'Mengembangkan fitur Review dan Rating untuk lapangan dengan alur CRUD lengkap: tambah review/rating, lihat daftar dan detail, ubah review/rating, serta hapus review/rating. Membuat pengalaman penilaian lapangan jadi lebih transparan dan informatif.',
    },
    {
      'name': 'Ahmad Fauzan Al Ayubi',
      'role': 'Admin ASKMO',
      'image': 'assets/image/ahmadfauzan.png',
      'description':
          'Mengembangkan manajemen Coach dengan akses Admin saja dan CRUD lengkap: tambah coach, lihat daftar dan detail coach, ubah data coach, dan hapus coach. Sekaligus membuat flow admin yang mengatur seluruh data coach agar rapi dan aman.',
    },
    {
      'name': 'Lessyarta Kamali Sopamena Pirade',
      'role': 'Admin ASKMO',
      'image': 'assets/image/kamalipirade.png',
      'description':
          'Mengembangkan fitur Event dengan CRUD lengkap: tambah event, lihat daftar dan detail event, ubah event, dan hapus event. Juga membangun authentication (register, login, logout) serta halaman beranda.',
    },
    {
      'name': 'Matthew Wijaya',
      'role': 'Admin ASKMO',
      'image': 'assets/image/matthewwijaya.png',
      'description':
          'Mengembangkan fitur Lapangan dengan CRUD lengkap: tambah lapangan, lihat daftar dan detail lapangan, ubah informasi lapangan, dan hapus lapangan. Fokus pada kebutuhan komunitas agar info lapangan mudah dicari dan selalu up to date.',
    },
    {
      'name': 'Nisrina Alya Nabilah',
      'role': 'Admin ASKMO',
      'image': 'assets/image/nisrinaalya.jpg',
      'description':
          'Mengembangkan fitur Profile dan Wishlist dengan pengelolaan CRUD: tambah data atau item, lihat profil serta wishlist, ubah data profil dan item wishlist, dan hapus item wishlist bila tidak diperlukan. Dirancang supaya nyaman dipakai dengan UI yang modern dan intuitif.',
    },
  ];

  @override
  void initState() {
    super.initState();
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

  Widget _buildTeamMemberCard(Map<String, String> member) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF571E88), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF571E88).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    member['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                member['name']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Role
              Text(
                member['role']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFA4E4FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                member['description']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required String initial,
    required String title,
    required String name,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: 210,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Initial Avatar
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFA4E4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About ASKMO',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Aura
          Positioned.fill(child: _buildBackgroundAura()),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ASKMO',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Platform Olahraga Terlengkap',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFA4E4FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 15.0,
                              sigmaY: 15.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                'ASKMO adalah platform yang menghubungkan penggemar olahraga dengan lapangan, pelatih profesional, dan event-event seru. Kami hadir untuk memudahkan Anda menemukan semua yang dibutuhkan dalam satu aplikasi.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Team Section Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Tim Kami',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Orang-orang di balik ASKMO',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Team Members Grid
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _teamMembers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return _buildTeamMemberCard(_teamMembers[index]);
                    },
                  ),

                  const SizedBox(height: 40),

                  // Dan juga... Section
                  Center(
                    child: Text(
                      'dan juga...',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dosen and Asdos Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSupportCard(
                          initial: 'A',
                          title: 'DOSEN PBP C',
                          name: 'Ibu Arawinda Dinakaramani, S.Kom., M.Hum.',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSupportCard(
                          initial: 'F',
                          title: 'ASDOS PBP C04',
                          name: 'Farrell Zidane Raihandrawan',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '© 2025 ASKMO Team',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Proyek PBP C - Kelompok 04',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
