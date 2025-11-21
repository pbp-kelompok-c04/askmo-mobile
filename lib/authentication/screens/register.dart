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
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                              const SizedBox(height: 12.0),
                              TextField(
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
                                  onPressed: () async {
                                    String username = _usernameController.text
                                        .trim();
                                    String password1 = _passwordController.text
                                        .trim();
                                    String password2 =
                                        _confirmPasswordController.text.trim();

                                    // Validasi input
                                    if (username.isEmpty ||
                                        password1.isEmpty ||
                                        password2.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(
                                              0xFFFF5555,
                                            ),
                                            content: Text(
                                              'Semua field harus diisi!',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    color: const Color(
                                                      0xFFFFFFFF,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    if (password1 != password2) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(
                                              0xFFFF5555,
                                            ),
                                            content: Text(
                                              'Kata sandi tidak cocok!',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    color: const Color(
                                                      0xFFFFFFFF,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    try {
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
                                        if (response['status'] == 'success' ||
                                            response['status'] == true) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(
                                                0xFF571E88,
                                              ),
                                              content: Text(
                                                'Berhasil mendaftar! Silakan login.',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: const Color(
                                                        0xFFFFFFFF,
                                                      ),
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
                                          String errorMessage =
                                              'Gagal mendaftar!';

                                          if (response['errors'] != null) {
                                            // Handle error dictionary
                                            if (response['errors'] is Map) {
                                              Map<String, dynamic> errors =
                                                  response['errors'];
                                              List<String> indonesianErrors =
                                                  [];

                                              errors.forEach((key, value) {
                                                if (value is List) {
                                                  for (var error in value) {
                                                    String errorText = error
                                                        .toString();
                                                    // Translate common Django validation errors
                                                    if (errorText.contains(
                                                      'already exists',
                                                    )) {
                                                      indonesianErrors.add(
                                                        'Username sudah digunakan',
                                                      );
                                                    } else if (errorText
                                                            .contains(
                                                              'too short',
                                                            ) ||
                                                        errorText.contains(
                                                          'at least 8 characters',
                                                        ) ||
                                                        errorText.contains(
                                                          'must be at least',
                                                        )) {
                                                      indonesianErrors.add(
                                                        'Kata sandi harus minimal 8 karakter',
                                                      );
                                                    } else if (errorText
                                                        .contains(
                                                          'too common',
                                                        )) {
                                                      indonesianErrors.add(
                                                        'Kata sandi terlalu umum',
                                                      );
                                                    } else if (errorText
                                                        .contains(
                                                          'entirely numeric',
                                                        )) {
                                                      indonesianErrors.add(
                                                        'Kata sandi tidak boleh hanya angka',
                                                      );
                                                    } else if (errorText
                                                        .contains(
                                                          'similar to',
                                                        )) {
                                                      indonesianErrors.add(
                                                        'Kata sandi terlalu mirip dengan username',
                                                      );
                                                    } else if (errorText
                                                        .contains('required')) {
                                                      indonesianErrors.add(
                                                        'Field ini wajib diisi',
                                                      );
                                                    } else {
                                                      indonesianErrors.add(
                                                        errorText,
                                                      );
                                                    }
                                                  }
                                                } else {
                                                  String errorText = value
                                                      .toString();
                                                  if (errorText.contains(
                                                    'already exists',
                                                  )) {
                                                    indonesianErrors.add(
                                                      'Username sudah digunakan',
                                                    );
                                                  } else if (errorText.contains(
                                                        'too short',
                                                      ) ||
                                                      errorText.contains(
                                                        'at least 8 characters',
                                                      ) ||
                                                      errorText.contains(
                                                        'must be at least',
                                                      )) {
                                                    indonesianErrors.add(
                                                      'Kata sandi harus minimal 8 karakter',
                                                    );
                                                  } else if (errorText.contains(
                                                    'too common',
                                                  )) {
                                                    indonesianErrors.add(
                                                      'Kata sandi terlalu umum',
                                                    );
                                                  } else if (errorText.contains(
                                                    'entirely numeric',
                                                  )) {
                                                    indonesianErrors.add(
                                                      'Kata sandi tidak boleh hanya angka',
                                                    );
                                                  } else if (errorText.contains(
                                                    'similar to',
                                                  )) {
                                                    indonesianErrors.add(
                                                      'Kata sandi terlalu mirip dengan username',
                                                    );
                                                  } else if (errorText.contains(
                                                    'required',
                                                  )) {
                                                    indonesianErrors.add(
                                                      'Field ini wajib diisi',
                                                    );
                                                  } else {
                                                    indonesianErrors.add(
                                                      errorText,
                                                    );
                                                  }
                                                }
                                              });

                                              if (indonesianErrors.isNotEmpty) {
                                                errorMessage = indonesianErrors
                                                    .join('\n');
                                              }
                                            } else if (response['errors']
                                                is String) {
                                              String errorText =
                                                  response['errors'];
                                              if (errorText.contains(
                                                'already exists',
                                              )) {
                                                errorMessage =
                                                    'Username sudah digunakan';
                                              } else if (errorText.contains(
                                                    'too short',
                                                  ) ||
                                                  errorText.contains(
                                                    'at least 8 characters',
                                                  ) ||
                                                  errorText.contains(
                                                    'must be at least',
                                                  )) {
                                                errorMessage =
                                                    'Kata sandi harus minimal 8 karakter';
                                              } else if (errorText.contains(
                                                'too common',
                                              )) {
                                                errorMessage =
                                                    'Kata sandi terlalu umum';
                                              } else if (errorText.contains(
                                                'entirely numeric',
                                              )) {
                                                errorMessage =
                                                    'Kata sandi tidak boleh hanya angka';
                                              } else if (errorText.contains(
                                                'similar to',
                                              )) {
                                                errorMessage =
                                                    'Kata sandi terlalu mirip dengan username';
                                              } else {
                                                errorMessage = errorText;
                                              }
                                            }
                                          } else if (response['message'] !=
                                              null) {
                                            String msgText =
                                                response['message'];
                                            if (msgText.contains(
                                              'already exists',
                                            )) {
                                              errorMessage =
                                                  'Username sudah digunakan';
                                            } else if (msgText.contains(
                                                  'too short',
                                                ) ||
                                                msgText.contains(
                                                  'at least 8 characters',
                                                ) ||
                                                msgText.contains(
                                                  'must be at least',
                                                )) {
                                              errorMessage =
                                                  'Kata sandi harus minimal 8 karakter';
                                            } else if (msgText.contains(
                                              'too common',
                                            )) {
                                              errorMessage =
                                                  'Kata sandi terlalu umum';
                                            } else if (msgText.contains(
                                              'entirely numeric',
                                            )) {
                                              errorMessage =
                                                  'Kata sandi tidak boleh hanya angka';
                                            } else if (msgText.contains(
                                              'similar to',
                                            )) {
                                              errorMessage =
                                                  'Kata sandi terlalu mirip dengan username';
                                            } else {
                                              errorMessage = msgText;
                                            }
                                          }

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(
                                                0xFFFF5555,
                                              ),
                                              content: Text(
                                                errorMessage,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: const Color(
                                                        0xFFFFFFFF,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(
                                              0xFFFF5555,
                                            ),
                                            content: Text(
                                              'Terjadi kesalahan koneksi. Pastikan server Django berjalan di http://localhost:8000',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    color: const Color(
                                                      0xFFFFFFFF,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
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
                                  child: const Text('Daftar'),
                                ),
                              ),
                              const SizedBox(height: 36.0),
                              _LoginLink(),
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

class _LoginLink extends StatefulWidget {
  const _LoginLink();

  @override
  State<_LoginLink> createState() => _LoginLinkState();
}

class _LoginLinkState extends State<_LoginLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
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
