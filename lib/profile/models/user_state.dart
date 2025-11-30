import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  String _username = '';
  String _name = '';
  String _avatarPath = '';
  String _favoriteSport = '';
  bool _isLoaded = false;
  bool _isEmailLogin = false; // Track jika login dengan email

  String get username => _username;
  String get name => _name;
  String get avatarPath => _avatarPath;
  String get favoriteSport => _favoriteSport;
  bool get isLoaded => _isLoaded;
  bool get isEmailLogin => _isEmailLogin;

  // Display name: gunakan name jika ada, fallback ke username
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
      
      // Jika name masih kosong dan login dengan email, set dari email
      if (_name.isEmpty && _isEmailLogin) {
        _name = _extractNameFromEmail(_username);
      }
    } else {
      _name = '';
      _avatarPath = '';
      _favoriteSport = '';
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
    }
  }

  // Extract nama dari email (sebelum @)
  String _extractNameFromEmail(String email) {
    if (!email.contains('@')) return email;
    String localPart = email.split('@')[0];
    // Capitalize first letter dan ganti _ atau . dengan spasi
    localPart = localPart.replaceAll(RegExp(r'[._]'), ' ');
    return localPart.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> setUsername(String uname) async {
    _username = uname;
    // Cek apakah username adalah email
    _isEmailLogin = uname.contains('@');
    
    await _loadFromStorage();
    
    // Auto-set name dari email jika belum ada
    if (_isEmailLogin && _name.isEmpty) {
      _name = _extractNameFromEmail(uname);
    }
    
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
    _username = '';
    _name = '';
    _avatarPath = '';
    _favoriteSport = '';
    _isEmailLogin = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
 
    notifyListeners();
  }
}