import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:convert' show base64Encode, base64Decode;
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

  // --- Data / state for profile editing (constants) ---
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

  // --- Profile Column (Menggunakan UserState) ---
  Widget _buildProfileColumn() {
    final userState = context.watch<UserState>();
    final String avatarPath = userState.avatarPath.isNotEmpty
        ? userState.avatarPath
        : 'asset/avatar/default_avatar.png';
    final String sportKey = userState.favoriteSport.isNotEmpty
        ? userState.favoriteSport
        : 'lainnya';

    ImageProvider avatarImage;
    if (avatarPath.startsWith('data:')) {
      final base64String = avatarPath.split(',').last;
      avatarImage = MemoryImage(base64Decode(base64String));
    } else {
      avatarImage = AssetImage(avatarPath);
    }

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
                // Menggunakan avatarImage yang sudah disiapkan dari UserState
                backgroundImage: avatarImage,
                backgroundColor: Colors.grey[900],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userState.displayName.isNotEmpty
                ? userState.displayName
                : userState.username,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
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
                child: _sportIconWidget(
                  sportKey,
                ), // Menggunakan sportKey dari UserState
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06005E), Color(0xFF571E88)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _showEditProfile,
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Card Content (New function for dynamic image based on type) ---
  Widget _buildCardContent(String type) {
    String imagePath;

    // Menentukan path gambar berdasarkan tipe kartu
    if (type == 'wishlist') {
      imagePath =
          'asset/image/wishlist_placeholder_1.png'; // Ganti dengan aset yang diinginkan
    } else if (type == 'coach') {
      imagePath =
          'asset/image/coach_placeholder.png'; // Ganti dengan aset yang diinginkan
    } else {
      return Container(color: Colors.grey[800]);
    }

    return Image.asset(
      imagePath,
      // Menggunakan BoxFit.cover dan Alignment.topCenter untuk tampilan seperti di foto kedua
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
    );
  }

  // --- Right Column Cards (Updated to use type and dynamic content) ---
  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildCard(
          title: 'Wishlist - Koleksi Lapangan',
          type: 'wishlist', // Mengirim tipe 'wishlist'
          onTap: () {
            // navigate to wishlist
          },
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: 'List - Coach',
          type: 'coach', // Mengirim tipe 'coach'
          onTap: () {
            // navigate to coach list
          },
        ),
      ],
    );
  }

  // --- Generic Card Widget (Updated signature) ---
  Widget _buildCard({
    required String title,
    required String type, // Menerima parameter type baru
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
                    _buildCardContent(type), // Memanggil fungsi konten dinamis
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

  // Fungsi yang tidak digunakan lagi:
  // bool _avatarExists(String path) {
  //   return path.isNotEmpty;
  // }

  void _showEditProfile() {
    final userState = context.read<UserState>();
    final initialName = userState.name;
    final initialAvatar = userState.avatarPath;
    final initialSport = userState.favoriteSport;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          builder: (context, ctrl) {
            // use local state inside the sheet
            String tempAvatar = initialAvatar;
            String tempSport = initialSport;
            Uint8List? pickedBytes;
            final TextEditingController nameController = TextEditingController(
              text: initialName.isNotEmpty ? initialName : userState.username,
            );

            return StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> pickImage() async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    pickedBytes = result.files.first.bytes;
                    if (pickedBytes != null) {
                      tempAvatar =
                          'data:image/${result.files.first.extension};base64,' +
                          base64Encode(pickedBytes!);
                      setModalState(() {});
                    }
                  }
                }

                void selectAvatarAsset(String assetPath) {
                  pickedBytes = null;
                  tempAvatar = assetPath;
                  setModalState(() {});
                }

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
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

                        // Name field
                        Text(
                          'Name',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Color(0xFF111111),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Avatar selection and upload
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Avatar',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: pickImage,
                              icon: const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Upload',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: pickedBytes != null
                              ? CircleAvatar(
                                  radius: 48,
                                  backgroundImage: MemoryImage(pickedBytes!),
                                )
                              : (tempAvatar.isNotEmpty
                                    ? (tempAvatar.startsWith('data:')
                                          ? CircleAvatar(
                                              radius: 48,
                                              backgroundImage: MemoryImage(
                                                base64Decode(
                                                  tempAvatar.split(',').last,
                                                ),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 48,
                                              backgroundImage:
                                                  AssetImage(tempAvatar)
                                                      as ImageProvider,
                                            ))
                                    : CircleAvatar(
                                        radius: 48,
                                        backgroundImage: const AssetImage(
                                          'asset/avatar/default_avatar.png',
                                        ),
                                      )),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _avatars
                              .map(
                                (a) => GestureDetector(
                                  onTap: () => selectAvatarAsset(a),
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            tempAvatar == a &&
                                                !tempAvatar.startsWith('data:')
                                            ? const Color(0xFF6C5CE7)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        a,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Image.asset(
                                          'asset/avatar/default_avatar.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Favorite Sport',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: _sportChoices.entries.map((e) {
                            final selected = tempSport == e.key;
                            return GestureDetector(
                              onTap: () =>
                                  setModalState(() => tempSport = e.key),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF6C5CE7)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: Colors.purple.withOpacity(
                                              0.08,
                                            ),
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
                                        'asset/icon-olahraga/${e.key}.png',
                                        errorBuilder: (c, ex, st) => const Icon(
                                          Icons.sports,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      const Icon(
                                        Icons.check,
                                        color: Color(0xFF6C5CE7),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF06005E), Color(0xFF571E88)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                // save changes to UserState
                                final finalName = nameController.text.trim();
                                if (finalName.isNotEmpty) {
                                  await userState.setName(finalName);
                                }
                                await userState.setFavoriteSport(tempSport);
                                if (pickedBytes != null) {
                                  final b64 = base64Encode(pickedBytes!);
                                  // Simpan sebagai base64 string dengan format URI data
                                  await userState.setAvatarPath(
                                    'data:image/png;base64,' + b64,
                                  );
                                } else if (tempAvatar.isNotEmpty) {
                                  // Simpan asset path atau base64 string yang dipilih dari koleksi
                                  await userState.setAvatarPath(tempAvatar);
                                }
                                // Tidak perlu setState() di sini, karena UserState.notifyListeners()
                                // akan memicu rebuild dari widget yang menggunakan context.watch().
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF571E88),
                                      content: Text(
                                        'Profil diperbarui',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: const StadiumBorder(),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'SIMPAN PERUBAHAN',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
}
