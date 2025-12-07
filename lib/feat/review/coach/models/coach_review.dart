class CoachReview {
  final int id;
  final String reviewerName;
  final double rating;
  final String reviewText;
  final String tanggalDibuat;
  final bool canEdit;
  final bool canDelete;

  CoachReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.reviewText,
    required this.tanggalDibuat,
    required this.canEdit,
    required this.canDelete,
  });

  factory CoachReview.fromJson(Map<String, dynamic> json) {
    return CoachReview(
      id: json['id'] as int,
      reviewerName: json['reviewer_name'] ?? 'Anonim',
      rating: (json['rating'] as num).toDouble(),
      reviewText: json['review_text'] ?? '',
      tanggalDibuat: json['tanggal_dibuat'] ?? '',
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }
}
