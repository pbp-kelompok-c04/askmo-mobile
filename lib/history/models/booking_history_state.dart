import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingItem {
  final String id; // lapangan id
  final String name;
  final String day;
  final String slot;
  final String paymentMethod;
  final String price;
  final String timestamp;
  final String imageUrl;

  BookingItem({
    required this.id,
    required this.name,
    required this.day,
    required this.slot,
    required this.paymentMethod,
    required this.price,
    required this.timestamp,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'day': day,
    'slot': slot,
    'paymentMethod': paymentMethod,
    'price': price,
    'timestamp': timestamp,
    'imageUrl': imageUrl,
  };

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
    id: json['id'],
    name: json['name'],
    day: json['day'],
    slot: json['slot'],
    paymentMethod: json['paymentMethod'],
    price: json['price'],
    timestamp: json['timestamp'],
    imageUrl: json['imageUrl'],
  );
}

class BookingHistoryState extends ChangeNotifier {
  List<BookingItem> _bookings = [];
  String _currentUsername = '';

  List<BookingItem> get bookings => _bookings;

  BookingHistoryState() {
    // Don't auto-load, wait for setUsername
  }

  Future<void> setUsername(String username) async {
    _currentUsername = username;
    await _load();
  }

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
      final list = jsonDecode(s) as List<dynamic>;
      _bookings = list
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _bookings = [];
    }
    notifyListeners();
  }

  Future<void> _save() async {
    if (_currentUsername.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'booking_history_$_currentUsername';
    await prefs.setString(
      key,
      jsonEncode(_bookings.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addBooking(BookingItem b) async {
    _bookings.insert(0, b); // newest first
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _bookings.clear();
    await _save();
    notifyListeners();
  }
}
