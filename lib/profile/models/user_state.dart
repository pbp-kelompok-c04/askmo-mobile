import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  String _username = '';
  String _name = '';
  String _avatarPath = '';
  String _favoriteSport = '';
  int _userId = 0;
  bool _isLoaded = false;
  bool _isEmailLogin = false; // Track jika login dengan email

  String get username => _username;
  String get name => _name;
  String get avatarPath => _avatarPath;
  String get favoriteSport => _favoriteSport;
  int get userId => _userId;
  bool get isLoaded => _isLoaded;
  bool get isEmailLogin => _isEmailLogin;

  String get displayName => _name.isNotEmpty ? _name : _username;

  String _getPrefKey(String suffix) {
    if (_username.isEmpty) {
      return suffix;
    }
    return '${_username}_$suffix';
  }

  UserState() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    _isEmailLogin = prefs.getBool('${_username}_isEmailLogin') ?? false;

    if (_username.isNotEmpty) {
      _name = prefs.getString(_getPrefKey('name')) ?? '';
      _avatarPath = prefs.getString(_getPrefKey('avatarPath')) ?? '';
      _favoriteSport = prefs.getString(_getPrefKey('favoriteSport')) ?? '';
      _userId = prefs.getInt(_getPrefKey('userId')) ?? 0;

      // Jika name masih kosong dan login dengan email, set dari email
      if (_name.isEmpty && _isEmailLogin) {
        _name = _extractNameFromEmail(_username);
      }
    } else {
      _name = '';
      _avatarPath = '';
      _favoriteSport = '';
      _userId = 0;
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setBool('${_username}_isEmailLogin', _isEmailLogin);

    if (_username.isNotEmpty) {
      await prefs.setString(_getPrefKey('name'), _name);
      await prefs.setString(_getPrefKey('avatarPath'), _avatarPath);
      await prefs.setString(_getPrefKey('favoriteSport'), _favoriteSport);
      await prefs.setInt(_getPrefKey('userId'), _userId);
    }
  }

  // Extract nama dari email (sebelum @)
  String _extractNameFromEmail(String email) {
    if (!email.contains('@')) return email;
    String localPart = email.split('@')[0];
    // Capitalize first letter dan ganti _ atau . dengan spasi
    localPart = localPart.replaceAll(RegExp(r'[._]'), ' ');
    return localPart
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // === BAGIAN YANG DIPERBAIKI ADA DI SINI ===
  Future<void> setUsername(String uname) async {
    _username = uname;
    // Cek apakah username adalah email
    _isEmailLogin = uname.contains('@');

    // HAPUS BARIS INI: await _loadFromStorage();
    // Kenapa? Karena ini akan me-load data lama (kosong) dan menimpa 'uname' baru.

    // Sebagai gantinya, load atribut lain secara manual tanpa menimpa username:
    final prefs = await SharedPreferences.getInstance();
    if (_username.isNotEmpty) {
      _name = prefs.getString(_getPrefKey('name')) ?? '';
      _avatarPath = prefs.getString(_getPrefKey('avatarPath')) ?? '';
      _favoriteSport = prefs.getString(_getPrefKey('favoriteSport')) ?? '';
      // Jangan load userId disini jika akan di-set manual setelah ini
    }

    // Auto-set name dari email jika belum ada
    if (_isEmailLogin && _name.isEmpty) {
      _name = _extractNameFromEmail(uname);
    }

    await _saveToStorage(); // Simpan username BARU ke storage
    notifyListeners();
  }
  // ==========================================

  Future<void> setUserId(int id) async {
    _userId = id;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> setName(String newName) async {
    _name = newName;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> setAvatarPath(String path) async {
    _avatarPath = path;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> setFavoriteSport(String sportKey) async {
    _favoriteSport = sportKey;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> reload() async {
    await _loadFromStorage();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final oldUsername = _username;

    _username = '';
    _name = '';
    _avatarPath = '';
    _favoriteSport = '';
    _userId = 0;
    _isEmailLogin = false;

    await prefs.remove('username');

    if (oldUsername.isNotEmpty) {
      await prefs.remove('${oldUsername}_isEmailLogin');
      await prefs.remove('${oldUsername}_name');
      await prefs.remove('${oldUsername}_avatarPath');
      await prefs.remove('${oldUsername}_favoriteSport');
      await prefs.remove('${oldUsername}_userId');
    }

    notifyListeners();
  }
}
