import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  static String get apiKey {
    const fromDartDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDartDefine.isNotEmpty) {
      return fromDartDefine;
    }

    final fromDotenv = dotenv.env['GEMINI_API_KEY'];
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }

    // Graceful fallback so UI can show a helpful message instead of crashing.
    return '';
  }
}
