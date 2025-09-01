import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration for Becomap Flutter SDK
///
/// This class manages configuration values loaded from environment variables
/// using flutter_dotenv. Values are loaded from .env file in development
/// and from environment variables in production.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// Initialize the configuration by loading the .env file
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  /// Client ID for Becomap API authentication
  /// Loaded from BECOMAP_CLIENT_ID environment variable
  static String get clientId {
    return dotenv.env['BECOMAP_CLIENT_ID'] ??
        (throw Exception('BECOMAP_CLIENT_ID not found in environment'));
  }

  /// Client secret for Becomap API authentication
  /// Loaded from BECOMAP_CLIENT_SECRET environment variable
  static String get clientSecret {
    return dotenv.env['BECOMAP_CLIENT_SECRET'] ??
        (throw Exception('BECOMAP_CLIENT_SECRET not found in environment'));
  }

  /// Site identifier for Becomap
  /// Loaded from BECOMAP_SITE_IDENTIFIER environment variable
  static String get siteIdentifier {
    return dotenv.env['BECOMAP_SITE_IDENTIFIER'] ??
        (throw Exception('BECOMAP_SITE_IDENTIFIER not found in environment'));
  }

  /// Validates that all required configuration values are present
  static bool validateConfig() {
    try {
      final id = clientId;
      final secret = clientSecret;
      final site = siteIdentifier;

      return id.isNotEmpty && secret.isNotEmpty && site.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
