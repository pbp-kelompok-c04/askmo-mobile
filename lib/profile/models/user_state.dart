import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  String _username = '';
  String _name = '';
  String _avatarPath = '';
  String _favoriteSport = '';
  bool _isLoaded = false;

  String get username => _username;
  String get name => _name;
  String get avatarPath => _avatarPath;
  String get favoriteSport => _favoriteSport;
  bool get isLoaded => _isLoaded;

  // Display name: gunakan name jika ada, fallback ke username
  String get displayName => _name.isNotEmpty ? _name : _username;

  UserState() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    _name = prefs.getString('name') ?? '';
    _avatarPath = prefs.getString('avatarPath') ?? '';
    _favoriteSport = prefs.getString('favoriteSport') ?? '';
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setString('name', _name);
    await prefs.setString('avatarPath', _avatarPath);
    await prefs.setString('favoriteSport', _favoriteSport);
  }

  Future<void> setUsername(String uname) async {
    _username = uname;
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

  // Reload data dari storage (gunakan setelah login baru)
  Future<void> reload() async {
    await _loadFromStorage();
  }

  Future<void> clear() async {
    _username = '';
    _name = '';
    _avatarPath = '';
    _favoriteSport = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    notifyListeners();
  }
}
