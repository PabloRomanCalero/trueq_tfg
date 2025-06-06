import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseTrueq{
  static const String passwordHost = "change-password";
  static const String mailConfirmHost = "confirm-email";
  static const String redirectPassword = "trueq://change-password";
  static const String redirectMailConfirm = "trueq://confirm-email";
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get serviceRole => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
}

class GoogleAuthKeys {
  static String get webClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get iosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
}

class OneSignalKeys {
  static String get appId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get restApiKey => dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';
}