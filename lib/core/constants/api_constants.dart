class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String apiVersion = '/';
  
  static const String getUser = '/user/{user_id}';
  static const String updateUser = '/user/{user_id}';
  static const String getAppliances = '/appliances/{user_id}';
  static const String createAppliance = '/appliances/{user_id}';
  static const String deleteAppliance = '/appliances/{appliance_id}';
  static const String getUsageLogs = '/usage/{user_id}';
  static const String createUsageLog = '/usage/{user_id}';
  static const String getAnalytics = '/analytics/{user_id}';
  static const String getEcoTips = '/analytics/tips/list';
  static const String healthCheck = '/health';
}

class AppConstants {
  static const int defaultUserId = 1;
  static const double emissionFactor = 0.82;
  static const String appName = 'Eco Warrior';
  static const String appTagline = 'Track Your Carbon Footprint';
}
