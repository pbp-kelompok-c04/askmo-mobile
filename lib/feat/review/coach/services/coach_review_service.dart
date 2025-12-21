import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:askmo/config/api_base.dart';
import '../models/coach_review.dart';

// Service untuk operasi review coach (CRUD)
class CoachReviewService {
  // Gunakan apiBase dari api_base.dart sebagai base URL
  static String get baseUrl => apiBase;

  // Ekstrak pesan error dari response backend
  static String _extractErrorMessage(dynamic response, String defaultMsg) {
    if (response is Map<String, dynamic>) {
      if (response['message'] != null) return response['message'].toString();

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

  // ===================== FETCH REVIEWS COACH =====================

  static Future<List<CoachReview>> fetchReviews(
    BuildContext context,
    int coachId,
  ) async {
    // Ambil instance request dari Provider
    final request = context.read<CookieRequest>();
    // Endpoint untuk ambil review coach
    final url = '$baseUrl/coach/json/$coachId/';

    final response = await request.get(url);

    // Validasi response harus List
    if (response is! List) {
      throw Exception(
        'Server tidak mengembalikan List JSON. Response: $response',
      );
    }

    // Mapping response ke list model CoachReview
    return response
        .map((e) => CoachReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===================== TAMBAH REVIEW =====================
  static Future<void> addReview(
    BuildContext context, {
    required int coachId,
    required String reviewerName,
    required double rating,
    required String reviewText,
  }) async {
    // Ambil instance request dari Provider
    final request = context.read<CookieRequest>();
    // Endpoint untuk tambah review
    final url = '$baseUrl/review/coach/add-ajax/$coachId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
    });

    // Cek status response
    if (response is! Map ||
        response['status']?.toString() != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Gagal menambah review.',
      );
      throw Exception(msg);
    }
  }

  // ===================== UPDATE REVIEW =====================
  static Future<void> updateReview(
    BuildContext context, {
    required int reviewId,
    required String reviewerName,
    required double rating,
    required String reviewText,
  }) async {
    // Ambil instance request dari Provider
    final request = context.read<CookieRequest>();
    // Endpoint untuk update review
    final url = '$baseUrl/coach/edit-ajax/$reviewId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
    });

    // Cek status response
    if (response is! Map ||
        response['status']?.toString() != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Gagal update review.',
      );
      throw Exception(msg);
    }
  }

  // ===================== HAPUS REVIEW =====================
  static Future<void> deleteReview(
    BuildContext context,
    int reviewId,
  ) async {
    // Ambil instance request dari Provider
    final request = context.read<CookieRequest>();
    // Endpoint untuk hapus review
    final url = '$baseUrl/coach/delete/$reviewId/';

    final response = await request.post(url, {});

    // Cek status response
    if (response is! Map ||
        (response['status']?.toLowerCase() != 'success' &&
            !(response['message'] ?? '')
                .toLowerCase()
                .contains('berhasil'))) {
      final msg = _extractErrorMessage(
        response,
        'Gagal menghapus review.',
      );
      throw Exception(msg);
    }
  }
}