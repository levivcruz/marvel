import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl = 'https://gateway.marvel.com/v1/public';

  static const String charactersEndpoint = '/characters';

  static String get publicKey =>
      dotenv.env['MARVEL_PUBLIC_KEY'] ??
      const String.fromEnvironment('MARVEL_PUBLIC_KEY');

  static String get privateKey =>
      dotenv.env['MARVEL_PRIVATE_KEY'] ??
      const String.fromEnvironment('MARVEL_PRIVATE_KEY');
}
