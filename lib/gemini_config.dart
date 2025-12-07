import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  static String get apiKey {
    // 1. Coba ambil dari --dart-define (CI/CD)
    const fromDartDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDartDefine.isNotEmpty) {
      return fromDartDefine;
    }

    // 2. Fallback ke .env (development lokal)
    final fromDotenv = dotenv.env['GEMINI_API_KEY'];
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }

    // 3. Kalau dua-duanya kosong → error, tapi jangan pernah di-commit key-nya di sini
    throw StateError('GEMINI_API_KEY not found. '
        'Pastikan .env terisi (lokal) atau --dart-define di CI.');
  }
}
