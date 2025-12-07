import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:askmo/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile', 'openid'],
    clientId:
        '312722822760-ddcvk4fbt7sm7mefo8hb812lukfsb6ff.apps.googleusercontent.com',
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerManual(CookieRequest request) async {
    final username = _usernameController.text.trim();
    final password1 = _passwordController.text.trim();
    final password2 = _confirmPasswordController.text.trim();

    if (username.isEmpty || password1.isEmpty || password2.isEmpty) {
      _showError('Semua field harus diisi!');
      return;
    }

    if (password1 != password2) {
      _showError('Kata sandi tidak cocok!');
      return;
    }

    try {
      final response = await request.postJson(
        'http://localhost:8000/auth/register/',
        jsonEncode({
          'username': username,
          'password1': password1,
          'password2': password2,
        }),
      );

      if (!mounted) return;

      if (response['status'] == true || response['status'] == 'success') {
        _showSuccess('Berhasil mendaftar! Silakan login.');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        _handleRegisterError(response);
      }
    } catch (_) {
      _showError(
        'Terjadi kesalahan koneksi. Pastikan server Django berjalan di http://localhost:8000',
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    final request = context.read<CookieRequest>();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        _showError('Tidak ada token yang diterima dari Google');
        return;
      }

      final payload = <String, dynamic>{
        if (idToken != null) 'id_token': idToken,
        if (idToken == null && accessToken != null) 'access_token': accessToken,
        'mode': 'register',
      };

      final response = await request.postJson(
        'http://localhost:8000/auth/google-login/',
        jsonEncode(payload),
      );

      if (response['status'] == true) {
        final username = response['username'] ?? googleUser.email;
        _showSuccess(
          'Pendaftaran Google berhasil! Silakan login sebagai $username',
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        _showError(
          response['error']?.toString() ?? 'Pendaftaran dengan Google gagal',
        );
      }
    } catch (_) {
      _showError('Terjadi kesalahan saat daftar dengan Google.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFF5555),
        content: Text(
          msg,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF571E88),
        content: Text(
          msg,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
      ),
    );
  }

  void _handleRegisterError(Map<String, dynamic> response) {
    String msg = 'Gagal mendaftar!';

    if (response['errors'] != null) {
      if (response['errors'] is Map) {
        final Map<String, dynamic> errors = response['errors'];
        final List<String> list = [];

        errors.forEach((_, value) {
          if (value is List) {
            list.addAll(value.map((e) => e.toString()));
          } else {
            list.add(value.toString());
          }
        });

        msg = list.join('\n');
      } else {
        msg = response['errors'].toString();
      }
    } else if (response['message'] != null) {
      msg = response['message'].toString();
    }

    _showError(msg);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            _buildBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                child: _buildGlassForm(request),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
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
    );
  }

  Widget _buildCircle(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }

  Widget _buildGlassForm(CookieRequest request) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildTextFields(),
                  const SizedBox(height: 24),
                  _buildRegisterButton(request),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildGoogleButton(),
                  const SizedBox(height: 36),
                  const _LoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Daftar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Buat akun baru di ASKMO',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        _inputField('Username', _usernameController),
        const SizedBox(height: 12),
        _inputField('Kata Sandi', _passwordController, obscure: true),
        const SizedBox(height: 12),
        _inputField(
          'Konfirmasi Kata Sandi',
          _confirmPasswordController,
          obscure: true,
        ),
      ],
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: label,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF571E88)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildRegisterButton(CookieRequest request) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06005E), Color(0xFF571E88)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: () => _registerManual(request),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text('Daftar', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white30)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'atau',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.white30)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _registerWithGoogle,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white.withOpacity(0.1),
        ),
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
          'Daftar dengan Google',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
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
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.pop(context);
        },
        child: RichText(
          text: TextSpan(
            text: 'Sudah punya akun? ',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: 'Masuk di sini!',
                style: GoogleFonts.plusJakartaSans(
                  color: _isHovered
                      ? const Color.fromARGB(255, 110, 106, 114)
                      : const Color(0xFFA4E4FF),
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
