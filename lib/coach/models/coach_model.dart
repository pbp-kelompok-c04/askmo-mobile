// Model data untuk pelatih (Coach)
// Berisi fungsi konversi dari/ke JSON dan kelas Coach serta Fields
import 'dart:convert';

// Fungsi untuk mengubah string JSON menjadi list objek Coach
List<Coach> coachFromJson(String str) =>
    List<Coach>.from(json.decode(str).map((x) => Coach.fromJson(x)));

// Fungsi untuk mengubah list objek Coach menjadi string JSON
String coachToJson(List<Coach> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Class utama Coach, merepresentasikan satu pelatih
class Coach {
  String model; // Nama model (biasanya dari backend)
  int pk; // Primary key/id
  Fields fields; // Data detail pelatih

  Coach({required this.model, required this.pk, required this.fields});

  // Membuat objek Coach dari JSON
  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
    model: json["model"],
    pk: json["pk"],
    fields: Fields.fromJson(json["fields"]),
  );

  // Mengubah objek Coach ke bentuk JSON
  Map<String, dynamic> toJson() => {
    "model": model,
    "pk": pk,
    "fields": fields.toJson(),
  };
}

// Kelas Fields berisi detail data pelatih
class Fields {
  String name; // Nama pelatih
  String sportBranch; // Cabang olahraga
  String location; // Lokasi pelatih
  String contact; // Kontak pelatih
  String experience; // Pengalaman
  String certifications; // Sertifikasi
  String serviceFee; // Biaya jasa
  String? photo; // Foto pelatih (opsional)

  Fields({
    required this.name,
    required this.sportBranch,
    required this.location,
    required this.contact,
    required this.experience,
    required this.certifications,
    required this.serviceFee,
    this.photo,
  });

  // Membuat objek Fields dari JSON
  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    name: json["name"] ?? "",
    sportBranch: json["sport_branch"] ?? "",
    location: json["location"] ?? "",
    contact: json["contact"] ?? "",
    experience: json["experience"] ?? "",
    certifications: json["certifications"] ?? "",
    serviceFee: json["service_fee"] ?? "",
    photo: json["photo"],
  );

  // Mengubah objek Fields ke bentuk JSON
  Map<String, dynamic> toJson() => {
    "name": name,
    "sport_branch": sportBranch,
    "location": location,
    "contact": contact,
    "experience": experience,
    "certifications": certifications,
    "service_fee": serviceFee,
    "photo": photo,
  };
}
