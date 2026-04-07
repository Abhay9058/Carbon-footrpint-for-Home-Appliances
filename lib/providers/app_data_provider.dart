import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/appliance_model.dart';
import '../models/usage_log_model.dart';
import '../models/analytics_model.dart';
import '../models/eco_tip_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../screens/gamification/achievements_screen.dart';

class AppDataProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  UserModel? _user;
  List<ApplianceModel> _appliances = [];
  List<UsageLogModel> _usageLogs = [];
  List<UsageLogModel> _recentActivity = [];
  AnalyticsModel? _analytics;
  List<EcoTipModel> _ecoTips = [];
  
  bool _isLoading = false;
  String? _error;

  AppDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  UserModel? get user => _user;
  List<ApplianceModel> get appliances => _appliances;
  List<UsageLogModel> get usageLogs => _usageLogs;
  List<UsageLogModel> get recentActivity => _recentActivity;
  AnalyticsModel? get analytics => _analytics;
  List<EcoTipModel> get ecoTips => _ecoTips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get userId => AppConstants.defaultUserId;

  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadUser(),
        loadAppliances(),
        loadAnalytics(),
        loadRecentActivity(),
        loadEcoTips(),
      ]);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    try {
      _user = await _apiService.getUser(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAppliances() async {
    try {
      _appliances = await _apiService.getAppliances(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUsageLogs() async {
    try {
      _usageLogs = await _apiService.getUsageLogs(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadRecentActivity() async {
    try {
      _recentActivity = await _apiService.getUsageLogs(userId, limit: 10);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAnalytics() async {
    try {
      _analytics = await _apiService.getAnalytics(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadEcoTips() async {
    try {
      _ecoTips = await _apiService.getEcoTips(limit: 5);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addAppliance(ApplianceCreate appliance) async {
    try {
      final newAppliance = await _apiService.createAppliance(userId, appliance);
      _appliances.add(newAppliance);
      notifyListeners();
      await loadAnalytics();
      _updateAchievements();
      return true;
    } catch (e) {
      debugPrint('Add appliance error: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAppliance(int applianceId) async {
    try {
      await _apiService.deleteAppliance(applianceId);
      _appliances.removeWhere((a) => a.id == applianceId);
      notifyListeners();
      await loadAnalytics();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> logUsage(UsageLogCreate log) async {
    try {
      final newLog = await _apiService.createUsageLog(userId, log);
      _usageLogs.insert(0, newLog);
      _recentActivity.insert(0, newLog);
      if (_recentActivity.length > 10) {
        _recentActivity.removeLast();
      }
      notifyListeners();
      await loadAnalytics();
      await loadUser();
      _updateAchievements();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  ApplianceModel? getApplianceById(int id) {
    try {
      return _appliances.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<double> calculateCarbonFootprint({
    required double electricity,
    required double transport,
    double diet = 0.0,
  }) async {
    try {
      return await _apiService.calculateCarbonFootprint(
        electricity: electricity,
        transport: transport,
        diet: diet,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _updateAchievements() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = AppConstants.appNavigatorKey.currentContext;
        if (context != null) {
          try {
            final achievementsProvider = Provider.of<AchievementsProvider>(
              context,
              listen: false,
            );
            achievementsProvider.checkAndUnlockAchievements(
              applianceCount: _appliances.length,
              logCount: _usageLogs.length,
              totalEmissionsSaved: _analytics?.totalCarbonEmissions ?? 0,
              currentStreak: _calculateStreak(),
            );
          } catch (e) {
            debugPrint('Error updating achievements: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Error updating achievements: $e');
    }
  }

  int _calculateStreak() {
    if (_recentActivity.isEmpty) return 0;
    
    final dates = _recentActivity.map((l) => l.date).toSet().toList()..sort();
    if (dates.isEmpty) return 0;
    
    int streak = 1;
    for (int i = dates.length - 1; i > 0; i--) {
      final current = DateTime.parse(dates[i]);
      final previous = DateTime.parse(dates[i - 1]);
      final difference = current.difference(previous).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
