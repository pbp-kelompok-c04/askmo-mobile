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

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'imageUrl': imageUrl,
    'location': location,
    'category': category,
  };

  factory WishedItem.fromJson(Map<String, dynamic> json) => WishedItem(
    id: json['id'],
    type: json['type'],
    name: json['name'],
    imageUrl: json['imageUrl'],
    location: json['location'],
    category: json['category'],
  );
}

class WishlistState extends ChangeNotifier {
  List<WishedItem> _wishedItems = [];

  List<WishedItem> get wishedItems => _wishedItems;

  WishlistState() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('wishlist');
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      _wishedItems = jsonList
          .map((item) => WishedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      _wishedItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('wishlist', jsonString);
  }

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

  Future<void> removeWish(String id) async {
    _wishedItems.removeWhere((item) => item.id == id);
    await _saveWishlist();
    notifyListeners();
  }

  bool isWished(String id, String type) {
    return _wishedItems.any((item) => item.id == id && item.type == type);
  }

  List<WishedItem> getWishedByType(String type) {
    return _wishedItems.where((item) => item.type == type).toList();
  }

  Future<void> clear() async {
    _wishedItems.clear();
    await _saveWishlist();
    notifyListeners();
  }
}
