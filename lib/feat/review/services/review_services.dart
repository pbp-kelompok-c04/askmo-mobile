// lib/feat/review/services/review_service.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:askmo/config/api_base.dart';
import 'package:askmo/feat/review/models/review_lapangan.dart';

class ReviewService {
  // pakai base URL dari config/api_base.dart
  static String get baseUrl => apiBase;

  // cache rata-rata per lapangan (optional, buat tampilan lebih cepat)
  static final Map<String, double> _cachedAverageByLapangan = {};

  static double? getCachedAverage(String lapanganId) =>
      _cachedAverageByLapangan[lapanganId];

  // ===== helper rounding biar mirip Python round(..., 1) =====
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

  // hitung rata-rata rating dari list ReviewLapangan
  static double? calculateAverageFromReviews(List<ReviewLapangan> reviews) {
    if (reviews.isEmpty) return null;

    double? datasetRating;
    double userTotal = 0;
    int userCount = 0;

    for (final r in reviews) {
      if (r.isDataset) {
        datasetRating ??= r.rating; // kalau lebih dari satu, pakai yang pertama
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

  // ===== helper ambil pesan error dari response Django =====
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

  // =========================================================
  // 1. Ambil semua review untuk 1 lapangan (JSON list)
  // Django: path('lapangan/json/<uuid:lapangan_id>/', ...)
  // project urls: include('review/', review.urls)
  // => /review/lapangan/json/<lapangan_id>/
  // =========================================================
  static Future<List<ReviewLapangan>> fetchReviews(
    BuildContext context,
    String lapanganId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/review/lapangan/json/$lapanganId/';

    final response = await request.get(url);

    if (response is! List) {
      throw Exception(
          'Server tidak mengembalikan List JSON. Response: $response');
    }

    final reviews = response
        .map((e) => ReviewLapangan.fromJson(e as Map<String, dynamic>))
        .toList();

    // update cache rata-rata
    final avg = calculateAverageFromReviews(reviews);
    if (avg != null) {
      _cachedAverageByLapangan[lapanganId] = avg;
    } else {
      _cachedAverageByLapangan.remove(lapanganId);
    }

    return reviews;
  }

  // =========================================================
  // 2. Tambah review baru
  // Django: path('lapangan/add-ajax/<uuid:lapangan_id>/', ...)
  // => /review/lapangan/add-ajax/<lapangan_id>/
  // =========================================================
  static Future<void> addReview(
    BuildContext context, {
    required String lapanganId,
    required String reviewerName,
    required double rating,
    required String reviewText,
    String? gambarUrl,
  }) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/review/lapangan/add-ajax/$lapanganId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
      if (gambarUrl != null && gambarUrl.isNotEmpty) 'gambar': gambarUrl,
    });

    if (response is! Map || response['status']?.toString() != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Terjadi kesalahan saat menambah review.',
      );
      throw Exception('Gagal menambah review: $msg');
    }

    _cachedAverageByLapangan.remove(lapanganId);
  }

  // =========================================================
  // 3. Ambil satu review (buat form edit)
  // Django: path('lapangan/json-single/<int:review_id>/', ...)
  // => /review/lapangan/json-single/<review_id>/
  // =========================================================
  static Future<ReviewLapangan> fetchSingleReview(
    BuildContext context,
    int reviewId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/lapangan/json-single/$reviewId/';

    final response = await request.get(url);

    if (response is! Map) {
      throw Exception(
          'Server tidak mengembalikan Map JSON. Response: $response');
    }

    return ReviewLapangan.fromJson(response as Map<String, dynamic>);
  }

  // =========================================================
  // 4. Update review
  // Django: path('lapangan/update-ajax/<int:review_id>/', ...)
  // => /review/lapangan/update-ajax/<review_id>/
  // =========================================================
  static Future<void> updateReview(
    BuildContext context, {
    required int reviewId,
    required String reviewerName,
    required double rating,
    required String reviewText,
    String? gambarUrl,
  }) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/review/lapangan/update-ajax/$reviewId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
      if (gambarUrl != null && gambarUrl.isNotEmpty) 'gambar': gambarUrl,
    });

    if (response is! Map || response['status']?.toString() != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Terjadi kesalahan saat update review.',
      );
      throw Exception('Gagal update review: $msg');
    }

    _cachedAverageByLapangan.clear();
  }

  // =========================================================
  // 5. Hapus review
  // Django: path('lapangan/delete-ajax/<int:review_id>/', ...)
  // => /review/lapangan/delete-ajax/<review_id>/
  // =========================================================
  static Future<void> deleteReview(
    BuildContext context,
    int reviewId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/review/lapangan/delete-ajax/$reviewId/';

    final response = await request.post(url, {});

    if (response is! Map || response['status']?.toString() != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Terjadi kesalahan saat menghapus review.',
      );
      throw Exception('Gagal menghapus review: $msg');
    }

    _cachedAverageByLapangan.clear();
  }
}