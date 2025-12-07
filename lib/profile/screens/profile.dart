import 'package:askmo/history/models/booking_history_state.dart';
import 'package:askmo/user_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:askmo/wishlist/models/wishlist_state.dart';
import 'package:askmo/lapangan/screens/lapangan_detail.dart';
import 'package:askmo/lapangan/models/lapangan.dart';
import 'package:askmo/lapangan/widgets/lapangan_card.dart';
import 'package:askmo/lapangan/screens/lapangan_booking.dart';
import 'package:askmo/coach/screens/coach_detail.dart'; 
import 'package:askmo/coach/models/coach_model.dart';
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

  String _selectedTab = 'wishlist';

  final List<String> _avatars = [
    'assets/avatar/default_avatar.png',
    'assets/avatar/avatar1.png',
    'assets/avatar/avatar2.png',
    'assets/avatar/avatar3.png',
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

  Future<void> _showUnwishlistDialog(
    BuildContext context,
    WishedItem item,
    WishlistState wishlistState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Hapus dari Wishlist',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${item.name} dari Wishlist?',
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
      await wishlistState.removeWish(item.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF5555),
          content: Text(
            '${item.name} berhasil dihapus dari Wishlist.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
        ),
      );
    }
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
    double opacity = 0.03,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProfileColumn() {
    final userState = context.watch<UserState>();
    final String avatarPath = userState.avatarPath.isNotEmpty
        ? userState.avatarPath
        : 'assets/avatar/default_avatar.png';
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

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showEditProfile(),
          child: CircleAvatar(
            radius: 70,
            backgroundColor: const Color(0xFF6C5CE7),
            child: CircleAvatar(
              radius: 66,
              backgroundImage: avatarImage,
              backgroundColor: Colors.grey[900],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          userState.displayName.isNotEmpty
              ? userState.displayName
              : UserInfo.username,
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
            SizedBox(width: 24, height: 24, child: _sportIconWidget(sportKey)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 300, 
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
    );
  }

  Widget _buildCustomIcon(String assetName) {
    final bool isSelected = _selectedTab == 'wishlist';
    final Color color = isSelected ? Colors.white : Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: Image.asset(
          'assets/image/$assetName',
          width: 28,
          height: 28,
          errorBuilder: (c, e, s) =>
              Icon(Icons.star_border, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildTabsBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.0),
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabIcon(
            tabKey: 'wishlist',
            customIcon: _buildCustomIcon('lapangan.png'),
          ),
          _buildTabIcon(tabKey: 'coach', customIcon: _buildCustomIcon('coach.png'),),
          _buildTabIcon(tabKey: 'history', customIcon: _buildCustomIcon('transaction.png'),),
        ],
      ),
    );
  }

  Widget _buildTabIcon({IconData? icon, required String tabKey, Widget? customIcon,}) {
    final bool isSelected = _selectedTab == tabKey;
    Widget displayIcon;
    if (customIcon != null) {
      displayIcon = customIcon;
    } else if (icon != null) {
      displayIcon = Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
        size: 28,
      );
    } else {
      displayIcon = Icon(
        Icons.star_border,
        color: isSelected ? Colors.white : Colors.grey,
        size: 28,
      );
    }

    return Flexible(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabKey;
          });
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: isSelected
                  ? const BorderSide(color: Color(0xFF6C5CE7), width: 2.0)
                  : BorderSide.none,
            ),
          ),
          child: displayIcon,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              color: Colors.white38,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(String type) {
    String imagePath;

    if (type == 'wishlist') {
      imagePath = 'assets/image/wishlist_placeholder_1.png';
    } else if (type == 'coach') {
      imagePath = 'assets/image/coach_placeholder.png';
    } else if (type == 'history') {
      imagePath = 'assets/image/history_placeholder.png';
    } else {
      return Container(color: Colors.grey[800]);
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
    );
  }

  // Card untuk lapangan wishlist (mirip feature card)
  Widget _buildLapanganWishlistCard({
    required String title,
    required String category,
    required String imageUrl,
    required VoidCallback onRemove,
    required VoidCallback onTap,
  }) {
    return GestureDetector( 
      onTap: onTap,
      child: _glassContainer(
        radius: 12,
        height: 160,
        opacity: 0.1,
        child: Column(
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  // Overlay dark
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  
                  // wishlist button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[400],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card untuk coach wishlist (mirip feature coach card)
  Widget _buildCoachWishlistCard({
    required String name,
    required String sportBranch,
    required String photoUrl,
    required String location,
    required VoidCallback onRemove, 
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _glassContainer(
        radius: 12,
        opacity: 0.1,
        padding: const EdgeInsets.all(12.0), 
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                // Avatar (Thumbnail Coach)
                Container(
                  width: 80,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF7E57C2), width: 3),
                    color: Colors.grey[900],
                    image: photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 40)
                      : null,
                ),
                const SizedBox(height: 6),
                // Nama Coach
                Text(
                  name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Cabang Olahraga
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06005E),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06005E).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    sportBranch,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // lokasi Coach
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
              ],
            ),

            // Unwishlist
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onRemove,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: 32, 
                      height: 32, 
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String type,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _glassContainer(
        radius: 12,
        height: 160,
        opacity: 0.1,
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
                    _buildCardContent(type),
                    Container(color: Colors.black.withOpacity(0.15)),
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

  Widget _buildTabContent(String tabKey) {
  return Consumer<WishlistState>(
    builder: (context, wishlistState, child) {
      Widget content;
      bool isEmpty = false;

      if (tabKey == 'wishlist') {
        final lapanganItems = wishlistState.getWishedByType('lapangan');
        isEmpty = lapanganItems.isEmpty;
        
        if (isEmpty) {
          content = _buildEmptyState(
            message: 'Tidak ada Lapangan yang di-Wishlist. Ayo temukan Lapangan favoritmu!',
          );
        } else {
          // Your existing FutureBuilder for lapangan...
          return FutureBuilder<List<Lapangan>>(
            future: _fetchLapanganDetails(lapanganItems),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF571E88)),
                );
              }

              final List<Lapangan> lapanganList = snapshot.data ?? [];
              
              if (snapshot.hasError || !snapshot.hasData || lapanganList.isEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lapanganItems.length,
                  itemBuilder: (context, index) {
                    final item = lapanganItems[index];
                    final lapanganDummy = Lapangan.fromWishedItem(
                      id: item.id,
                      name: item.name,
                      imageUrl: item.imageUrl ?? '',
                      category: item.category,
                    );

                    return LapanganCard(
                      lapangan: lapanganDummy,
                      showWishlistButton: true,
                      onWishlistRemove: () => _showUnwishlistDialog(context, item, wishlistState),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LapanganDetailPage(lapangan: lapanganDummy),
                          ),
                        );
                      },
                      onBook: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LapanganBookingPage(lapangan: lapanganDummy),
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lapanganList.length,
                itemBuilder: (context, index) {
                  final lapangan = lapanganList[index];
                  final wishItem = lapanganItems.firstWhere(
                    (item) => item.id == lapangan.id,
                  );

                  return LapanganCard(
                    lapangan: lapangan,
                    showWishlistButton: true,
                    onWishlistRemove: () => _showUnwishlistDialog(context, wishItem, wishlistState),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LapanganDetailPage(lapangan: lapangan),
                        ),
                      );
                    },
                    onBook: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LapanganBookingPage(lapangan: lapangan),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }
      } else if (tabKey == 'coach') {
        final coachItems = wishlistState.getWishedByType('coach');
        isEmpty = coachItems.isEmpty;
        
        if (isEmpty) {
          content = _buildEmptyState(
            message: 'Tidak ada Coach dalam daftar favorit. Cari Coach terbaik sekarang!',
          );
        } else {
          // Your existing FutureBuilder for coach...
          return FutureBuilder<List<Coach>>(
            future: _fetchCoachDetails(coachItems),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF571E88)),
                );
              }

              final List<Coach> coachList = snapshot.data ?? [];

              if (snapshot.hasError || !snapshot.hasData || coachList.isEmpty) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: coachItems.length,
                  itemBuilder: (context, index) {
                    final item = coachItems[index];
                    return _buildCoachWishlistCard(
                      name: item.name,
                      sportBranch: item.category,
                      photoUrl: item.imageUrl ?? '',
                      location: item.location ?? '',
                      onRemove: () => _showUnwishlistDialog(context, item, wishlistState),
                      onTap: () {
                        final coachDummy = Coach(
                          model: 'coach.coach',
                          pk: int.tryParse(item.id) ?? 0,
                          fields: Fields(
                            name: item.name,
                            sportBranch: item.category,
                            location: item.location ?? '',
                            contact: '',
                            experience: '',
                            certifications: '',
                            serviceFee: '',
                            photo: item.imageUrl ?? '',
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoachDetailPage(coach: coachDummy),
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: coachList.length,
                itemBuilder: (context, index) {
                  final coach = coachList[index];
                  final wishItem = coachItems.firstWhere(
                    (item) => item.id == coach.pk.toString(),
                  );
                  
                  return _buildCoachWishlistCard(
                    name: coach.fields.name,
                    sportBranch: coach.fields.sportBranch,
                    photoUrl: coach.fields.photo ?? '',
                    location: coach.fields.location,
                    onRemove: () => _showUnwishlistDialog(context, wishItem, wishlistState),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CoachDetailPage(coach: coach),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }
      } else if (tabKey == 'history') {
        final historyState = context.watch<BookingHistoryState>();
        final historyItems = historyState.bookings;
        isEmpty = historyItems.isEmpty;

        if (isEmpty) {
          content = _buildEmptyState(
            message: 'Anda belum memiliki riwayat booking. Booking lapangan pertamamu!',
          );
        } else {
          content = ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildHistoryCard(item),
              );
            },
          );
        }
      } else {
        isEmpty = true;
        content = const Center(
          child: Text(
            'Konten tidak tersedia',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }
      
      // Wrap empty states with LayoutBuilder for full-page height
      if (isEmpty) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final safeAreaTop = MediaQuery.of(context).padding.top;
            const estimatedContentAboveTabs = 350.0;
            
            final minHeight = screenHeight - safeAreaTop - kToolbarHeight - estimatedContentAboveTabs;
            
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight > 0 ? minHeight : 0,
              ),
              child: content,
            );
          },
        );
      }

      return content;
    },
  );
}

Widget _buildHistoryCard(BookingItem item) {
  return _glassContainer(
    padding: const EdgeInsets.all(16.0),
    radius: 12,
    opacity: 0.1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Lapangan Name & Sport
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        // const Divider(color: Colors.white24, height: 2.0),
        const SizedBox(height: 15),
        // Detail Booking
        _buildDetailRowSmall(
          icon: Icons.calendar_today,
          label: 'Waktu Booking',
          value: '${item.day}, ${item.slot}',
        ),
        const SizedBox(height: 10),
        _buildDetailRowSmall(
          icon: Icons.payments,
          label: 'Pembayaran',
          value: item.paymentMethod,
        ),
        const SizedBox(height: 10),

        // Total Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Bayar',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              'Rp ${item.price}',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA4E4FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

// Helper tambahan untuk baris detail kecil
Widget _buildDetailRowSmall({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.white54, size: 16),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}

Future<List<Lapangan>> _fetchLapanganDetails(List<WishedItem> wishedItems) async {
  try {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/json/');
    
    if (response != null) {
      List<Lapangan> allLapangan = [];
      for (var d in response) {
        if (d != null) {
          allLapangan.add(Lapangan.fromJson(d));
        }
      }
      
      List<Lapangan> wishedLapangan = allLapangan.where((lapangan) {
        return wishedItems.any((item) => item.id == lapangan.id);
      }).toList();
      
      return wishedLapangan;
    }
  } catch (e) {
    print('Error fetching lapangan details: $e');
  }
  
  return [];
}

Future<List<Coach>> _fetchCoachDetails(List<WishedItem> wishedItems) async {
  try {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://127.0.0.1:8000/coach/json/');
    
    if (response != null) {
      List<Coach> allCoaches = [];
      for (var d in response) {
        if (d != null) {
          allCoaches.add(Coach.fromJson(d));
        }
      }
      
      List<Coach> wishedCoaches = allCoaches.where((coach) {
        return wishedItems.any((item) => item.id == coach.pk.toString());
      }).toList();
      
      return wishedCoaches;
    }
  } catch (e) {
    print('Error fetching coach details: $e');
  }
  
  return [];
}

  Widget _sportIconWidget(String key) {
    final path = 'assets/icon-olahraga/$key.png';
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) =>
          const Icon(Icons.sports, color: Colors.white, size: 20),
    );
  }

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
            String tempAvatar = initialAvatar;
            String tempSport = initialSport;
            Uint8List? pickedBytes;
            final TextEditingController nameController = TextEditingController(
              text: initialName.isNotEmpty ? initialName : UserInfo.username,
            );

            return StatefulBuilder(
              builder: (context, setModalState) {
                // Method untuk memilih foto dari galeri atau file
                Future<void> showImageSourcePicker() async {
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF2A2A2A),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Profile photo',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.photo_library, color: Colors.white),
                                ),
                                title: Text(
                                  'Gallery',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    withData: true,
                                  );
                                  if (result != null && result.files.isNotEmpty) {
                                    pickedBytes = result.files.first.bytes;
                                    if (pickedBytes != null) {
                                      tempAvatar = 'data:image/${result.files.first.extension};base64,${base64Encode(pickedBytes!)}';
                                      setModalState(() {});
                                    }
                                  }
                                },
                              ),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.emoji_emotions, color: Colors.white),
                                ),
                                title: Text(
                                  'Avatar',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showAvatarSelection(setModalState, (avatar) {
                                    pickedBytes = null;
                                    tempAvatar = avatar;
                                  });
                                },
                              ),
                              if (tempAvatar.isNotEmpty && tempAvatar != 'assets/avatar/default_avatar.png')
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                  title: Text(
                                    'Delete',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    pickedBytes = null;
                                    tempAvatar = 'assets/avatar/default_avatar.png';
                                    setModalState(() {});
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                ImageProvider getCurrentAvatar() {
                  if (pickedBytes != null) {
                    return MemoryImage(pickedBytes!);
                  } else if (tempAvatar.startsWith('data:')) {
                    return MemoryImage(base64Decode(tempAvatar.split(',').last));
                  } else if (tempAvatar.isNotEmpty) {
                    return AssetImage(tempAvatar);
                  }
                  return const AssetImage('assets/avatar/default_avatar.png');
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

                        // Username (Read-only)
                        Text(
                          'Username',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  UserInfo.username,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name (Editable)
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
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF111111),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Avatar
                        Text(
                          'Avatar',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: showImageSourcePicker,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: getCurrentAvatar(),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C5CE7),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF1A1A1A), width: 3),
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Favorite Sport
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
                              onTap: () => setModalState(() => tempSport = e.key),
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
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: Image.asset(
                                        'assets/icon-olahraga/${e.key}.png',
                                        errorBuilder: (c, ex, st) => const Icon(Icons.sports, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(e.value, style: const TextStyle(color: Colors.white)),
                                    ),
                                    if (selected) const Icon(Icons.check, color: Color(0xFF6C5CE7)),
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
                                final finalName = nameController.text.trim();
                                if (finalName.isNotEmpty) {
                                  await userState.setName(finalName);
                                }
                                await userState.setFavoriteSport(tempSport);
                                if (pickedBytes != null) {
                                  final b64 = base64Encode(pickedBytes!);
                                  await userState.setAvatarPath('data:image/png;base64,$b64');
                                } else if (tempAvatar.isNotEmpty) {
                                  await userState.setAvatarPath(tempAvatar);
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF571E88),
                                      content: Text(
                                        'Profil diperbarui',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
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
                            child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
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

  // Method untuk menampilkan pilihan avatar
  void _showAvatarSelection(StateSetter setModalState, Function(String) onAvatarSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Avatar',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _avatars.map((avatarPath) {
                    return GestureDetector(
                      onTap: () {
                        onAvatarSelected(avatarPath);
                        Navigator.pop(context);
                        setModalState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(avatarPath),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
    child: Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'PROFILE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _glassContainer(
                            padding: const EdgeInsets.all(20),
                            radius: 16,
                            child: _buildProfileColumn(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTabsBar(),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildTabContent(_selectedTab),
                        ),
                        const SizedBox(height: 24),
                        ],
          ),
        ),
      ),
    ),
  ),
),
          // ),
        ],
      ),
    );
  }
}