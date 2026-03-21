import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _darkMode = false;
  bool _ecoTipsNotifications = true;

  AuthProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get darkMode => _darkMode;
  bool get ecoTipsNotifications => _ecoTipsNotifications;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.getUser(AppConstants.defaultUserId);
      _darkMode = _user?.darkMode ?? false;
      _ecoTipsNotifications = _user?.ecoTipsNotifications ?? true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUsername(String username) async {
    try {
      _user = await _apiService.updateUser(
        AppConstants.defaultUserId,
        {'username': username},
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    notifyListeners();

    try {
      _user = await _apiService.updateUser(
        AppConstants.defaultUserId,
        {'dark_mode': _darkMode},
      );
    } catch (e) {
      _darkMode = !_darkMode;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleEcoTipsNotifications() async {
    _ecoTipsNotifications = !_ecoTipsNotifications;
    notifyListeners();

    try {
      _user = await _apiService.updateUser(
        AppConstants.defaultUserId,
        {'eco_tips_notifications': _ecoTipsNotifications},
      );
    } catch (e) {
      _ecoTipsNotifications = !_ecoTipsNotifications;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
