import 'package:flutter/material.dart';
import 'package:image_gallery_frontend/providers/image_provider.dart';
import 'package:image_gallery_frontend/screens/image_viewer.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/base64_or_network_image.dart';
import '../widgets/image_upload_dialog.dart';

class GalleryScreen extends StatefulWidget {
  static const routeName = '/gallery';
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<GalleryProvider>(context, listen: false).fetchImages());
  }

  Future<void> _showUploadDialog() async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => const ImageUploadDialog(),
    );

    if (result != null && mounted) {
      try {
        await Provider.of<GalleryProvider>(context, listen: false).uploadImage(
          result['image'],
          result['title'],
          result['description'],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Image uploaded successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Provider.of<GalleryProvider>(context, listen: false).fetchImages();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No images yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first image',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Upload Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<dynamic> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return CustomCard(
          elevation: 4,
          padding: EdgeInsets.zero,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ImageViewerScreen(initialImageId: image.id),
            ),
          ),
          child: Hero(
            tag: 'image_${image.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Base64OrNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black87,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        image.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _showUploadDialog,
            tooltip: 'Upload Image',
          ),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (ctx, galleryProvider, _) {
          if (galleryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => galleryProvider.fetchImages(),
            child: galleryProvider.images.isEmpty
                ? _buildEmptyState()
                : _buildImageGrid(galleryProvider.images),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Image'),
        elevation: 4,
      ),
    );
  }
}