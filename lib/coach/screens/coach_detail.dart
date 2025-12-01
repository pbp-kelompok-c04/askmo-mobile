import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askmo/coach/models/coach_model.dart';
import 'package:askmo/coach/screens/coach_edit_form.dart';
import 'package:askmo/user_info.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter

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

  String _buildPhotoUrl(String photoPath) {
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }
    return 'http://127.0.0.1:8000/media/$photoPath';
  }

  // WIDGET AURA BACKGROUND
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
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND AURA
          Positioned.fill(child: _buildBackgroundAura()),

          // 2. KONTEN
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF571E88),
                          width: 4,
                        ),
                        color: Colors.grey[800],
                        image:
                            widget.coach.fields.photo != null &&
                                widget.coach.fields.photo!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  _buildPhotoUrl(widget.coach.fields.photo!),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          widget.coach.fields.photo == null ||
                              widget.coach.fields.photo!.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 80,
                            )
                          : null,
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.coach.fields.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF571E88).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF571E88)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF571E88).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            // Format nama olahraga jadi Title Case (Voli)
                            _formatSportLabel(widget.coach.fields.sportBranch),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // CONTAINER GLASSMORPHISM
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF353535,
                          ).withOpacity(0.6), // Transparan gelap
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.location_on,
                              "Lokasi",
                              widget.coach.fields.location,
                            ),
                            Divider(color: Colors.grey.withOpacity(0.2)),
                            _buildInfoRow(
                              Icons.monetization_on,
                              "Tarif",
                              widget.coach.fields.serviceFee,
                            ),
                            Divider(color: Colors.grey.withOpacity(0.2)),
                            _buildInfoRow(
                              Icons.contact_phone,
                              "Kontak",
                              widget.coach.fields.contact,
                            ),
                            Divider(color: Colors.grey.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              "Pengalaman",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.coach.fields.experience.isNotEmpty
                                  ? widget.coach.fields.experience
                                  : "-",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[300],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Sertifikasi",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.coach.fields.certifications.isNotEmpty
                                  ? widget.coach.fields.certifications
                                  : "-",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[300],
                                height: 1.5,
                              ),
                            ),

                            // TOMBOL EDIT & DELETE (ADMIN ONLY)
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
                                        if (result == true && context.mounted)
                                          Navigator.pop(context, true);
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Edit Event', // Text Putih
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF571E88,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                        'Hapus Event', // Text Putih
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFF5555,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF571E88).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFA4E4FF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : "-",
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
      ),
    );
  }
}
