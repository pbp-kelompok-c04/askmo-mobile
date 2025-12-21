import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingItem {
  final String id;
  final String name;
  final String day;
  final String slot;
  final String paymentMethod;
  final String price;
  final String timestamp;
  final String imageUrl;
  final String olahraga;

  BookingItem({
    required this.id,
    required this.name,
    required this.day,
    required this.slot,
    required this.paymentMethod,
    required this.price,
    required this.timestamp,
    required this.imageUrl,
    required this.olahraga,
  });

  // Konversi objek ke bentuk JSON (Map)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'day': day,
    'slot': slot,
    'paymentMethod': paymentMethod,
    'price': price,
    'timestamp': timestamp,
    'imageUrl': imageUrl,
    'olahraga': olahraga,
  };

  // Membuat objek BookingItem dari JSON (Map)
  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
    id: json['id'],
    name: json['name'],
    day: json['day'],
    slot: json['slot'],
    paymentMethod: json['paymentMethod'],
    price: json['price'],
    timestamp: json['timestamp'],
    imageUrl: json['imageUrl'],
    olahraga: json['olahraga'],
  );
}


// State management untuk riwayat booking, menggunakan ChangeNotifier agar bisa di-observe oleh UI
class BookingHistoryState extends ChangeNotifier {
  List<BookingItem> _bookings = [];
  String _currentUsername = '';

  // Getter untuk mengambil list booking
  List<BookingItem> get bookings => _bookings;

  // Konstruktor
  BookingHistoryState() {
  }

  // Menambah item riwayat booking baru berdasarkan data yang diberikan
  void addHistoryItem({
    required String name,
    required String lapanganId,
    required String olahraga,
    required String date,
    required String paymentMethod,
    required String price,
    required String imageUrl,
  }) {
    final parts = date.split(', ');
    final dayPart = parts.first;
    final slotPart = parts.length > 1 ? parts.last : '';
    
    final newItem = BookingItem(
      id: lapanganId,
      name: name,
      day: dayPart,
      slot: slotPart,
      paymentMethod: paymentMethod,
      price: price,
      timestamp: DateTime.now().toIso8601String(),
      imageUrl: imageUrl,
      olahraga: olahraga,
    );
  addBooking(newItem);
  }

  // Mengatur username yang sedang aktif dan memuat data booking dari penyimpanan lokal
  Future<void> setUsername(String username) async {
    _currentUsername = username;
    await _load();
  }

  // Memuat data booking dari SharedPreferences berdasarkan username
  Future<void> _load() async {
    if (_currentUsername.isEmpty) {
      _bookings = [];
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = 'booking_history_$_currentUsername';
    final s = prefs.getString(key);
    if (s != null) {
      // Jika data ada, decode dari JSON ke list BookingItem
      final list = jsonDecode(s) as List<dynamic>;
      _bookings = list
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _bookings = [];
    }
    notifyListeners();
  }

  // Menyimpan data booking ke SharedPreferences
  Future<void> _save() async {
    if (_currentUsername.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'booking_history_$_currentUsername';
    await prefs.setString(
      key,
      jsonEncode(_bookings.map((e) => e.toJson()).toList()),
    );
  }

  // Menambah BookingItem ke list dan simpan ke storage
  Future<void> addBooking(BookingItem b) async {
    _bookings.insert(0, b);
    await _save();
    notifyListeners();
  }

  // Menghapus seluruh riwayat booking
  Future<void> clear() async {
    _bookings.clear();
    await _save();
    notifyListeners();
  }
}
