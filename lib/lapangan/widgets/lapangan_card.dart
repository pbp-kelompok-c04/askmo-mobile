import 'dart:ui';

import 'package:askmo/feat/review/services/review_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/lapangan.dart';

// Card komponen untuk menampilkan ringkasan informasi lapangan
class LapanganCard extends StatelessWidget {
  final Lapangan lapangan;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final bool showWishlistButton;
  final VoidCallback? onWishlistRemove;

  const LapanganCard({
    super.key,
    required this.lapangan,
    required this.onTap,
    required this.onBook,
    this.showWishlistButton = false,
    this.onWishlistRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil rating rata-rata dari cache review (jika ada)
    final double? displayRating =
        ReviewService.getCachedAverage(lapangan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          // Efek glassmorphism
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                // Tap card untuk ke halaman detail
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian thumbnail
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: lapangan.thumbnail != null &&
                                    lapangan.thumbnail!.isNotEmpty
                                ? Image.network(
                                    lapangan.thumbnail!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                        ),

                        // Tombol wishlist (khusus halaman wishlist)
                        if (showWishlistButton)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: onWishlistRemove,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Konten utama card
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bubble kategori olahraga
                          _buildSportBubbles(lapangan.olahraga),
                          const SizedBox(height: 12),

                          // Nama lapangan
                          Text(
                            lapangan.nama,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Alamat singkat
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  lapangan.alamat ??
                                      'Lokasi tidak tersedia',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Harga dan rating
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(
                                  double.parse(lapangan.tarifPerSesi),
                                )} / Sesi",
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFA4B3FF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    displayRating == null
                                        ? 'Belum ada rating'
                                        : displayRating.toStringAsFixed(1),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontStyle: displayRating == null
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      fontWeight: displayRating == null
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Tombol aksi
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onTap,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color:
                                          Colors.white.withOpacity(0.6),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Detail',
                                    style:
                                        GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: onBook,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF06005E),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Booking',
                                    style:
                                        GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Bubble kategori olahraga (bisa lebih dari satu)
  Widget _buildSportBubbles(String olahragaString) {
    final List<String> sports = olahragaString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: sports.map((sport) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF06005E),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            toTitleCase(sport),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Placeholder jika gambar gagal dimuat
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF4F4F4F),
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }
}

// Utility global untuk Title Case
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
