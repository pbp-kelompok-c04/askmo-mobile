import 'dart:convert';

List<Coach> coachFromJson(String str) =>
    List<Coach>.from(json.decode(str).map((x) => Coach.fromJson(x)));

String coachToJson(List<Coach> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Coach {
  String model;
  int pk;
  Fields fields;

  Coach({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        model: json["model"] ?? "",
        pk: json["pk"] ?? 0,
        fields: Fields.fromJson(json["fields"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String name;
  String sportBranch;
  String location;
  String contact;
  String experience;
  String certifications;
  String serviceFee;
  String photo;

  Fields({
    required this.name,
    required this.sportBranch,
    required this.location,
    required this.contact,
    required this.experience,
    required this.certifications,
    required this.serviceFee,
    required this.photo,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"] ?? "",
        sportBranch: json["sport_branch"] ?? "",
        location: json["location"] ?? "",
        contact: json["contact"] ?? "",
        experience: json["experience"] ?? "",
        certifications: json["certifications"] ?? "",
        serviceFee: json["service_fee"] ?? "",
        photo: json["photo"] ?? "",
      );

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
