import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askmo/coach/models/coach_model.dart';

class CoachDetailPage extends StatelessWidget {
  final Coach coach;

  const CoachDetailPage({super.key, required this.coach});

  /// Build photo URL dari berbagai format
  String _buildPhotoUrl(String photoPath) {
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }
    return 'http://127.0.0.1:8000/media/$photoPath';
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
          'Detail Coach',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image / Avatar Besar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF571E88), width: 4),
                  color: Colors.grey[800],
                  image:
                      coach.fields.photo != null && coach.fields.photo!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                  _buildPhotoUrl(coach.fields.photo!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child:
                    coach.fields.photo == null || coach.fields.photo!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 80)
                        : null,
              ),
            ),

            // Nama dan Cabang Olahraga
            Center(
              child: Column(
                children: [
                  Text(
                    coach.fields.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF571E88).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF571E88)),
                    ),
                    child: Text(
                      coach.fields.sportBranch,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFA4E4FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Container Detail Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                      Icons.location_on, "Lokasi", coach.fields.location),
                  _buildDivider(),
                  _buildInfoRow(
                      Icons.monetization_on, "Tarif", coach.fields.serviceFee),
                  _buildDivider(),
                  _buildInfoRow(Icons.contact_phone, "Kontak", coach.fields.contact),
                  _buildDivider(),
                  const SizedBox(height: 10),
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
                    coach.fields.experience.isNotEmpty
                        ? coach.fields.experience
                        : "-",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[300], height: 1.5),
                  ),
                  const SizedBox(height: 20),
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
                    coach.fields.certifications.isNotEmpty
                        ? coach.fields.certifications
                        : "-",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[300], height: 1.5),
                  ),
                  const SizedBox(height: 40), // Space for bottom navigation
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.2), height: 1);
  }
}