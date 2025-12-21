import 'package:askmo/history/models/booking_history_state.dart';
import 'package:flutter/material.dart';
import 'package:askmo/menu.dart';
import 'package:askmo/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:askmo/wishlist/models/wishlist_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:askmo/config/api_base.dart';

// Fungsi utama aplikasi
void main() async {
  // Inisialisasi Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari file .env (khusus development)
  if (!kReleaseMode && !kIsWeb) {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e, st) {
      debugPrint('Gagal load .env: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);
  // Jalankan aplikasi utama
  runApp(const MyApp());
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    // Setup providers untuk state management (Provider, ChangeNotifier)
    return MultiProvider(
      providers: [
        // Provider untuk request ke backend (autentikasi)
        Provider<CookieRequest>(create: (_) => CookieRequest()),
        // Provider untuk state user
        ChangeNotifierProvider<UserState>(create: (_) => UserState()),
        // Provider untuk state wishlist
        ChangeNotifierProvider<WishlistState>(create: (_) => WishlistState()),
        // Provider untuk state riwayat booking
        ChangeNotifierProvider<BookingHistoryState>(
          create: (_) => BookingHistoryState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ASKMO',
        // Tema aplikasi
        theme: base.copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            titleTextStyle: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: const Color(0xFF571E88),
            primary: const Color(0xFF571E88),
            secondary: const Color(0xFFA4E4FF),
          ),
        ),
        home: const FirstLaunchWrapper(),
      ),
    );
  }
}

class FirstLaunchWrapper extends StatefulWidget {
  const FirstLaunchWrapper({super.key});

  @override
  State<FirstLaunchWrapper> createState() => _FirstLaunchWrapperState();
}

class _FirstLaunchWrapperState extends State<FirstLaunchWrapper> {
  // Status apakah aplikasi baru pertama kali dibuka
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched') ?? false;

    // Logout otomatis saat pertama kali buka aplikasi
    try {
      if (!hasLaunched) {
        final request = context.read<CookieRequest>();
        await request.logout('$apiBase/auth/logout/');
      }
    } catch (e, st) {
      debugPrint('Logout failed: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      if (!mounted) return;
      setState(() {
        _isFirstLaunch = !hasLaunched;
        _isLoading = false;
      });
    }
  }

  // Tandai aplikasi sudah pernah dibuka
  void _markAsLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched', true);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading saat cek first launch
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF571E88)),
        ),
      );
    }

    // Tampilkan login dengan skip jika pertama kali
    if (_isFirstLaunch) {
      return LoginPageWithSkip(onSkip: _markAsLaunched);
    } else {
      return const MenuPage();
    }
  }
}

// Widget login dengan tombol skip di pojok kanan atas (khusus first launch)
class LoginPageWithSkip extends StatelessWidget {
  final VoidCallback? onSkip;

  const LoginPageWithSkip({super.key, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Halaman login utama
          const LoginPage(),
          // Tombol skip di pojok kanan atas
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                onSkip?.call();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              child: Text(
                'Skip',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
