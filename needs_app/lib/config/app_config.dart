class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const int apiTimeout = 30;

  // App Information
  static const String appName = 'Needs';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.needs.app';

  // Payment Configuration
  static const String alipayAppId = 'YOUR_ALIPAY_APPID';
  static const String alipaySandboxUrl = 'https://openapi.alipaydev.com/gateway.do';
  static const String alipayProductionUrl = 'https://openapi.alipay.com/gateway.do';

  // Environment Configuration
  static const bool isDevelopment = true;
  static const bool isProduction = false;
  static const bool enableLogging = true;

  // Deepseek AI Configuration
  static const String deepseekApiKey = 'YOUR_DEEPSEEK_API_KEY';
  static const String deepseekBaseUrl = 'https://api.deepseek.com/v1';

  // Storage Configuration
  static const String storageBoxName = 'needs_storage';

  // Features
  static const bool enablePayment = true;
  static const bool enableAiAssistant = true;
  static const bool enableImageUpload = true;

  /// Get the appropriate API base URL based on environment
  static String get currentApiBaseUrl {
    return isDevelopment ? apiBaseUrl : apiBaseUrl;
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
