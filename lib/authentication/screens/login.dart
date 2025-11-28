import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:askmo/authentication/screens/register.dart';
import 'package:askmo/menu.dart';
import 'package:askmo/user_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF571E88),
          primary: const Color(0xFF571E88),
          secondary: const Color(0xFFA4E4FF),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '312722822760-ddcvk4fbt7sm7mefo8hb812lukfsb6ff.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithUsernamePassword(CookieRequest request) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final response = await request.login("http://localhost:8000/auth/login/", {
      'username': username,
      'password': password,
    });

    if (request.loggedIn) {
      final userState = context.read<UserState>();

      await userState.reload();
      await userState.setUsername(response['username']);

      final bool isStaff = response['is_staff'] ?? false;
      UserInfo.login(response['username'], isStaff);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF571E88),
            content: Text("Login berhasil!"),
          ),
        );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: const Color(0xFF571E88).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          title: Text(
            'Login Gagal',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Username atau kata sandi salah. Silakan coba lagi.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFFFFFF)),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF571E88),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    final request = context.read<CookieRequest>();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFFF5555),
            content: Text('Tidak ada token yang diterima dari Google'),
          ),
        );
        return;
      }

      final payload = {
        if (idToken != null) 'id_token': idToken,
        if (idToken == null && accessToken != null) 'access_token': accessToken,
        'mode': 'login',
      };

      final response = await request.postJson(
        "http://localhost:8000/auth/google-login/",
        jsonEncode(payload),
      );

      if (response['status'] == true) {
        final username = response['username'] ?? googleUser.email;
        final bool isStaff = response['is_staff'] ?? false;

        final userState = context.read<UserState>();
        await userState.reload();
        await userState.setUsername(username);

        UserInfo.login(username, isStaff);

        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF571E88),
              content: Text('Login dengan Google berhasil'),
            ),
          );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      } else {
        if (!mounted) return;
        final String errorMessage =
            response['error']?.toString() ?? 'Login dengan Google gagal';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF5555),
            content: Text(errorMessage),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFFF5555),
          content: Text('Terjadi kesalahan saat login dengan Google'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -150,
                      left: -150,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 700,
                          height: 700,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF571E88).withOpacity(0.7),
                                const Color(0xFF06005E).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -200,
                      right: -200,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 800,
                          height: 800,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF6F0732).withOpacity(0.7),
                                const Color(0xFF571E88).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 16.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                              Text(
                                'Selamat datang kembali di ASKMO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              TextField(
                                controller: _usernameController,
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  hintText: 'Masukkan username Anda',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF571E88),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              TextField(
                                controller: _passwordController,
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Kata Sandi',
                                  labelStyle: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  hintText: 'Masukkan kata sandi Anda',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF571E88),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF06005E),
                                      Color(0xFF571E88),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _loginWithUsernamePassword(request),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFFFFFF),
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                  ),
                                  child: const Text('Masuk'),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'atau',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                  onPressed: _loginWithGoogle,
                                  icon: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/auth-icon/google.png',
                                        width: 18,
                                        height: 18,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    'Masuk dengan Google',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFFFFFFF),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36.0),
                              const _RegisterLink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterLink extends StatefulWidget {
  const _RegisterLink();

  @override
  State<_RegisterLink> createState() => _RegisterLinkState();
}

class _RegisterLinkState extends State<_RegisterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        child: RichText(
          text: TextSpan(
            text: 'Belum punya akun? ',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFFFFFF),
              fontSize: 16.0,
            ),
            children: [
              TextSpan(
                text: 'Daftar akun di sini!',
                style: GoogleFonts.plusJakartaSans(
                  color: _isHovered
                      ? const Color.fromARGB(255, 110, 106, 114)
                      : const Color(0xFFA4E4FF),
                  fontSize: 16.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
