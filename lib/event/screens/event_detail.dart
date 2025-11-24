import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

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
          'Detail Event',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
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
            children: [_buildThumbnail(), _buildEventInfo(context)],
          );
        } else {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildThumbnail()),
                Expanded(child: _buildEventInfo(context)),
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
          child: event.thumbnail != null && event.thumbnail!.isNotEmpty
              ? Image.network(
                  event.thumbnail!,
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

  Widget _buildEventInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF06005E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              event.olahraga,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            event.nama,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lokasi: ${event.lokasi}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[300],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
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
                  icon: Icons.calendar_today,
                  label: 'Tanggal',
                  value: DateFormat(
                    'd MMMM yyyy',
                    'id_ID',
                  ).format(event.tanggal),
                ),
                if (event.jam != null && event.jam!.toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Jam',
                    value: '${event.jam} WIB',
                  ),
                ],
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.contact_phone,
                  label: 'Kontak',
                  value: event.kontak,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rp ${event.biaya}',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA4B3FF),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
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
            event.deskripsi,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.5,
            ),
          ),
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
