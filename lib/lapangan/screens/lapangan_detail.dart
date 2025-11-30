import 'dart:ui'; // Needed for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:askmo/feat/review/screens/review_list_page.dart';
import 'package:askmo/wishlist/models/wishlist_state.dart';
import '../models/lapangan.dart';

class LapanganDetailPage extends StatefulWidget {
  final Lapangan lapangan;

  const LapanganDetailPage({super.key, required this.lapangan});

  @override
  State<LapanganDetailPage> createState() => _LapanganDetailPageState();
}

class _LapanganDetailPageState extends State<LapanganDetailPage>
    with SingleTickerProviderStateMixin {
  // Animation controllers for the background aura
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation Controller
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

  // Helper to convert text to Title Case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Background Aura Widget
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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Lapangan',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<WishlistState>(
            builder: (context, wishlistState, child) {
              final isWished = wishlistState.isWished(
                widget.lapangan.id,
                'lapangan',
              );
              return IconButton(
                icon: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  wishlistState.toggleWish(
                    id: widget.lapangan.id,
                    type: 'lapangan',
                    name: widget.lapangan.nama,
                    imageUrl: widget.lapangan.thumbnail ?? '',
                    location: '',
                    category: widget.lapangan.olahraga,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF571E88),
                      content: Text(
                        isWished
                            ? 'Dihapus dari Wishlist'
                            : 'Ditambahkan ke Wishlist',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Aura
          Positioned.fill(child: _buildBackgroundAura()),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Nama Lapangan (First)
                        Text(
                          widget.lapangan.nama,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.1, // Reduced line height slightly
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Sport Tag (Title Case)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                            _toTitleCase(widget.lapangan.olahraga),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Alamat (Second)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.lapangan.alamat ?? "-",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 3. Pictures (Third)
                        _buildThumbnail(),
                        const SizedBox(height: 24),

                        // 4. Other Details + Review Button
                        _buildDetailsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: widget.lapangan.thumbnail != null &&
                widget.lapangan.thumbnail!.isNotEmpty
            ? Image.network(
                widget.lapangan.thumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported,
                color: Colors.white54, size: 40),
            const SizedBox(height: 8),
            Text(
              'Foto tidak tersedia',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Rows
        _buildDetailRow(
          icon: Icons.star,
          label: 'Rating',
          value: '${widget.lapangan.rating} / 5.0',
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          icon: Icons.contact_phone,
          label: 'Kontak',
          value: widget.lapangan.kontak ?? "-",
        ),
        if (widget.lapangan.fasilitas != null &&
            widget.lapangan.fasilitas!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.check_circle_outline,
            label: 'Fasilitas',
            value: widget.lapangan.fasilitas!,
          ),
        ],

        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 24),

        // Price
        Text(
          'Rp ${widget.lapangan.tarifPerSesi} / sesi',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA4E4FF),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Description
        Text(
          'Deskripsi',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.lapangan.deskripsi,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),

        // Peraturan (Optional)
        if (widget.lapangan.peraturan != null &&
            widget.lapangan.peraturan!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Peraturan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.lapangan.peraturan!,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Button: Lihat Rating & Review
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF571E88),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewListPage(
                    lapanganId: widget.lapangan.id, // UUID string
                    lapanganName: widget.lapangan.nama,
                  ),
                ),
              );
            },
            child: Text(
              'Lihat Rating & Review',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
