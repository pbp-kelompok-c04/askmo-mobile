// lib/feat/review/coach/services/coach_review_service.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// IMPORT API BASE
import 'package:askmo/config/api_base.dart';

import '../models/coach_review.dart';

class CoachReviewService {
  // Gunakan apiBase dari api_base.dart
  static String get baseUrl => apiBase;

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
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/coach/json/$coachId/';

    final response = await request.get(url);

    if (response is! List) {
      throw Exception(
        'Server tidak mengembalikan List JSON. Response: $response',
      );
    }

    return response
        .map((e) => CoachReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===================== ADD REVIEW =====================

  static Future<void> addReview(
    BuildContext context, {
    required int coachId,
    required String reviewerName,
    required double rating,
    required String reviewText,
  }) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/review/coach/add-ajax/$coachId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
    });

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
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/coach/edit-ajax/$reviewId/';

    final response = await request.post(url, {
      'reviewer_name': reviewerName,
      'rating': rating.toString(),
      'review_text': reviewText,
    });

    if (response is! Map ||
        response['status']?.toString() != 'success') {
      final msg = _extractErrorMessage(
        response,
        'Gagal update review.',
      );
      throw Exception(msg);
    }
  }

  // ===================== DELETE REVIEW =====================

  static Future<void> deleteReview(
    BuildContext context,
    int reviewId,
  ) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/coach/delete/$reviewId/';

    final response = await request.post(url, {});

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