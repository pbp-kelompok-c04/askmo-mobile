// lib/feat/review/coach/services/coach_review_service.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/coach_review.dart';

class CoachReviewService {
  /// Base URL:
  ///  - Web:      http://localhost:8000
  ///  - Emulator: http://10.0.2.2:8000
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

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

  // ===================== FETCH SEMUA REVIEW COACH =====================

  static Future<List<CoachReview>> fetchReviews(
    BuildContext context,
    int coachId,
  ) async {
    final request = context.read<CookieRequest>();

    final url = '$baseUrl/coach/json/$coachId/';

    final response = await request.get(url);

    if (response is! List) {
      throw Exception(
        'Respon server tidak berupa list JSON. Response: $response',
      );
    }

    return response
        .map((e) => CoachReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===================== ADD REVIEW COACH (AJAX) =====================

  static Future<void> addReview(
    BuildContext context, {
    required int coachId,
    required String reviewerName,
    required double rating,
    required String reviewText,
  }) async {
    final request = context.read<CookieRequest>();

    final url = '$baseUrl/coach/add-ajax/$coachId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
    });

    if (response is! Map) {
      throw Exception(
        'Respon server tidak berupa Map JSON ketika add review: $response',
      );
    }

    if (response['status'] != 'success') {
      final msg = _extractErrorMessage(
        response as Map<String, dynamic>,
        'Terjadi kesalahan saat menambah review.',
      );
      throw Exception('Gagal menambah review: $msg');
    }
  }

  // ===================== UPDATE REVIEW COACH (AJAX) =====================

  static Future<void> updateReview(
    BuildContext context, {
    required int reviewId,
    required String reviewerName,
    required double rating,
    required String reviewText,
  }) async {
    final request = context.read<CookieRequest>();

    final url = '$baseUrl/coach/edit-ajax/$reviewId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
    });

    if (response is! Map) {
      throw Exception(
        'Respon server tidak berupa Map JSON ketika update review: $response',
      );
    }

    if (response['status'] != 'success') {
      final msg = _extractErrorMessage(
        response as Map<String, dynamic>,
        'Terjadi kesalahan saat mengupdate review.',
      );
      throw Exception('Gagal update review: $msg');
    }
  }

  // ===================== DELETE REVIEW COACH =====================

  static Future<void> deleteReview(
    BuildContext context,
    int reviewId,
  ) async {
    final request = context.read<CookieRequest>();

    final url = '$baseUrl/coach/delete/$reviewId/';

    final response = await request.post(url, {});

    if (response is! Map) {
      throw Exception(
        'Respon server tidak berupa Map JSON ketika delete review: $response',
      );
    }

    final map = response as Map<String, dynamic>;
    final status = map['status']?.toString();
    final message = map['message']?.toString() ?? '';

    final bool ok =
        status == 'success' || message.toLowerCase().contains('berhasil');

    if (!ok) {
      final msg = _extractErrorMessage(
        map,
        'Terjadi kesalahan saat menghapus review.',
      );
      throw Exception('Gagal menghapus review: $msg');
    }
  }
}
