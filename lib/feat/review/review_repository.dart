import 'package:flutter/foundation.dart';
import '../../models/review.dart';

class ReviewRepository {
  ReviewRepository._privateConstructor();
  static final ReviewRepository instance = ReviewRepository._privateConstructor();

  // Use ValueNotifier so UI can listen for changes
  final ValueNotifier<List<Review>> reviews = ValueNotifier<List<Review>>([]);

  List<Review> getAll() => reviews.value;

  void add(Review r) {
    reviews.value = [...reviews.value, r];
  }

  void update(String id, Review updated) {
    reviews.value = reviews.value.map((r) => r.id == id ? updated : r).toList();
  }

  void remove(String id) {
    reviews.value = reviews.value.where((r) => r.id != id).toList();
  }
}
