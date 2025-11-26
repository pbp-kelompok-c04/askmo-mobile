class UserInfo {
  static bool isLoggedIn = false;
  static bool isAdmin = false;
  static String username = "";
  
  static void login(String user, bool admin) {
    isLoggedIn = true;
    username = user;
    isAdmin = admin;
  }

  static void logout() {
    isLoggedIn = false;
    isAdmin = false;
    username = "";
  }
}