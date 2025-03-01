import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gallery_image.dart';
import '../services/api_service.dart';

class GalleryProvider with ChangeNotifier {
  final ApiService _apiService;
  List<GalleryImage> _images = [];
  bool _isLoading = false;

  GalleryProvider(this._apiService);

  List<GalleryImage> get images => [..._images];
  bool get isLoading => _isLoading;

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      _images = await _apiService.getUserImages();
      notifyListeners();
    } catch (e) {
      print('Error fetching images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadImage(XFile imageFile, String title, String description) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newImage = await _apiService.uploadImage(
        imageFile,
        title,
        description,
      );
      _images.insert(0, newImage);
      notifyListeners();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(String imageId) async {
    try {
      await _apiService.deleteImage(imageId);
      _images.removeWhere((img) => img.id == imageId);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('500')) {
        throw Exception('Server error occurred. Please try again later.');
      } else {
        throw Exception('Failed to delete image. Please check your connection and try again.');
      }
    }
  }
}