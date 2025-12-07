import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/review_lapangan.dart';
import '../services/review_services.dart';
import 'review_form_page.dart';
import 'review_edit_page.dart';

class ReviewListPage extends StatefulWidget {
  final String lapanganId;
  final String lapanganName;

  const ReviewListPage({
    super.key,
    required this.lapanganId,
    required this.lapanganName,
  });

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late Future<List<ReviewLapangan>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _futureReviews = ReviewService.fetchReviews(context, widget.lapanganId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureReviews = ReviewService.fetchReviews(context, widget.lapanganId);
    });
  }

  void _goToAddReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewFormPage(
          lapanganId: widget.lapanganId,
          lapanganName: widget.lapanganName,
        ),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  void _goToEditReview(ReviewLapangan review) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewEditPage(review: review),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  void _deleteReview(ReviewLapangan review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF571E88).withOpacity(0.5),
          ),
        ),
        title: Text(
          'Konfirmasi',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin mau hapus review ini?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ReviewService.deleteReview(context, review.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil dihapus')),
        );
      }
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // background glow
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
                    const Color(0xFF571E88).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -250,
            right: -120,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6F0732).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: back + teks kecil
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kembali ke halaman sebelumnya',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Review Lapangan :',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 14, // diperbesar
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.lapanganName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 20, // diperbesar
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // OVERALL RATING
                _buildOverallRating(),
                const SizedBox(height: 12),

                // LIST REVIEW
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: FutureBuilder<List<ReviewLapangan>>(
                      future: _futureReviews,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        }

                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final allReviews = snapshot.data!;
                        // hanya review user (dataset ga ditampilin)
                        final userReviews =
                            allReviews.where((e) => !e.isDataset).toList();

                        if (userReviews.isEmpty) {
                          return ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'Belum ada review.\nJadilah yang pertama!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: userReviews.length,
                          itemBuilder: (context, index) {
                            final review = userReviews[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildReviewCard(review),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddReview,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06005E), Color(0xFF571E88)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: const Row(
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Tambah Review',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallRating() {
    return FutureBuilder<List<ReviewLapangan>>(
      future: _futureReviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Belum ada rating',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          );
        }

        final reviews = snapshot.data!;
        final dataset = reviews.where((e) => e.isDataset).toList();
        final nonDataset = reviews.where((e) => !e.isDataset).toList();

        double totalRating = 0;
        int totalCount = 0;

        if (dataset.isNotEmpty) {
          totalRating += dataset.first.rating;
          totalCount += 1;
        }

        for (final r in nonDataset) {
          totalRating += r.rating;
          totalCount += 1;
        }

        if (totalCount == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Belum ada rating',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          );
        }

        final avg =
            double.parse((totalRating / totalCount).toStringAsFixed(1));
        final ulasanCount = nonDataset.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [
                          const Color(0xFF571E88).withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      avg.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.amber,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ 5.0',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$ulasanCount ulasan',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewLapangan review) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nama + tanggal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      review.reviewerName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    review.tanggalDibuat,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // rating kecil
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${review.rating}/5',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // teks review
              Text(
                review.reviewText,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              // gambar (kalau ada)
              if (review.gambarUrl != null && review.gambarUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      review.gambarUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey.shade900,
                        child: Center(
                          child: Text(
                            'Gagal memuat gambar',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // tombol edit / hapus
              if (review.canEdit || review.canDelete) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (review.canEdit)
                      TextButton.icon(
                        onPressed: () => _goToEditReview(review),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor:
                              const Color(0xFF571E88).withOpacity(0.9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    if (review.canEdit && review.canDelete)
                      const SizedBox(width: 8),
                    if (review.canDelete)
                      TextButton.icon(
                        onPressed: () => _deleteReview(review),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor:
                              Colors.redAccent.withOpacity(0.9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text(
                          'Hapus',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
