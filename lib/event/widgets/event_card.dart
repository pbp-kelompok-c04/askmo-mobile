import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
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
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThumbnail(),
                      const SizedBox(height: 20),
                      _buildTitle(),
                      const SizedBox(height: 12),
                      _buildEventDetails(),
                      const SizedBox(height: 12),
                      _buildDescription(),
                      const SizedBox(height: 16),
                      _buildActions(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: event.thumbnail != null && event.thumbnail!.isNotEmpty
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(event.thumbnail!)}',
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF4F4F4F),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF571E88),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
            )
          : AspectRatio(aspectRatio: 16 / 9, child: _buildPlaceholder()),
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, color: Colors.grey[400], size: 48),
                const SizedBox(height: 8),
                Text(
                  'Foto tidak tersedia',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      event.nama,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEventDetails() {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: [
        _buildDetailItem(
          icon: Icons.calendar_today,
          text: DateFormat('d MMM yyyy', 'id_ID').format(event.tanggal),
        ),
        _buildDetailItem(icon: Icons.location_on, text: event.lokasi),
        _buildDetailItem(icon: Icons.sports_soccer, text: event.olahraga),
      ],
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[300], size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[300],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      event.deskripsi,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.grey[400],
        fontSize: 14,
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Selengkapnya',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA4B3FF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Spacer(),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: const Color(0xFF571E88),
            tooltip: 'Edit Event',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 8),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 20),
            color: const Color(0xFFFF5555),
            tooltip: 'Hapus Event',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
