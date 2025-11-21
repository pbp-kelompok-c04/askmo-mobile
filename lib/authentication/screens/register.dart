import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:askmo/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Animated aura effects
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // First aura - top left
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
                    // Second aura - bottom right
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
            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: const Color(0xFF571E88).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Daftar',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                              Text(
                                'Buat akun baru di ASKMO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.0,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              TextFormField(
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Masukkan username Anda';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              TextFormField(
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Masukkan kata sandi Anda';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: _confirmPasswordController,
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Konfirmasi Kata Sandi',
                                  labelStyle: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  hintText: 'Konfirmasi kata sandi Anda',
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi kata sandi Anda';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24.0),
                              ElevatedButton(
                                onPressed: () async {
                                  String username = _usernameController.text;
                                  String password1 = _passwordController.text;
                                  String password2 =
                                      _confirmPasswordController.text;

                                  // Untuk Android emulator gunakan http://10.0.2.2/
                                  // Untuk Chrome gunakan http://localhost:8000
                                  final response = await request.postJson(
                                    "http://localhost:8000/auth/register/",
                                    jsonEncode({
                                      "username": username,
                                      "password1": password1,
                                      "password2": password2,
                                    }),
                                  );
                                  if (context.mounted) {
                                    if (response['status'] == 'success') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(
                                            0xFF571E88,
                                          ),
                                          content: Text(
                                            'Berhasil mendaftar!',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFFFFFFFF),
                                            ),
                                          ),
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(
                                            0xFFFF5555,
                                          ),
                                          content: Text(
                                            'Gagal mendaftar!',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFFFFFFFF),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: const Color(0xFF571E88),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                ),
                                child: const Text('Daftar'),
                              ),
                              const SizedBox(height: 36.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Sudah punya akun? ',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFFFFFFF),
                                      fontSize: 16.0,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Masuk di sini!',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFA4E4FF),
                                          fontSize: 16.0,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
