import 'dart:convert';
import 'dart:typed_data';

class GalleryImage {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String userId;
  final DateTime createdAt;

  GalleryImage({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  bool get isBase64Image => imageUrl.startsWith('data:');

  Uint8List? getImageBytes() {
    if (!isBase64Image) return null;
    try {
      final base64String = imageUrl.split(',')[1];
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  String? getImageMimeType() {
    if (!isBase64Image) return null;
    try {
      final mimeType = imageUrl.split(',')[0].split(':')[1].split(';')[0];
      return mimeType;
    } catch (e) {
      print('Error getting mime type: $e');
      return null;
    }
  }
}