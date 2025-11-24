import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:askmo/menu.dart';
import 'package:askmo/right_drawer.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            color: const Color(0xFFFFFFFF),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuPage()),
              );
            },
          ),
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
      endDrawer: const RightDrawer(currentIndex: -1),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundAura()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'PROFILE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),

                      _glassContainer(
                        padding: const EdgeInsets.all(20),
                        radius: 16,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 640;
                            return isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildProfileColumn(),
                                      const SizedBox(width: 20),
                                      Expanded(child: _buildRightColumn()),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildProfileColumn(),
                                      const SizedBox(height: 16),
                                      _buildRightColumn(),
                                    ],
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI pieces ---
  Widget _buildProfileColumn() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showEditProfile(),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: const Color(0xFF6C5CE7),
              child: CircleAvatar(
                radius: 66,
                backgroundImage: _avatarExists(_selectedAvatar)
                    ? AssetImage(_selectedAvatar)
                    : const AssetImage('asset/avatar/default_avatar.png')
                          as ImageProvider,
                backgroundColor: Colors.grey[900],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final uname = context.watch<UserState>().username;
              return Text(
                uname.isNotEmpty ? uname : 'username',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Olahraga favorit: ',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 24,
                height: 24,
                child: _sportIconWidget(_selectedSportKey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
                backgroundColor: const LinearGradient(
                  colors: [Color(0xFF06005E), Color(0xFF571E88)],
                ).colors.first,
              ),
              onPressed: _showEditProfile,
              child: Text('Edit Profile', style: GoogleFonts.plusJakartaSans()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    EdgeInsets? padding,
    double radius = 16.0,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildCard(
          image: 'asset/image/wishlist_placeholder_1.png',
          title: 'Wishlist - Koleksi Lapangan',
          onTap: () {
            // navigate to wishlist
          },
        ),
        const SizedBox(height: 12),
        _buildCard(
          image: 'asset/image/coach_placeholder.png',
          title: 'List - Coach',
          onTap: () {
            // navigate to coach list
          },
        ),
      ],
    );
  }

  Widget _buildCard({
    required String image,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _glassContainer(
        radius: 12,
        height: 160,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.grey[800]),
                    ),
                    Container(color: Colors.black.withOpacity(0.08)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sportIconWidget(String key) {
    // Try to load an asset icon; if missing, fallback to an Icon
    final path = 'asset/icon-olahraga/$key.png';
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) =>
          const Icon(Icons.sports, color: Colors.white, size: 20),
    );
  }

  bool _avatarExists(String path) {
    // We can't synchronously check asset existence easily; assume provided assets exist.
    return path.isNotEmpty;
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          builder: (context, ctrl) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                controller: ctrl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'EDIT PROFILE',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'Pilih Avatar',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _avatars
                          .map((a) => _buildAvatarChoice(a))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Pilih Olahraga Favorit',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _sportChoices.entries
                          .map((e) => _buildSportChoice(e.key, e.value))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil diperbarui')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          backgroundColor: const Color(0xFF571E88),
                        ),
                        child: Text(
                          'SIMPAN PERUBAHAN',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarChoice(String path) {
    final selected = _selectedAvatar == path;
    return GestureDetector(
      onTap: () => setState(() => _selectedAvatar = path),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF6C5CE7) : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0x576C5CE7).withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) =>
                Image.asset('asset/avatar/default_avatar.png'),
          ),
        ),
      ),
    );
  }

  Widget _buildSportChoice(String key, String label) {
    final selected = _selectedSportKey == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedSportKey = key),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF6C5CE7) : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Image.asset(
                'asset/icon-olahraga/$key.png',
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.sports, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
            if (selected) const Icon(Icons.check, color: Color(0xFF6C5CE7)),
          ],
        ),
      ),
    );
  }

  // --- Data / state for profile editing ---
  String _selectedAvatar = 'asset/avatar/default_avatar.png';
  String _selectedSportKey = 'lainnya';

  final List<String> _avatars = [
    'asset/avatar/default_avatar.png',
    'asset/avatar/avatar1.png',
    'asset/avatar/avatar2.png',
    'asset/avatar/avatar3.png',
  ];

  final Map<String, String> _sportChoices = {
    'sepakbola': 'Sepakbola',
    'basket': 'Basket',
    'badminton': 'Badminton',
    'tenis': 'Tenis',
    'futsal': 'Futsal',
    'voli': 'Voli',
    'padel': 'Padel',
    'golf': 'Golf',
    'lainnya': 'Lainnya',
  };
}
