import 'package:flutter/material.dart';
import 'package:askmo/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:askmo/profile/models/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

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
        home: const LoginPage(),
      ),
    );
  }
}
