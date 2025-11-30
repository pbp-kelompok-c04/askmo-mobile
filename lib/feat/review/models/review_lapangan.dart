class ReviewLapangan {
  final int id;
  final String reviewerName;
  final double rating;
  final String reviewText;
  final String tanggalDibuat;
  final String? gambarUrl;
  final bool canEdit;
  final bool canDelete;
  final bool isDataset;

  ReviewLapangan({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.reviewText,
    required this.tanggalDibuat,
    this.gambarUrl,
    required this.canEdit,
    required this.canDelete,
    required this.isDataset,
  });

  factory ReviewLapangan.fromJson(Map<String, dynamic> json) {
    return ReviewLapangan(
      id: json['id'] as int,
      reviewerName: json['reviewer_name'] ?? 'Anonim',
      rating: (json['rating'] as num).toDouble(),
      reviewText: json['review_text'] ?? '',
      tanggalDibuat: json['tanggal_dibuat'] ?? '',
      
      /// FIX TERPENTING
      gambarUrl: json['gambar_url'] ?? json['gambar'] ?? null,

      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
      isDataset: json['is_dataset'] ?? false,
    );
  }
}
