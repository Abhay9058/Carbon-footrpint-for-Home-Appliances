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

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<UserModel> getUser(int userId) async {
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

  Future<UserModel> updateUser(int userId, Map<String, dynamic> updates) async {
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

  Future<List<ApplianceModel>> getAppliances(int userId) async {
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

  Future<ApplianceModel> createAppliance(int userId, ApplianceCreate appliance) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/appliances/$userId'),
        headers: await _getHeaders(),
        body: json.encode(appliance.toJson()),
      );
      
      if (response.statusCode == 200) {
        return ApplianceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create appliance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create appliance: $e');
    }
  }

  Future<void> deleteAppliance(int applianceId) async {
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

  Future<UsageLogModel> createUsageLog(int userId, UsageLogCreate log) async {
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

  Future<AnalyticsModel> getAnalytics(int userId) async {
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

  Future<List<EcoTipModel>> getEcoTips({int limit = 5}) async {
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
}
