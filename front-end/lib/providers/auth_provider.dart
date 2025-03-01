import 'package:flutter/material.dart';
import 'package:image_gallery_frontend/models/user.dart';
import 'package:image_gallery_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_data');
      
      if (token != null) {
        final userData = await _apiService.getUserProfile(token);
        // Include the token in the user data
        _user = User.fromJson({
          ...Map<String, dynamic>.from(userData),
          'token': token  // Add this line
        });
      }
    } catch (e) {
      print('Auth initialization error: $e');
      await logout(); // Clear any invalid session data
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Register new user
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    dynamic profilePicture,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.registerUser(
        name: name,
        email: email,
        password: password,
        profilePicture: profilePicture,
      );
      
      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.token);
      print('User registered successfully. Token: ${_user!.token.substring(0, 20)}...');
      print('Profile picture present: ${_user!.profilePicture.isNotEmpty}');
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.loginUser(
        email: email,
        password: password,
      );
      
      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', _user!.token);
      print('User logged in successfully. Token: ${_user!.token.substring(0, 20)}...');
      print('Profile picture present: ${_user!.profilePicture.isNotEmpty}');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = null;
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get user profile
  Future<void> refreshUserProfile() async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = _user!.token; // Store the current token
      final userData = await _apiService.getUserProfile(token);
      // Include the token in the updated user data
      _user = User.fromJson({
        ...Map<String, dynamic>.from(userData),
        'token': token  // Add this line
      });
      print('Profile refreshed successfully');
      print('Token preserved: ${_user!.token.substring(0, 20)}...');
      print('Profile picture present: ${_user!.profilePicture.isNotEmpty}');
      print('Profile picture data: ${_user!.profilePicture.substring(0, 50)}...');
    } catch (e) {
      print('Profile refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Debug method to check current user state
  void debugPrintUserState() {
    print('\nCurrent User State:');
    print('Is logged in: $isLoggedIn');
    print('Is loading: $isLoading');
    print('Is initialized: $isInitialized');
    if (_user != null) {
      print('User ID: ${_user!.id}');
      print('User Name: ${_user!.name}');
      print('User Email: ${_user!.email}');
      print('Has profile picture: ${_user!.profilePicture.isNotEmpty}');
      if (_user!.profilePicture.isNotEmpty) {
        print('Profile picture data type: ${_user!.profilePicture.startsWith('data:') ? 'base64' : 'URL'}');
        print('Profile picture preview: ${_user!.profilePicture.substring(0, 50)}...');
      }
      print('Token preview: ${_user!.token.substring(0, 20)}...');
    } else {
      print('No user currently logged in');
    }
    print('');
  }
}