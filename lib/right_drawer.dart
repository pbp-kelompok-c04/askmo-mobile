import 'package:flutter/material.dart';
import 'package:askmo/menu.dart';
import 'package:askmo/authentication/screens/login.dart';
import 'package:askmo/profile/screens/profile.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RightDrawer extends StatelessWidget {
  final int currentIndex;

  const RightDrawer({super.key, this.currentIndex = 0});

  @override
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
            child: Column(
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
                      _HoverListTile(
                        icon: Icons.home_rounded,
                        title: 'Beranda',
                        isActive: currentIndex == 0,
                        onTap: currentIndex == 0
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MenuPage(),
                                  ),
                                );
                              },
                      ),
                      _HoverListTile(
                        icon: Icons.sports_soccer_rounded,
                        title: 'Lapangan',
                        isActive: currentIndex == 1,
                        onTap: currentIndex == 1
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MenuPage(initialIndex: 1),
                                  ),
                                );
                              },
                      ),
                      _HoverListTile(
                        icon: Icons.person_rounded,
                        title: 'Coach',
                        isActive: currentIndex == 2,
                        onTap: currentIndex == 2
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MenuPage(initialIndex: 2),
                                  ),
                                );
                              },
                      ),
                      _HoverListTile(
                        icon: Icons.event_rounded,
                        title: 'Event',
                        isActive: currentIndex == 3,
                        onTap: currentIndex == 3
                            ? null
                            : () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MenuPage(initialIndex: 3),
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
                _HoverListTile(
                  icon: Icons.account_circle_rounded,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                _HoverListTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () async {
                    final request = context.read<CookieRequest>();
                    final response = await request.logout(
                      "http://localhost:8000/auth/logout/",
                    );
                    String message = response["message"];
                    if (context.mounted) {
                      if (response['status']) {
                        String uname = response["username"];
                        // clear stored username on logout
                        final userState = context.read<UserState>();
                        userState.clear();
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
                            builder: (context) => const LoginPage(),
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
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isActive;

  const _HoverListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<_HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = const Color(0xFFA4E4FF);
    final Color hoverColor = const Color.fromARGB(255, 110, 106, 114);
    final Color defaultColor = const Color(0xFFFFFFFF);
    final Color iconDefaultColor = const Color(0xFFFFFFFF);

    Color textColor;
    Color iconColor;

    if (widget.isActive) {
      textColor = highlightColor;
      iconColor = highlightColor;
    } else if (_isHovered) {
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
