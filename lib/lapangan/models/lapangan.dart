// lib/models/lapangan.dart
import 'dart:convert';

List<Lapangan> lapanganFromJson(String str) =>
    List<Lapangan>.from(json.decode(str).map((x) => Lapangan.fromJson(x)));

String lapanganToJson(List<Lapangan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Lapangan {
  String id;
  String nama;
  String deskripsi;
  String olahraga;
  String? thumbnail;
  double rating;
  bool refund;
  String tarifPerSesi;
  String? kontak;
  String? alamat;
  String? kecamatan;
  String? review;
  String? peraturan;
  String? fasilitas;

  Lapangan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.olahraga,
    this.thumbnail,
    required this.rating,
    required this.refund,
    required this.tarifPerSesi,
    this.kontak,
    this.alamat,
    this.kecamatan,
    this.review,
    this.peraturan,
    this.fasilitas,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) => Lapangan(
        id: json["id"],
        nama: json["nama"],
        deskripsi: json["deskripsi"] ?? "",
        olahraga: json["olahraga"] ?? "Lainnya",
        thumbnail: json["thumbnail"],
        rating: (json["rating"] is int)
            ? (json["rating"] as int).toDouble()
            : (json["rating"] as double? ?? 0.0),
        refund: json["refund"] ?? false,
        tarifPerSesi: json["tarif_per_sesi"] ?? "0",
        kontak: json["kontak"],
        alamat: json["alamat"],
        kecamatan: json["kecamatan"],
        review: json["review"],
        peraturan: json["peraturan"],
        fasilitas: json["fasilitas"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "deskripsi": deskripsi,
        "olahraga": olahraga,
        "thumbnail": thumbnail,
        "rating": rating,
        "refund": refund,
        "tarif_per_sesi": tarifPerSesi,
        "kontak": kontak,
        "alamat": alamat,
        "kecamatan": kecamatan,
        "review": review,
        "peraturan": peraturan,
        "fasilitas": fasilitas,
      };

  factory Lapangan.fromWishedItem({
    required String id,
    required String name,
    required String imageUrl,
    required String category,
  }) {
    return Lapangan(
      id: id,
      nama: name,
      deskripsi: '',
      olahraga: category,
      thumbnail: imageUrl,
      rating: 0.0,
      refund: false,
      tarifPerSesi: 'N/A',
      kontak: null,
      alamat: null,
      kecamatan: null,
      review: null,
      peraturan: null,
      fasilitas: null,
    );
  }
}