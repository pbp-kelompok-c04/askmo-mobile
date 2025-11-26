import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/event.dart';
import 'event_edit_form.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
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
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundAura()),
          SingleChildScrollView(
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
        ],
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
          child:
              widget.event.thumbnail != null &&
                  widget.event.thumbnail!.isNotEmpty
              ? Image.network(
                  'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(widget.event.thumbnail!)}',
                  fit: BoxFit.cover,
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
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                Icon(Icons.image_outlined, color: Colors.grey[400], size: 64),
                const SizedBox(height: 12),
                Text(
                  'Foto tidak tersedia',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
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
              widget.event.olahraga,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.event.nama,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lokasi: ${widget.event.lokasi}',
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
                  ).format(widget.event.tanggal),
                ),
                if (widget.event.jam != null &&
                    widget.event.jam!.toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Jam',
                    value: '${widget.event.jam} WIB',
                  ),
                ],
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.contact_phone,
                  label: 'Kontak',
                  value: widget.event.kontak,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rp ${widget.event.biaya}',
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
            widget.event.deskripsi,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.5,
            ),
          ),
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
                            EventEditFormPage(event: widget.event),
                      ),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: Text(
                    'Edit Event',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF571E88),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteEvent(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: Text(
                    'Hapus Event',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5555),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        title: Text(
          'Hapus Event',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus event ini?',
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
      try {
        final request = context.read<CookieRequest>();
        final response = await request.post(
          'http://localhost:8000/delete-event-ajax/${widget.event.id}/',
          {},
        );

        if (context.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Event berhasil dihapus',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                ),
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  response['message'] ?? 'Gagal menghapus event',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Terjadi kesalahan: $e',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          );
        }
      }
    }
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
