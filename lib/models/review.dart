class Review {
  final String id;
  final String name;
  final double rating;
  final String text;
  final String date;
  final String? imageUrl;

  Review({required this.id, required this.name, required this.rating, required this.text, required this.date, this.imageUrl});

  Review copyWith({String? id, String? name, double? rating, String? text, String? date, String? imageUrl}) {
    return Review(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
