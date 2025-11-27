// lib/screens/lapangan_detail.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:askmo/wishlist/models/wishlist_state.dart';
import '../models/lapangan.dart';

class LapanganDetailPage extends StatelessWidget {
  final Lapangan lapangan;

  const LapanganDetailPage({super.key, required this.lapangan});

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
          'Detail Lapangan',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<WishlistState>(
            builder: (context, wishlistState, child) {
              final isWished = wishlistState.isWished(lapangan.id, 'lapangan');
              return IconButton(
                icon: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  wishlistState.toggleWish(
                    id: lapangan.id,
                    type: 'lapangan',
                    name: lapangan.nama,
                    imageUrl: lapangan.thumbnail ?? '',
                    category: lapangan.olahraga,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isWished
                            ? 'Dihapus dari Wishlist'
                            : 'Ditambahkan ke Wishlist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF353535),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildImageAndInfo(context)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAndInfo(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [_buildThumbnail(), _buildLapanganInfo(context)],
          );
        } else {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildThumbnail()),
                Expanded(child: _buildLapanganInfo(context)),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildThumbnail() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: lapangan.thumbnail != null && lapangan.thumbnail!.isNotEmpty
              ? Image.network(
                  lapangan.thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF4F4F4F),
      child: Center(
        child: Text(
          'Foto tidak tersedia',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLapanganInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sport Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF06005E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              lapangan.olahraga,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nama Lapangan
          Text(
            lapangan.nama,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // Lokasi
          Text(
            'Lokasi: ${lapangan.alamat ?? "-"}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[300],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),

          // Details Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2)),
                bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.star,
                  label: 'Rating',
                  value: '${lapangan.rating} / 5.0',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.contact_phone,
                  label: 'Kontak',
                  value: lapangan.kontak ?? "-",
                ),
                if (lapangan.fasilitas != null &&
                    lapangan.fasilitas!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Fasilitas',
                    value: lapangan.fasilitas!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Price
          Text(
            'Rp ${lapangan.tarifPerSesi} / sesi',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA4B3FF),
              fontSize: 36,
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
            lapangan.deskripsi,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.5,
            ),
          ),

          // Peraturan (Optional)
          if (lapangan.peraturan != null && lapangan.peraturan!.isNotEmpty) ...[
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
              lapangan.peraturan!,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
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
        Icon(icon, color: Colors.grey[300], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
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
