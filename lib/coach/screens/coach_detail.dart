import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:askmo/wishlist/models/wishlist_state.dart';
import '../models/coach_model.dart';
import 'package:askmo/feat/review/coach/screens/coach_review_list_page.dart';
import 'package:askmo/feat/review/coach/services/coach_review_service.dart';
import 'package:askmo/feat/review/coach/models/coach_review.dart';

class CoachDetailPage extends StatefulWidget {
  final Coach coach;

  const CoachDetailPage({super.key, required this.coach});

  @override
  State<CoachDetailPage> createState() => _CoachDetailPageState();
}

class _CoachDetailPageState extends State<CoachDetailPage>
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

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
          'Detail Coach',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<WishlistState>(
            builder: (context, wishlistState, child) {
              final isWished = wishlistState.isWished(
                widget.coach.pk.toString(),
                'coach',
              );
              return IconButton(
                icon: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  wishlistState.toggleWish(
                    id: widget.coach.pk.toString(),
                    type: 'coach',
                    name: widget.coach.fields.name,
                    imageUrl: widget.coach.fields.photo,
                    location: widget.coach.fields.location,
                    category: widget.coach.fields.sportBranch,
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
                        // 1. Nama Coach (First)
                        Text(
                          widget.coach.fields.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),

                        // Narrow spacing
                        const SizedBox(height: 6),

                        // Sport Branch Tag (Title Case) - WARNA SAMA DENGAN LAPANGAN
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06005E), // WARNA SAMA
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
                            _toTitleCase(widget.coach.fields.sportBranch),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Location (Second)
                        if (widget.coach.fields.location.isNotEmpty)
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
                                  widget.coach.fields.location,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (widget.coach.fields.location.isNotEmpty)
                          const SizedBox(height: 24),

                        // 3. Photo (Third)
                        _buildPhoto(),
                        const SizedBox(height: 24),

                        // 4. Other Details
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

  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9, // Slightly wider for hero-like feel
        child: widget.coach.fields.photo.isNotEmpty
            ? Image.network(
                widget.coach.fields.photo,
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
            const Icon(Icons.person, color: Colors.white54, size: 40),
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
        // RATING DI ATAS KONTAK
        _buildRatingRow(),

        // Info Rows
        if (widget.coach.fields.contact.isNotEmpty) ...[
          _buildDetailRow(
            icon: Icons.contact_phone,
            label: 'Kontak',
            value: widget.coach.fields.contact,
          ),
          const SizedBox(height: 16),
        ],

        if (widget.coach.fields.experience.isNotEmpty) ...[
          _buildDetailRow(
            icon: Icons.work_outline,
            label: 'Pengalaman',
            value: widget.coach.fields.experience,
          ),
          const SizedBox(height: 16),
        ],

        if (widget.coach.fields.certifications.isNotEmpty) ...[
          _buildDetailRow(
            icon: Icons.card_membership,
            label: 'Sertifikasi',
            value: widget.coach.fields.certifications,
          ),
        ],

        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 24),

        if (widget.coach.fields.serviceFee.isNotEmpty) ...[
          Text(
            'Rp ${widget.coach.fields.serviceFee} / Sesi',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA4E4FF),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // === Tombol Lihat Rating & Review (ungu) ===
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoachReviewListPage(
                      coachId: widget.coach.pk, // id coach (int)
                      coachName: widget.coach.fields.name, // nama coach
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: const Color(0xFF571E88),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lihat Rating & Review',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingRow() {
    return FutureBuilder<List<CoachReview>>(
      future: CoachReviewService.fetchReviews(context, widget.coach.pk),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final reviews = snapshot.data!;
        double total = 0;
        for (final r in reviews) {
          total += r.rating;
        }
        final avg = total / reviews.length;

        return Column(
          children: [
            _buildDetailRow(
              icon: Icons.star,
              label: 'Rating',
              value: '${avg.toStringAsFixed(1)} / 5.0',
            ),
            const SizedBox(height: 16),
          ],
        );
      },
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

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.2), height: 1);
  }
}
