import 'package:flutter/foundation.dart';

class UserState extends ChangeNotifier {
  String _username = '';

  String get username => _username;

  void setUsername(String uname) {
    _username = uname;
    notifyListeners();
  }

  void clear() {
    _username = '';
    notifyListeners();
  }
}
