import 'package:askmo/config/api_base.dart';
import 'package:flutter/material.dart';
import 'package:askmo/menu.dart';
import 'package:askmo/authentication/screens/login.dart';
import 'package:askmo/profile/screens/profile.dart';
import 'package:askmo/about/screens/about.dart';
import 'package:askmo/chatbot/screens/gemini_chat_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RightDrawer extends StatelessWidget {
  final int currentIndex;

  // Konstruktor dengan index halaman aktif
  const RightDrawer({super.key, this.currentIndex = 0});

  @override
  // Build UI right drawer
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
            ),
            // Menggunakan Consumer untuk mendapatkan state user (login/logout)
            child: Consumer<UserState>(
              builder: (context, userState, child) {
                // Cek apakah user sudah login
                final isLoggedIn = userState.username.isNotEmpty;

                // Daftar menu navigasi
                return Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'ASKMO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Menu Profile hanya muncul jika sudah login
                          if (isLoggedIn)
                            _HoverListTile(
                              icon: Icons.account_circle_rounded,
                              title: 'Profile',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                            ),
                          // Menu Tanya ASKMO (chatbot)
                          _HoverListTile(
                            icon: Icons.psychology_alt_rounded,
                            title: 'Tanya ASKMO',
                            onTap: () {
                              Navigator.pop(context);
                              if (!isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(
                                      returnRoute: const GeminiChatScreen(),
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GeminiChatScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                          // Menu About Us
                          _HoverListTile(
                            icon: Icons.info_rounded,
                            title: 'About Us',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // Tombol Logout jika sudah login, Login jika belum
                    if (isLoggedIn)
                      _HoverListTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        onTap: () async {
                          final request = context.read<CookieRequest>();
                          final response =
                              await request.logout("$apiBase/auth/logout/");
                          String message = response["message"];
                          if (context.mounted) {
                            if (response['status']) {
                              String uname = response["username"];
                              final userState = context.read<UserState>();
                              await userState.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF571E88),
                                  content: Text(
                                    "Berhasil logout! Sampai jumpa, $uname.",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MenuPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFFF5555),
                                  content: Text(
                                    message,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      )
                    else
                      _HoverListTile(
                        icon: Icons.login_rounded,
                        title: 'Login',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Widget ListTile dengan efek hover (untuk menu drawer)
class _HoverListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _HoverListTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_HoverListTile> createState() => _HoverListTileState();
}

// State untuk efek hover pada ListTile
class _HoverListTileState extends State<_HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverColor = const Color.fromARGB(255, 110, 106, 114);
    final Color defaultColor = const Color(0xFFFFFFFF);
    final Color iconDefaultColor = const Color(0xFFFFFFFF);

    Color textColor;
    Color iconColor;

    if (_isHovered) {
      textColor = hoverColor;
      iconColor = hoverColor;
    } else {
      textColor = defaultColor;
      iconColor = iconDefaultColor;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ListTile(
        leading: Icon(widget.icon, color: iconColor, size: 28),
        title: Text(
          widget.title,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: widget.onTap,
        enabled: widget.onTap != null,
      ),
    );
  }
}
