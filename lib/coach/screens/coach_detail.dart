import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askmo/coach/models/coach_model.dart';
import 'package:askmo/coach/screens/coach_edit_form.dart';
import 'package:askmo/user_info.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
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
    // Animasi Aura
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

  /// Helper untuk memformat nama olahraga (Contoh: "voli" -> "Voli")
  String _formatSportLabel(String rawValue) {
    if (rawValue.isEmpty) return rawValue;
    return rawValue
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Helper umum untuk mengubah teks menjadi Title Case (disimpan jika nanti butuh)
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Helper untuk membangun URL foto coach
  String _buildPhotoUrl(String photoPath) {
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }
    return 'http://127.0.0.1:8000/media/$photoPath';
  }

  /// Background aura animasi untuk tampilan detail
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

  Future<void> _deleteCoach() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Hapus Coach',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin hapus "${widget.coach.fields.name}"?',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          'http://127.0.0.1:8000/coach/delete-coach-ajax/${widget.coach.pk}/',
          {},
        );

        if (context.mounted) {
          if (response['status'] == 'success') {
            Navigator.pop(context, true); // Sukses
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? 'Gagal menghapus')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error: $e. Cek URL server!'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
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
                  final photoPath = widget.coach.fields.photo;
                  final imageUrl = (photoPath != null && photoPath.isNotEmpty)
                      ? _buildPhotoUrl(photoPath)
                      : null;

                  wishlistState.toggleWish(
                    id: widget.coach.pk.toString(),
                    type: 'coach',
                    name: widget.coach.fields.name,
                    imageUrl: imageUrl ?? '',
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
          Positioned.fill(child: _buildBackgroundAura()),

          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                alignment: Alignment.topCenter, // <-- bikin tetep rata atas
                padding: const EdgeInsets.all(16),

                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),

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
                        // 1. Nama Coach
                            Text(
                              widget.coach.fields.name,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Sport Branch Tag (pakai _formatSportLabel)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06005E),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF06005E).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Text(
                                _formatSportLabel(widget.coach.fields.sportBranch),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 2. Lokasi
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

                            // 3. Foto
                            _buildPhoto(),
                            const SizedBox(height: 24),

                            // 4. Detail lain
                            _buildDetailsSection(),

                            // 5. Tombol Edit & Delete (Admin Only)
                            if (UserInfo.isAdmin) ...[
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CoachEditFormPage(
                                              coach: widget.coach,
                                            ),
                                          ),
                                        );
                                        if (result == true && context.mounted) {
                                          Navigator.pop(context, true);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Edit Coach',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF571E88),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _deleteCoach,
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Hapus Coach',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF5555),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      //   ],
      // ),
    );
  }

  Widget _buildPhoto() {
    final photoPath = widget.coach.fields.photo;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: (photoPath != null && photoPath.isNotEmpty)
            ? Image.network(
                _buildPhotoUrl(photoPath),
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
}
