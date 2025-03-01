import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../widgets/base64_or_network_image.dart';
import '../models/gallery_image.dart';
import '../widgets/custom_card.dart';

class ImageViewerScreen extends StatefulWidget {
  final String initialImageId;

  const ImageViewerScreen({
    super.key,
    required this.initialImageId,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  Timer? _hideTimer;
  bool _showControls = true;
  final double _minScale = 0.5;
  final double _maxScale = 4.0;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _setupKeyboardListeners();
  }

  void _initializeScreen() {
    final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
    _currentIndex = galleryProvider.images.indexWhere(
      (img) => img.id == widget.initialImageId,
    );
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _showControls = true;
    _animationController.value = 1;
    _startHideTimer();
  }

  void _setupKeyboardListeners() {
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _hideTimer?.cancel();
    _animationController.dispose();
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
          _animationController.reverse();
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _animationController.forward();
        _startHideTimer();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleMouseMove(PointerEvent event) {
    if (!_showControls) {
      setState(() {
        _showControls = true;
        _animationController.forward();
      });
    }
    _startHideTimer();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _navigateToPrevious();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _navigateToNext();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  void _navigateToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startHideTimer();
    }
  }

  void _navigateToNext() {
    final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
    if (_currentIndex < galleryProvider.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startHideTimer();
    }
  }

  Widget _buildImageControls(GalleryProvider galleryProvider) {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Top bar
            _buildTopBar(galleryProvider),
            
            // Navigation arrows
            _buildNavigationArrows(galleryProvider),
            
            // Bottom bar
            _buildBottomBar(galleryProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GalleryProvider galleryProvider) {
    final currentImage = galleryProvider.images[_currentIndex];
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              currentImage.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () => _confirmDelete(context, currentImage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrows(GalleryProvider galleryProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentIndex > 0)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _navigateToPrevious,
          ),
        if (_currentIndex < galleryProvider.images.length - 1)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: _navigateToNext,
          ),
      ],
    );
  }

  Widget _buildBottomBar(GalleryProvider galleryProvider) {
    final currentImage = galleryProvider.images[_currentIndex];
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentImage.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  currentImage.description,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentIndex + 1} / ${galleryProvider.images.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  _dateFormatter.format(currentImage.createdAt.toUtc()),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<GalleryProvider>(
        builder: (context, galleryProvider, _) {
          return MouseRegion(
            onHover: _handleMouseMove,
            child: GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: galleryProvider.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                      _startHideTimer();
                    },
                    itemBuilder: (context, index) {
                      final image = galleryProvider.images[index];
                      return InteractiveViewer(
                        minScale: _minScale,
                        maxScale: _maxScale,
                        child: Hero(
                          tag: 'image_${image.id}',
                          child: Base64OrNetworkImage(
                            imageUrl: image.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildImageControls(galleryProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GalleryImage image) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this image?'),
            const SizedBox(height: 16),
            CustomCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Base64OrNetworkImage(
                        imageUrl: image.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          image.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFormatter.format(image.createdAt.toUtc()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await Provider.of<GalleryProvider>(context, listen: false)
            .deleteImage(image.id);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete image: $e')),
          );
        }
      }
    }
  }
}