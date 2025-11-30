import 'package:askmo/feat/review/models/review_lapangan.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReviewService {
  // Untuk Flutter web di Chrome
  static const String baseUrl = 'http://localhost:8000';

  // 1. Ambil semua review utk 1 lapangan
  static Future<List<ReviewLapangan>> fetchReviews(
    BuildContext context,
    String lapanganId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/review/json/$lapanganId/';

    final response = await request.get(url);
    final list = response as List<dynamic>;

    return list
        .map((e) => ReviewLapangan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // helper buat ngambil pesan error yg lebih manusiawi
  static String _extractErrorMessage(dynamic response, String defaultMsg) {
    if (response is Map<String, dynamic>) {
      if (response['message'] != null) {
        return response['message'].toString();
      }
      if (response['errors'] != null && response['errors'] is Map) {
        final errors = response['errors'] as Map;
        if (errors.isNotEmpty) {
          // ambil error pertama aja
          final firstKey = errors.keys.first;
          final firstVal = errors[firstKey];

          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          return firstVal.toString();
        }
      }
    }
    return defaultMsg;
  }

  // 2. Tambah review baru
  static Future<void> addReview(
    BuildContext context, {
    required String lapanganId,
    required String reviewerName,
    required double rating,
    required String reviewText,
    String? gambarUrl,
  }) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/review/add-ajax/$lapanganId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
      if (gambarUrl != null && gambarUrl.isNotEmpty) 'gambar': gambarUrl,
    });

    if (response['status'] != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Terjadi kesalahan saat menambah review.',
      );
      throw Exception('Gagal menambah review: $msg');
    }
  }

  // 3. Ambil 1 review (buat edit)
  static Future<ReviewLapangan> fetchSingleReview(
    BuildContext context,
    int reviewId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/review/json-single/$reviewId/';

    final response = await request.get(url);
    return ReviewLapangan.fromJson(response as Map<String, dynamic>);
  }

  // 4. Update review
  static Future<void> updateReview(
    BuildContext context, {
    required int reviewId,
    required String reviewerName,
    required double rating,
    required String reviewText,
    String? gambarUrl,
  }) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/review/update-ajax/$reviewId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
      if (gambarUrl != null && gambarUrl.isNotEmpty) 'gambar': gambarUrl,
    });

    if (response['status'] != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Terjadi kesalahan saat update review.',
      );
      throw Exception('Gagal update review: $msg');
    }
  }

  // 5. Hapus review
  static Future<void> deleteReview(
    BuildContext context,
    int reviewId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/review/delete-ajax/$reviewId/';

    final response = await request.post(url, {});

    if (response['status'] != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Terjadi kesalahan saat menghapus review.',
      );
      throw Exception('Gagal menghapus review: $msg');
    }
  }
}
