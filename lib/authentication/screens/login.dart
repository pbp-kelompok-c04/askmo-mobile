import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:askmo/authentication/screens/register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

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
                              ElevatedButton(
                                onPressed: () async {
                                  String username = _usernameController.text;
                                  String password = _passwordController.text;

                                  // Untuk Android emulator gunakan http://10.0.2.2/
                                  // Untuk Chrome gunakan http://localhost:8000
                                  final response = await request.login(
                                    "http://localhost:8000/auth/login/",
                                    {
                                      'username': username,
                                      'password': password,
                                    },
                                  );

                                  if (request.loggedIn) {
                                    String uname = response['username'];
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(
                                              0xFF571E88,
                                            ),
                                            content: Text(
                                              "Selamat datang, $uname!",
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
                                  } else {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: const Color(
                                            0xFF1E1E1E,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            side: BorderSide(
                                              color: const Color(
                                                0xFF571E88,
                                              ).withOpacity(0.5),
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
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFFFFFFFF),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFF571E88,
                                                ),
                                              ),
                                              child: Text(
                                                'OK',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
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
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: const Color(0xFF571E88),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                ),
                                child: const Text('Masuk'),
                              ),
                              const SizedBox(height: 36.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
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
                                        text: 'Daftar akun disini!',
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
