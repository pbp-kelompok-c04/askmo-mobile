import 'package:flutter/foundation.dart';

class UserState extends ChangeNotifier {
  String _username = '';
  String _name = '';
  String _avatarPath = ''; // asset path or data URI
  String _favoriteSport = '';

  String get username => _username;
  String get name => _name;
  String get avatarPath => _avatarPath;
  String get favoriteSport => _favoriteSport;

  void setUsername(String uname) {
    _username = uname;
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setAvatarPath(String path) {
    _avatarPath = path;
    notifyListeners();
  }

  void setFavoriteSport(String sportKey) {
    _favoriteSport = sportKey;
    notifyListeners();
  }

  void clear() {
    _username = '';
    _name = '';
    _avatarPath = '';
    _favoriteSport = '';
    notifyListeners();
  }
}
