import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lapangan.dart';

class LapanganBookingPage extends StatefulWidget {
  final Lapangan lapangan;

  const LapanganBookingPage({super.key, required this.lapangan});

  @override
  State<LapanganBookingPage> createState() => _LapanganBookingPageState();
}

class _LapanganBookingPageState extends State<LapanganBookingPage> {
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

  String? _selectedDay;
  String? _selectedSlot;
  String _paymentMethod = 'Transfer Bank';
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _scheduleByDay.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 2), 
          child: Text(
            'Booking ${widget.lapangan.nama}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _buildLapanganHeader(),
            const SizedBox(height: 16),
            _buildScheduleSelector(),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            const SizedBox(height: 16),
            _buildBookingSummary(),
            const SizedBox(height: 12),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildLapanganHeader() {
    final dynamic alamatRaw = widget.lapangan.alamat;
    final String alamatText = (alamatRaw is String && alamatRaw.trim().isNotEmpty)
        ? alamatRaw
        : 'Lokasi tidak tersedia';

    final dynamic tarifRaw = widget.lapangan.tarifPerSesi;
    final String tarifText = 'Rp $tarifRaw / sesi';

    return Container(
      decoration: _sectionDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildImagePlaceholder(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06005E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${widget.lapangan.olahraga}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.lapangan.nama,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alamatText,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tarifText,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // JADWAL
  Widget _buildScheduleSelector() {
    return Container(
      decoration: _sectionDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Pilih Jadwal',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih hari dan jam yang pas untuk kamu.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _scheduleByDay.keys.map((String day) {
                final bool isSelected = _selectedDay == day;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      day,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedDay = day;
                        _selectedSlot = null;
                      });
                    },
                    selectedColor: const Color(0xFF06005E),
                    backgroundColor: const Color(0xFF353535),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedDay != null) ...<Widget>[
            Text(
              'Pilih Jam',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (_scheduleByDay[_selectedDay] ?? <String>[]).map((String slot) {
                final bool isSelected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(
                    slot,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedSlot = slot;
                    });
                  },
                  selectedColor: const Color(0xFF06005E),
                  backgroundColor: const Color(0xFF353535),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // METODE PEMBAYARAN
  Widget _buildPaymentMethods() {
    final List<String> methods = <String>[
      'Transfer Bank',
      'E-Wallet',
      'Bayar di Tempat',
    ];

    return Container(
      decoration: _sectionDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Metode Pembayaran',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pembayaran di sini hanya simulasi, tidak akan memotong saldo kamu.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...methods.map(
            (String method) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF06005E),
              value: method,
              groupValue: _paymentMethod,
              onChanged: (String? value) {
                if (value == null) return;
                setState(() {
                  _paymentMethod = value;
                });
              },
              title: Text(
                method,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                method == 'Bayar di Tempat'
                    ? 'Bayar di lokasi saat datang.'
                    : 'Simulasi langsung disetujui.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // RINGKASAN
  Widget _buildBookingSummary() {
    final dynamic tarifRaw = widget.lapangan.tarifPerSesi;
    final String tarifText = 'Rp $tarifRaw / sesi';

    return Container(
      decoration: _sectionDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Ringkasan Booking',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Lapangan', widget.lapangan.nama),
          _buildSummaryRow(_selectedDay == null ? 'Hari' : 'Hari', _selectedDay ?? '-'),
          _buildSummaryRow('Jam', _selectedSlot ?? '-'),
          _buildSummaryRow('Metode', _paymentMethod),
          _buildSummaryRow('Tarif', tarifText),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _simulatePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06005E),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isProcessingPayment
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Memproses...',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Bayar Sekarang',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  // LOGIC PEMBAYARAN (SIMULASI)
  Future<void> _simulatePayment() async {
    if (_selectedDay == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF5555),
          content: Text(
            'Pilih jadwal terlebih dahulu.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessingPayment = false;
    });

    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext ctx) {
        final dynamic tarifRaw = widget.lapangan.tarifPerSesi;
        final String tarifText = 'Rp $tarifRaw / sesi';

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0BB07B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Booking Berhasil',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Pembayaran $_paymentMethod dikonfirmasi.\nJangan lupa datang tepat waktu!',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Mengalihkan kembali...',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildSummaryRow('Lapangan', widget.lapangan.nama),
              _buildSummaryRow(
                'Hari & Jam',
                '${_selectedDay ?? '-'} • ${_selectedSlot ?? '-'}',
              ),
              _buildSummaryRow('Total', tarifText),
            ],
          ),
        );
      },
    );

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).maybePop(); // close sheet
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // pop booking page
      }
    });
  }

  // PLACEHOLDER GAMBAR
  Widget _buildImagePlaceholder() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF4F4F4F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.sports_soccer,
          color: Colors.white70,
          size: 32,
        ),
      ),
    );
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: const Color(0xFF353535),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.15),
      ),
    );
  }
}