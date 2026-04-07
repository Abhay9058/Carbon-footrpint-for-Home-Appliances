import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/appliance_model.dart';
import '../models/usage_log_model.dart';
import '../models/analytics_model.dart';
import '../models/eco_tip_model.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final bool useMockData;

  ApiService({String? baseUrl, http.Client? client, this.useMockData = true})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<bool> checkServerConnection() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel> getUser(int userId) async {
    if (useMockData) {
      return _getMockUser(userId);
    }
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  UserModel _getMockUser(int userId) {
    return UserModel(
      id: userId,
      username: 'eco_warrior',
      role: 'user',
      memberSince: '2024-01-15',
      totalCarbonEmissions: 125.5,
      darkMode: false,
      ecoTipsNotifications: true,
    );
  }

  Future<UserModel> updateUser(int userId, Map<String, dynamic> updates) async {
    if (useMockData) {
      return _getMockUser(userId);
    }
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/user/$userId'),
        headers: await _getHeaders(),
        body: json.encode(updates),
      );
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  int _mockApplianceIdCounter = 4;
  final List<ApplianceModel> _mockAppliances = [];
  int _mockLogIdCounter = 1;
  final List<UsageLogModel> _mockUsageLogs = [];

  Future<List<ApplianceModel>> getAppliances(int userId) async {
    if (useMockData) {
      return _getMockAppliances(userId);
    }
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/appliances/$userId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ApplianceModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load appliances: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load appliances: $e');
    }
  }

  List<ApplianceModel> _getMockAppliances(int userId) {
    final baseAppliances = [
      ApplianceModel(
        id: 1,
        userId: userId,
        name: 'LED Bulb',
        applianceType: 'Lighting',
        wattage: 10,
        quantity: 5,
        createdAt: '2024-01-16T10:30:00',
      ),
      ApplianceModel(
        id: 2,
        userId: userId,
        name: 'Air Conditioner',
        applianceType: 'Cooling',
        wattage: 1500,
        quantity: 1,
        createdAt: '2024-01-17T14:20:00',
      ),
      ApplianceModel(
        id: 3,
        userId: userId,
        name: 'Refrigerator',
        applianceType: 'Kitchen',
        wattage: 150,
        quantity: 1,
        createdAt: '2024-01-18T09:15:00',
      ),
    ];
    return [...baseAppliances, ..._mockAppliances];
  }

  Future<ApplianceModel> createAppliance(int userId, ApplianceCreate appliance) async {
    if (useMockData) {
      final newAppliance = ApplianceModel(
        id: _mockApplianceIdCounter,
        userId: userId,
        name: appliance.name,
        applianceType: appliance.applianceType,
        wattage: appliance.wattage,
        quantity: appliance.quantity,
        createdAt: DateTime.now().toIso8601String(),
      );
      _mockAppliances.add(newAppliance);
      _mockApplianceIdCounter++;
      return newAppliance;
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/appliances/$userId'),
        headers: await _getHeaders(),
        body: json.encode(appliance.toJson()),
      );
      
      if (response.statusCode == 200) {
        return ApplianceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create appliance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create appliance: $e');
    }
  }

  Future<void> deleteAppliance(int applianceId) async {
    if (useMockData) {
      _mockAppliances.removeWhere((a) => a.id == applianceId);
      return;
    }
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/appliances/$applianceId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete appliance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete appliance: $e');
    }
  }

  Future<List<UsageLogModel>> getUsageLogs(int userId, {int? limit}) async {
    if (useMockData) {
      return _getMockUsageLogs(userId, limit: limit);
    }
    try {
      String url = '$baseUrl/usage/$userId';
      if (limit != null) {
        url += '?limit=$limit';
      }
      
      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => UsageLogModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load usage logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load usage logs: $e');
    }
  }

  List<UsageLogModel> _getMockUsageLogs(int userId, {int? limit}) {
    final now = DateTime.now();
    final logs = <UsageLogModel>[];
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      logs.add(UsageLogModel(
        id: i + 1,
        userId: userId,
        applianceId: (i % 3) + 1,
        hours: [6.0, 8.0, 24.0, 5.0, 10.0][i % 5],
        date: date.toIso8601String().split('T')[0],
        carbonEmission: [0.049, 9.84, 2.952, 0.041, 12.3][i % 5],
        createdAt: date.toIso8601String(),
      ));
    }
    
    logs.addAll(_mockUsageLogs);
    
    if (limit != null) {
      return logs.take(limit).toList();
    }
    return logs;
  }

  Future<UsageLogModel> createUsageLog(int userId, UsageLogCreate log) async {
    if (useMockData) {
      final emission = _calculateMockEmission(log.applianceId, log.hours);
      final newLog = UsageLogModel(
        id: _mockLogIdCounter,
        userId: userId,
        applianceId: log.applianceId,
        hours: log.hours,
        date: log.date,
        carbonEmission: emission,
        createdAt: DateTime.now().toIso8601String(),
      );
      _mockUsageLogs.add(newLog);
      _mockLogIdCounter++;
      return newLog;
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/usage/$userId'),
        headers: await _getHeaders(),
        body: json.encode(log.toJson()),
      );
      
      if (response.statusCode == 200) {
        return UsageLogModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create usage log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create usage log: $e');
    }
  }

  double _calculateMockEmission(int applianceId, double hours) {
    final wattages = {1: 10.0, 2: 1500.0, 3: 150.0};
    final wattage = wattages[applianceId] ?? 100.0;
    return (wattage * hours / 1000) * 0.82;
  }

  Future<AnalyticsModel> getAnalytics(int userId) async {
    if (useMockData) {
      return _getMockAnalytics(userId);
    }
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/analytics/$userId'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return AnalyticsModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load analytics: $e');
    }
  }

  AnalyticsModel _getMockAnalytics(int userId) {
    final now = DateTime.now();
    final dailyEmissions = <DailyEmission>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dailyEmissions.add(DailyEmission(
        date: date.toIso8601String().split('T')[0],
        emission: [12.3, 8.5, 15.2, 10.8, 9.1, 14.5, 11.2][6 - i],
      ));
    }
    
    return AnalyticsModel(
      dailyEmissions: dailyEmissions,
      weeklyTotal: 81.6,
      monthlyTotal: 325.5,
      yearlyTotal: 2450.0,
      monthlyEmissions: [
        WeeklyEmission(week: 'Week 1', emission: 85.2),
        WeeklyEmission(week: 'Week 2', emission: 92.1),
        WeeklyEmission(week: 'Week 3', emission: 78.4),
        WeeklyEmission(week: 'Week 4', emission: 69.8),
      ],
      emissionsByAppliance: [
        ApplianceEmission(name: 'Air Conditioner', type: 'Cooling', emission: 180.5, quantity: 1),
        ApplianceEmission(name: 'Refrigerator', type: 'Kitchen', emission: 42.8, quantity: 1),
        ApplianceEmission(name: 'LED Bulb', type: 'Lighting', emission: 2.5, quantity: 5),
      ],
      topAppliances: [
        ApplianceEmission(name: 'Air Conditioner', type: 'Cooling', emission: 180.5, quantity: 1),
        ApplianceEmission(name: 'Refrigerator', type: 'Kitchen', emission: 42.8, quantity: 1),
        ApplianceEmission(name: 'LED Bulb', type: 'Lighting', emission: 2.5, quantity: 5),
      ],
      highestEmissionAppliance: ApplianceEmission(name: 'Air Conditioner', type: 'Cooling', emission: 180.5, quantity: 1),
      todayEmission: 11.2,
      dailyAverage: 11.66,
      totalCarbonEmissions: 2450.0,
    );
  }

  Future<List<EcoTipModel>> getEcoTips({int limit = 5}) async {
    if (useMockData) {
      return _getMockEcoTips(limit);
    }
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/analytics/tips/list?limit=$limit'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => EcoTipModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load eco tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load eco tips: $e');
    }
  }

  List<EcoTipModel> _getMockEcoTips(int limit) {
    final allTips = [
      EcoTipModel(id: 1, title: 'Switch to LED', description: 'Replace incandescent bulbs with LED lights to save up to 75% energy.', category: 'Lighting'),
      EcoTipModel(id: 2, title: 'Optimal Temperature', description: 'Set AC to 24°C for optimal energy efficiency.', category: 'Cooling'),
      EcoTipModel(id: 3, title: 'Unplug Idle Devices', description: 'Unplug chargers and devices when not in use to eliminate phantom energy consumption.', category: 'General'),
      EcoTipModel(id: 4, title: 'Use Natural Light', description: 'Maximize natural daylight to reduce artificial lighting needs.', category: 'Lighting'),
      EcoTipModel(id: 5, title: 'Energy Star Appliances', description: 'Choose Energy Star certified appliances for 10-50% less energy consumption.', category: 'General'),
      EcoTipModel(id: 6, title: 'Regular Maintenance', description: 'Clean AC filters monthly for better efficiency and lower emissions.', category: 'Cooling'),
      EcoTipModel(id: 7, title: 'Power Strip Strategy', description: 'Use power strips to easily switch off multiple devices at once.', category: 'General'),
      EcoTipModel(id: 8, title: 'Efficient Cooking', description: 'Use lids while cooking to reduce energy usage by up to 30%.', category: 'Kitchen'),
    ];
    return allTips.take(limit).toList();
  }

  Future<double> calculateCarbonFootprint({
    required double electricity,
    required double transport,
    double diet = 0.0,
  }) async {
    if (useMockData) {
      return (electricity * 0.5) + (transport * 0.2) + (diet * 0.3);
    }
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/calculate'),
        headers: await _getHeaders(),
        body: json.encode({
          'electricity': electricity,
          'transport': transport,
          'diet': diet,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['carbon_footprint'] as double;
      } else {
        throw Exception('Failed to calculate carbon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to calculate carbon: $e');
    }
  }
}
