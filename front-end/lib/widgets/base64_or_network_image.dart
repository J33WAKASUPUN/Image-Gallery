import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Base64OrNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget? placeholder;
  final Duration fadeInDuration;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const Base64OrNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    this.placeholder,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.backgroundColor,
  });

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: placeholder ??
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error, stackTrace);
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Theme.of(context).colorScheme.error.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Failed to load image',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBase64Image(BuildContext context, String base64String) {
    try {
      final data = base64String.split(',');
      if (data.length != 2) {
        throw Exception('Invalid base64 image format');
      }

      final bytes = base64Decode(data[1]);
      
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(context, error, stackTrace),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: fadeInDuration,
            curve: Curves.easeOut,
            child: child,
          );
        },
      );
    } catch (e) {
      debugPrint('Error processing base64 image: $e');
      return _buildErrorWidget(context, e, StackTrace.current);
    }
  }

  Widget _buildNetworkImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) => _buildLoadingIndicator(context),
      errorWidget: (context, url, error) =>
          _buildErrorWidget(context, error, StackTrace.current),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.startsWith('data:')) {
      imageWidget = _buildBase64Image(context, imageUrl);
    } else {
      imageWidget = _buildNetworkImage(context);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}