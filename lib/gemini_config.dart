// Import package untuk membaca environment variable dari file .env
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Kelas konfigurasi untuk API Gemini
class GeminiConfig {
  static String get apiKey {
    // Ambil dari dart-define jika ada
    const fromDartDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDartDefine.isNotEmpty) {
      return fromDartDefine;
    }

    // Ambil dari file .env jika ada
    final fromDotenv = dotenv.env['GEMINI_API_KEY'];
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }

    // Jika tidak ditemukan, kembalikan string kosong
    return '';
  }
}
