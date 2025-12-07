import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/review_lapangan.dart';
import '../services/review_services.dart';

class ReviewEditPage extends StatefulWidget {
  final ReviewLapangan review;

  const ReviewEditPage({
    super.key,
    required this.review,
  });

  @override
  State<ReviewEditPage> createState() => _ReviewEditPageState();
}

class _ReviewEditPageState extends State<ReviewEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _ratingController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _gambarController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.review.reviewerName;
    _ratingController.text = widget.review.rating.toString();
    _deskripsiController.text = widget.review.reviewText;
    _gambarController.text = widget.review.gambarUrl ?? '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _ratingController.dispose();
    _deskripsiController.dispose();
    _gambarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rating = double.tryParse(_ratingController.text.replaceAll(',', '.'));
    if (rating == null || rating < 0 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating harus antara 0 - 5')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ReviewService.updateReview(
        context,
        reviewId: widget.review.id,
        reviewerName: _namaController.text,
        rating: rating,
        reviewText: _deskripsiController.text,
        gambarUrl: _gambarController.text.isEmpty ? null : _gambarController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil diupdate')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update review: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: -200,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF571E88).withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6F0732).withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Text(
                              "Edit Review",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInput(controller: _namaController, label: "Nama"),
                          const SizedBox(height: 16),
                          _buildInput(
                            controller: _ratingController,
                            label: "Rating (0.0 - 5.0)",
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Rating wajib diisi";
                              final r = double.tryParse(v.replaceAll(',', '.'));
                              if (r == null || r < 0 || r > 5) return "Rating harus antara 0 - 5";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInput(
                            controller: _deskripsiController,
                            label: "Deskripsi",
                            maxLines: 4,
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Deskripsi wajib diisi";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildInput(controller: _gambarController, label: "URL Gambar (opsional)"),
                          const SizedBox(height: 28),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF06005E), Color(0xFF571E88)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                                  : const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFF571E88)),
        ),
      ),
    );
  }
}
