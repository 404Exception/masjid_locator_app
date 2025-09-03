abstract class Environment {
  static const String dev = 'development';
  static const String staging = 'staging';
  static const String prod = 'production';
}

class AppConfig {
  static String currentEnv = Environment.staging;
  
  static String get baseUrl {
    switch (currentEnv) {
      case Environment.dev:
        return 'http://192.168.1.4:5074/api';
      case Environment.staging:
        return 'https://masjid-locator-api.onrender.com/api';
      case Environment.prod:
        return 'https://api.yourdomain.com';
      default:
        return 'https://masjid-locator-api.onrender.com/api';
    }
  }
  
  static bool get isProduction => currentEnv == Environment.prod;
  static bool get isDevelopment => currentEnv == Environment.dev;
  static bool get isStaging => currentEnv == Environment.staging;
}