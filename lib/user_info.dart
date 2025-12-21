class UserInfo {
  static bool isLoggedIn = false;
  static bool isAdmin = false;
  static String username = "";
  
  // Method untuk login, set status dan username
  static void login(String user, bool admin) {
    isLoggedIn = true;
    username = user;
    isAdmin = admin;
  }

  // Method untuk logout, reset semua status
  static void logout() {
    isLoggedIn = false;
    isAdmin = false;
    username = "";
  }
}