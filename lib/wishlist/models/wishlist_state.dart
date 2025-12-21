// Import package yang diperlukan
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishedItem {
  final String id;
  final String type;
  final String name;
  final String imageUrl;
  final String location;
  final String category;

  WishedItem({
    required this.id,
    required this.type,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.location,
  });


  // Konversi objek ke bentuk JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'imageUrl': imageUrl,
    'location': location,
    'category': category,
  };

  // Membuat objek dari JSON
  factory WishedItem.fromJson(Map<String, dynamic> json) => WishedItem(
    id: json['id'],
    type: json['type'],
    name: json['name'],
    imageUrl: json['imageUrl'],
    location: json['location'],
    category: json['category'],
  );
}


// State management untuk wishlist
class WishlistState extends ChangeNotifier {
  List<WishedItem> _wishedItems = [];
  String _currentUsername = '';

  List<WishedItem> get wishedItems => _wishedItems;


  // Konstruktor
  WishlistState() {
  }

  Future<void> setUsername(String username) async {
    _currentUsername = username;
    await _loadWishlist();
  }

  // Memuat wishlist dari SharedPreferences
  Future<void> _loadWishlist() async {
    if (_currentUsername.isEmpty) {
      _wishedItems = [];
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = 'wishlist_$_currentUsername';
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      _wishedItems = jsonList
          .map((item) => WishedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      _wishedItems = [];
    }
    notifyListeners();
  }

  // Menyimpan wishlist ke SharedPreferences
  Future<void> _saveWishlist() async {
    if (_currentUsername.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'wishlist_$_currentUsername';
    final jsonString = jsonEncode(
      _wishedItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(key, jsonString);
  }

  // Menambah atau menghapus item dari wishlist (toggle)
  Future<void> toggleWish({
    required String id,
    required String type,
    required String name,
    required String location,
    required String imageUrl,
    required String category,
  }) async {
    final index = _wishedItems.indexWhere(
      (item) => item.id == id && item.type == type,
    );

    if (index >= 0) {
      _wishedItems.removeAt(index);
    } else {
      _wishedItems.add(
        WishedItem(
          id: id,
          type: type,
          name: name,
          location: location,
          imageUrl: imageUrl,
          category: category,
        ),
      );
    }

    await _saveWishlist();
    notifyListeners();
  }

  // Menghapus item dari wishlist berdasarkan id
  Future<void> removeWish(String id) async {
    _wishedItems.removeWhere((item) => item.id == id);
    await _saveWishlist();
    notifyListeners();
  }

  // Mengecek apakah item sudah ada di wishlist
  bool isWished(String id, String type) {
    return _wishedItems.any((item) => item.id == id && item.type == type);
  }

  // Mengambil daftar item wishlist berdasarkan tipe
  List<WishedItem> getWishedByType(String type) {
    return _wishedItems.where((item) => item.type == type).toList();
  }

  // Menghapus semua item dari wishlist
  Future<void> clear() async {
    _wishedItems.clear();
    await _saveWishlist();
    notifyListeners();
  }
}
