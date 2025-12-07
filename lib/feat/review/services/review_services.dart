import 'dart:math' as math;

import 'package:askmo/feat/review/models/review_lapangan.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReviewService {
  static const String baseUrl = 'http://localhost:8000';

  static final Map<String, double> _cachedAverageByLapangan = {};

  static double? getCachedAverage(String lapanganId) =>
      _cachedAverageByLapangan[lapanganId];

  static double _roundLikePython(double value, int digits) {
    final factor = math.pow(10, digits);
    final scaled = value * factor;
    final floor = scaled.floorToDouble();
    final diff = scaled - floor;

    const eps = 1e-9;
    if ((diff - 0.5).abs() < eps) {
      final isEven = floor % 2 == 0;
      return (isEven ? floor : floor + 1.0) / factor;
    } else if (diff < 0.5) {
      return floor / factor;
    } else {
      return (floor + 1.0) / factor;
    }
  }

  static double? calculateAverageFromReviews(List<ReviewLapangan> reviews) {
    if (reviews.isEmpty) return null;

    double? datasetRating;
    double userTotal = 0;
    int userCount = 0;

    for (final r in reviews) {
      if (r.isDataset) {
        datasetRating ??= r.rating; // kalau ada >1, pakai yg pertama
      } else {
        userTotal += r.rating;
        userCount++;
      }
    }

    double? avgRating;

    if (datasetRating != null && userCount > 0) {
      avgRating = (datasetRating + userTotal) / (1 + userCount);
    } else if (datasetRating != null && userCount == 0) {
      avgRating = datasetRating;
    } else if (datasetRating == null && userCount > 0) {
      avgRating = userTotal / userCount;
    } else {
      avgRating = null;
    }

    if (avgRating == null) return null;
    return _roundLikePython(avgRating, 1);
  }

  // 1. Ambil semua review utk 1 lapangan
  static Future<List<ReviewLapangan>> fetchReviews(
    BuildContext context,
    String lapanganId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/review/json/$lapanganId/';

    final response = await request.get(url);
    final list = response as List<dynamic>;

    final reviews = list
        .map((e) => ReviewLapangan.fromJson(e as Map<String, dynamic>))
        .toList();

    // Update cache rata-rata untuk lapangan ini
    final avg = calculateAverageFromReviews(reviews);
    if (avg != null) {
      _cachedAverageByLapangan[lapanganId] = avg;
    } else {
      _cachedAverageByLapangan.remove(lapanganId);
    }

    return reviews;
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

    _cachedAverageByLapangan.remove(lapanganId);
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

    _cachedAverageByLapangan.clear();
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

    _cachedAverageByLapangan.clear();
  }
}
