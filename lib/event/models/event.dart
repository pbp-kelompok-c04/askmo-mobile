// To parse this JSON data, do
//
//     final eventEntry = eventEntryFromJson(jsonString);

import 'dart:convert';

EventEntry eventEntryFromJson(String str) =>
    EventEntry.fromJson(json.decode(str));

String eventEntryToJson(EventEntry data) => json.encode(data.toJson());

class EventEntry {
  List<Event> events;

  EventEntry({required this.events});

  factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
    events: List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "events": List<dynamic>.from(events.map((x) => x.toJson())),
  };
}

class Event {
  String id;
  String nama;
  String olahraga;
  String deskripsi;
  DateTime tanggal;
  String lokasi;
  String kontak;
  int biaya;
  String? thumbnail;
  dynamic jam;
  int userId;

  Event({
    required this.id,
    required this.nama,
    required this.olahraga,
    required this.deskripsi,
    required this.tanggal,
    required this.lokasi,
    required this.kontak,
    required this.biaya,
    required this.thumbnail,
    required this.jam,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json["id"],
    nama: json["nama"],
    olahraga: json["olahraga"],
    deskripsi: json["deskripsi"],
    tanggal: DateTime.parse(json["tanggal"]),
    lokasi: json["lokasi"],
    kontak: json["kontak"],
    biaya: json["biaya"],
    thumbnail: json["thumbnail"],
    jam: json["jam"],
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "olahraga": olahraga,
    "deskripsi": deskripsi,
    "tanggal":
        "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
    "lokasi": lokasi,
    "kontak": kontak,
    "biaya": biaya,
    "thumbnail": thumbnail,
    "jam": jam,
    "user_id": userId,
  };
}
