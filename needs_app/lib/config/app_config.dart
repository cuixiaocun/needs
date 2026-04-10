import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // API Configuration - Read from .env
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;

  // App Information - Read from .env
  static String get appName => dotenv.env['APP_NAME'] ?? 'Needs';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  static const String appPackage = 'com.needs.app';

  // Payment Configuration - Read from .env
  static String get alipayAppId =>
      dotenv.env['ALIPAY_APP_ID'] ?? 'YOUR_ALIPAY_APPID';

  static const String alipaySandboxUrl =
      'https://openapi.alipaydev.com/gateway.do';

  static const String alipayProductionUrl =
      'https://openapi.alipay.com/gateway.do';

  // Environment Configuration - Read from .env
  static bool get isDevelopment =>
      (dotenv.env['IS_DEVELOPMENT'] ?? 'true').toLowerCase() == 'true';

  // Deepseek AI Configuration - Read from .env
  static String get deepseekApiKey =>
      dotenv.env['DEEPSEEK_API_KEY'] ?? 'YOUR_DEEPSEEK_API_KEY';

  static const String deepseekBaseUrl = 'https://api.deepseek.com/v1';

  // Storage Configuration - Read from .env
  static String get storageBoxName =>
      dotenv.env['STORAGE_BOX_NAME'] ?? 'needs_storage';

  // Features - Read from .env
  static bool get enablePayment =>
      (dotenv.env['ENABLE_PAYMENT'] ?? 'true').toLowerCase() == 'true';

  static bool get enableAiAssistant =>
      (dotenv.env['ENABLE_AI_ASSISTANT'] ?? 'true').toLowerCase() == 'true';

  static bool get enableImageUpload =>
      (dotenv.env['ENABLE_IMAGE_UPLOAD'] ?? 'true').toLowerCase() == 'true';

  // Logging
  static bool get enableLogging =>
      (dotenv.env['ENABLE_LOGGING'] ?? 'true').toLowerCase() == 'true';

  /// Get the appropriate API base URL based on environment
  static String get currentApiBaseUrl {
    return apiBaseUrl;
  }

  /// Get the appropriate Alipay URL based on environment
  static String get currentAlipayUrl {
    return isDevelopment ? alipaySandboxUrl : alipayProductionUrl;
  }

  /// Check if app is running in production
  static bool get inProduction => !isDevelopment;

  /// Check if app is running in development
  static bool get inDevelopment => isDevelopment;
}
