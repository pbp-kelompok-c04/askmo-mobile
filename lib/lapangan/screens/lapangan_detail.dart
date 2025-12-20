import 'dart:ui';

import 'package:askmo/feat/review/screens/review_list_page.dart';
import 'package:askmo/feat/review/services/review_services.dart';
import 'package:askmo/wishlist/models/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lapangan.dart';

// Halaman detail lapangan, menampilkan informasi lengkap dari objek Lapangan
class LapanganDetailPage extends StatefulWidget {
  final Lapangan lapangan;

  const LapanganDetailPage({super.key, required this.lapangan});

  @override
  State<LapanganDetailPage> createState() => _LapanganDetailPageState();
}

class _LapanganDetailPageState extends State<LapanganDetailPage>
    with SingleTickerProviderStateMixin {
  // Controller animasi untuk background aura
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi aura background (looping halus)
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
    // Wajib dispose untuk mencegah memory leak
    _animationController.dispose();
    super.dispose();
  }

  // Utility sederhana untuk Title Case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Redirect alamat ke Google Maps
  Future<void> _openMap(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return;

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(trimmed)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // Redirect nomor ke WhatsApp
  Future<void> _openWhatsApp(String phone) async {
    var cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhone.isEmpty) return;

    // Normalisasi nomor Indonesia
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '62${cleanedPhone.substring(1)}';
    }

    final uri = Uri.parse("https://wa.me/$cleanedPhone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Nomor ini belum tersedia di WhatsApp.';
    }
  }

  // Background visual (aura animasi)
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
    // Ambil rating rata-rata dari cache review
    final double? currentRating =
        ReviewService.getCachedAverage(widget.lapangan.id);

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

        // Tombol wishlist (Provider)
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
                        style:
                            GoogleFonts.plusJakartaSans(color: Colors.white),
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

      // Stack: background animasi + konten utama
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundAura()),
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
                        Text(
                          widget.lapangan.nama,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bubble kategori olahraga
                        _buildSportBubbles(widget.lapangan.olahraga),
                        const SizedBox(height: 24),

                        // Thumbnail lapangan
                        _buildThumbnail(),
                        const SizedBox(height: 24),

                        // Alamat interaktif (Google Maps)
                        _buildInteractiveAddress(),
                        const SizedBox(height: 24),

                        // Detail utama lapangan
                        _buildDetailsSection(currentRating),
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

  // Alamat yang bisa ditekan (redirect ke Maps)
  Widget _buildInteractiveAddress() {
    final address = widget.lapangan.alamat ?? "";

    return GestureDetector(
      onTap: () => _openMap(address),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address.trim().isEmpty ? "Alamat tidak tersedia" : address,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bubble kategori olahraga
  Widget _buildSportBubbles(String olahragaString) {
    final sports = olahragaString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sports.map((sport) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF06005E),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            _toTitleCase(sport),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Thumbnail utama lapangan
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

  // Placeholder jika gambar tidak tersedia
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.image_not_supported,
            color: Colors.white54, size: 40),
      ),
    );
  }

  // Format tarif ke Rupiah per sesi
  String _formatRupiahPerSesi(dynamic rawTarif) {
    final raw = (rawTarif ?? '').toString().trim();
    if (raw.isEmpty) return 'Rp - / Sesi';

    final parsed = double.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    if (parsed != null) {
      return NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(parsed);
    }

    return 'Rp $raw / Sesi';
  }

  // Section detail utama lapangan
  Widget _buildDetailsSection(double? currentRating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          icon: Icons.star,
          label: 'Rating',
          value: currentRating == null
              ? 'Belum ada rating'
              : '${currentRating.toStringAsFixed(1)} / 5.0',
          valueItalic: currentRating == null,
        ),
        const SizedBox(height: 16),

        // Kontak WhatsApp
        GestureDetector(
          onTap: () => _openWhatsApp(widget.lapangan.kontak ?? ""),
          child: _buildDetailRow(
            icon: Icons.contact_phone,
            label: 'Kontak',
            value: widget.lapangan.kontak ?? "-",
          ),
        ),
        const SizedBox(height: 24),

        // Tombol menuju halaman review
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF571E88),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewListPage(
                    lapanganId: widget.lapangan.id,
                    lapanganName: widget.lapangan.nama,
                  ),
                ),
              );
            },
            child: const Text('Lihat Rating & Review'),
          ),
        ),
      ],
    );
  }

  // Baris detail reusable
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool valueItalic = false,
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
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: valueItalic ? Colors.white70 : Colors.white,
                  fontStyle:
                      valueItalic ? FontStyle.italic : FontStyle.normal,
                  fontWeight:
                      valueItalic ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
