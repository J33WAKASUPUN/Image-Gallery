import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_frontend/models/gallery_image.dart';
import 'package:image_gallery_frontend/models/user.dart';
import 'package:image_gallery_frontend/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  final Dio _dio = Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_data');
  }

  // Add authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Get DIO options with auth headers
  Future<Options> _getDioOptions() async {
    final token = await _getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
      },
    );
  }

  // Get user images
Future<List<GalleryImage>> getUserImages() async {
  try {
    final headers = await _getAuthHeaders();
    print('Fetching images from: ${Constants.baseUrl}/images');  // Debug log
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/images'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('Response status: ${response.statusCode}');  // Debug log
    print('Response body: ${response.body}');  // Debug log

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) {
        final image = GalleryImage.fromJson(json);
        print('Processed image URL: ${image.imageUrl}');  // Debug log
        return image;
      }).toList();
    } else {
      throw Exception('Failed to load images: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getUserImages: $e');  // Debug log
    throw Exception('Failed to load images: $e');
  }
}

  // Upload image
  Future<GalleryImage> uploadImage(
      XFile image, String title, String description) async {
    try {
      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
      });

      if (kIsWeb) {
        List<int> bytes = await image.readAsBytes();
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(
              bytes,
              filename: image.name,
            ),
          ),
        );
      } else {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              image.path,
              filename: image.name,
            ),
          ),
        );
      }

      final options = await _getDioOptions();
      final response = await _dio.post(
        '${Constants.baseUrl}/images',
        data: formData,
        options: options,
      );

      if (response.statusCode == 201) {
        return GalleryImage.fromJson(response.data);
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image
Future<void> deleteImage(String imageId) async {
  try {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication required. Please log in again.');
    }

    final response = await http.delete(
      Uri.parse('${Constants.baseUrl}/images/$imageId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to delete this image.');
    } else if (response.statusCode == 404) {
      throw Exception('Image not found. It may have been already deleted.');
    } else if (response.statusCode == 500) {
      throw Exception('Server error occurred. Please try again later.');
    } else {
      throw Exception('Failed to delete image: ${response.statusCode}');
    }
  } catch (e) {
    if (e is SocketException) {
      throw Exception('Network error. Please check your connection.');
    }
    rethrow;
  }
}

  // Register new user
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
    dynamic
        profilePicture, // Change type to dynamic to handle both File and XFile
  }) async {
    try {
      // Create form data for multipart request
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
      });

      // Add profile picture if available
      if (profilePicture != null) {
        if (kIsWeb) {
          // Handle web platform
          if (profilePicture is XFile) {
            List<int> bytes = await profilePicture.readAsBytes();
            formData.files.add(
              MapEntry(
                'profilePicture',
                MultipartFile.fromBytes(
                  bytes,
                  filename: profilePicture.name,
                ),
              ),
            );
          }
        } else {
          // Handle mobile platform
          if (profilePicture is File) {
            formData.files.add(
              MapEntry(
                'profilePicture',
                await MultipartFile.fromFile(
                  profilePicture.path,
                  filename: 'profile_pic.jpg',
                ),
              ),
            );
          }
        }
      }

      // Make API call
      final response = await _dio.post(
        Constants.baseUrl + Constants.usersEndpoint,
        data: formData,
      );

      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to register user: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Login user
  Future<User> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.baseUrl + Constants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to login: ${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(Constants.baseUrl + Constants.profileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to get profile: ${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
}
