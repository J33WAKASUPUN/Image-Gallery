import 'package:flutter/material.dart';
import 'package:image_gallery_frontend/screens/image_viewer.dart';
import 'package:image_gallery_frontend/widgets/app_drawer.dart';
import 'package:image_gallery_frontend/widgets/image_upload_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/image_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/base64_or_network_image.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AuthProvider>(context, listen: false).refreshUserProfile();
      Provider.of<GalleryProvider>(context, listen: false).fetchImages();
    });
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showUploadDialog(context),
      icon: const Icon(Icons.add_photo_alternate),
      label: const Text('Add Image'),
      elevation: 4,
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
      itemBuilder: (context, index) => _buildImageCard(context, images[index]),
    );
  }

  Widget _buildImageCard(BuildContext context, dynamic image) {
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
                        Colors.black.withOpacity(0.8),
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
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer2<AuthProvider, GalleryProvider>(
        builder: (ctx, authProvider, galleryProvider, _) {
          if (authProvider.isLoading || galleryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authProvider.user == null) {
            return const Center(child: Text('Please login to continue'));
          }

          final images = galleryProvider.images;

          if (images.isEmpty) {
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
                    style: Theme.of(context).textTheme.titleLarge,
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
                    onPressed: () => _showUploadDialog(context),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Upload Image'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => galleryProvider.fetchImages(),
            child: _buildImageGrid(images),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const ImageUploadDialog(),
    );

    if (result != null && mounted) {
      try {
        await Provider.of<GalleryProvider>(context, listen: false)
            .uploadImage(
          result['image'],
          result['title'],
          result['description'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
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
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}