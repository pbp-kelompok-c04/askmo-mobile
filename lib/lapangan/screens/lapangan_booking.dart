import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lapangan.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:askmo/history/models/booking_history_state.dart';

// Halaman booking lapangan, menerima objek Lapangan dari halaman sebelumnya
class LapanganBookingPage extends StatefulWidget {
  final Lapangan lapangan;

  const LapanganBookingPage({super.key, required this.lapangan});

  @override
  State<LapanganBookingPage> createState() => _LapanganBookingPageState();
}

// State utama untuk halaman booking lapangan
class _LapanganBookingPageState extends State<LapanganBookingPage>
  with SingleTickerProviderStateMixin {

  // Data jadwal dummy (simulasi, belum dari backend)
  final Map<String, List<String>> _scheduleByDay = <String, List<String>>{
    'Hari ini': <String>[
      '08:00 - 09:00',
      '10:00 - 11:00',
      '14:00 - 15:00',
      '19:00 - 20:00',
    ],
    'Besok': <String>[
      '07:00 - 08:00',
      '09:00 - 10:00',
      '16:00 - 17:00',
      '20:00 - 21:00',
    ],
    'Lusa': <String>[
      '06:00 - 07:00',
      '09:00 - 10:00',
      '13:00 - 14:00',
      '18:00 - 19:00',
    ],
  };

  // State pilihan user
  String? _selectedDay;
  String? _selectedSlot;
  String _paymentMethod = 'Transfer Bank';
  bool _isProcessingPayment = false;

  // Controller animasi background
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Default hari pertama
    _selectedDay = _scheduleByDay.keys.first;

    // Animasi background aura (looping)
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

  // Utility sederhana untuk formatting teks (Title Case)
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(
            'Booking ${widget.lapangan.nama}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),

      // Stack: background animasi + konten utama
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundAura()),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildGlassSection(_buildLapanganHeaderContent()),
                  const SizedBox(height: 16),
                  _buildGlassSection(_buildScheduleSelectorContent()),
                  const SizedBox(height: 16),
                  _buildGlassSection(_buildPaymentMethodsContent()),
                  const SizedBox(height: 16),
                  _buildGlassSection(_buildBookingSummaryContent()),
                  const SizedBox(height: 24),
                  _buildPayButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Wrapper glassmorphism agar UI konsisten
  Widget _buildGlassSection(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Header: info lapangan (nama, lokasi, tarif)
  Widget _buildLapanganHeaderContent() {
    final String alamatText =
        (widget.lapangan.alamat?.trim().isNotEmpty ?? false)
            ? widget.lapangan.alamat!
            : 'Lokasi tidak tersedia';

    // Format harga sesuai format rupiah
    final String tarifText =
        '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(widget.lapangan.tarifPerSesi) ?? 0)} / sesi';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagePlaceholder(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag olahraga
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06005E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _toTitleCase(widget.lapangan.olahraga),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Nama lapangan
              Text(
                widget.lapangan.nama,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              // Lokasi
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      alamatText,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tarif harga
              Text(
                tarifText,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Pemilihan hari dan jam booking
  Widget _buildScheduleSelectorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Jadwal',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // Pilih hari
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _scheduleByDay.keys.map((day) {
              final bool isSelected = _selectedDay == day;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(day,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedDay = day;
                      _selectedSlot = null;
                    });
                  },
                  selectedColor: const Color(0xFF06005E),
                  backgroundColor: Colors.black,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Pilih jam
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_scheduleByDay[_selectedDay] ?? []).map((slot) {
            final bool isSelected = _selectedSlot == slot;
            return ChoiceChip(
              label: Text(slot,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedSlot = slot;
                });
              },
              selectedColor: const Color(0xFF06005E),
              backgroundColor: Colors.black,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Pemilihan metode pembayaran (simulasi)
  Widget _buildPaymentMethodsContent() {
    final methods = ['Transfer Bank', 'E-Wallet', 'Bayar di Tempat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: methods.map((method) {
        return RadioListTile<String>(
          value: method,
          groupValue: _paymentMethod,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _paymentMethod = value);
          },
          title: Text(method,
              style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          activeColor: const Color(0xFFA4E4FF),
        );
      }).toList(),
    );
  }

  // Ringkasan booking sebelum pembayaran
  Widget _buildBookingSummaryContent() {
    // Format harga sesuai format rupiah
    final String tarifText =
        '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(widget.lapangan.tarifPerSesi) ?? 0)} / sesi';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan Booking',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _buildSummaryRow('Lapangan', widget.lapangan.nama),
        _buildSummaryRow('Hari', _selectedDay ?? '-'),
        _buildSummaryRow('Jam', _selectedSlot ?? '-'),
        _buildSummaryRow('Metode', _paymentMethod),
        _buildSummaryRow('Tarif', tarifText),
      ],
    );
  }

  // Widget untuk menampilkan satu baris ringkasan booking
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // Tombol bayar + loading state
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _simulatePayment,
        child: _isProcessingPayment
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Bayar Sekarang'),
      ),
    );
  }

  // Simulasi proses pembayaran
  Future<void> _simulatePayment() async {
    if (_selectedDay == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jadwal terlebih dahulu')),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessingPayment = false);

    _showSuccessSheet();
  }

  // Bottom sheet sukses + simpan ke riwayat booking
  void _showSuccessSheet() {
    final bookingHistoryState =
        Provider.of<BookingHistoryState>(context, listen: false);

    DateTime bookingDate = DateTime.now();
    if (_selectedDay == 'Besok') {
      bookingDate = bookingDate.add(const Duration(days: 1));
    } else if (_selectedDay == 'Lusa') {
      bookingDate = bookingDate.add(const Duration(days: 2));
    }

    bookingHistoryState.addHistoryItem(
      name: widget.lapangan.nama,
      lapanganId: widget.lapangan.id,
      olahraga: widget.lapangan.olahraga,
      date:
          '${DateFormat('dd MMM yyyy').format(bookingDate)}, $_selectedSlot',
      paymentMethod: _paymentMethod,
      price: widget.lapangan.tarifPerSesi,
      imageUrl: widget.lapangan.thumbnail ?? '',
    );

    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(child: Text('Booking Berhasil')),
    );
  }

  // Placeholder gambar jika thumbnail tidak tersedia
  Widget _buildImagePlaceholder() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.sports_soccer, color: Colors.white54),
    );
  }
}
