import 'package:flutter/foundation.dart';

class Constants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://192.168.1.159:5000/api';  // Your computer's IP address
    }
  }
  
  // Auth endpoints
  static const String usersEndpoint = '/users';
  static const String loginEndpoint = '/users/login';
  static const String profileEndpoint = '/users/profile';
  
  // Image endpoints
  static const String imagesEndpoint = '/images';

  // Helper methods for URLs
  static String getFullImageUrl(String path) {
    if (path.startsWith('data:image')) {
      return path; // Already a base64 image
    }
    if (path.startsWith('http')) {
      return path; // Already a full URL
    }
    return '$baseUrl/${path.startsWith('/') ? path.substring(1) : path}';
  }
}