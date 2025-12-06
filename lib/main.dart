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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    return MultiProvider(
      providers: [
        Provider<CookieRequest>(create: (_) => CookieRequest()),
        ChangeNotifierProvider<UserState>(create: (_) => UserState()),
        ChangeNotifierProvider<WishlistState>(create: (_) => WishlistState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ASKMO',
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

    setState(() {
      _isFirstLaunch = !hasLaunched;
      _isLoading = false;
    });

    if (!hasLaunched) {
      await prefs.setBool('has_launched', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF571E88)),
        ),
      );
    }

    return _isFirstLaunch ? const LoginPageWithSkip() : const MenuPage();
  }
}

class LoginPageWithSkip extends StatelessWidget {
  const LoginPageWithSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LoginPage(),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
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
