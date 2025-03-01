import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                Icon(
                  Icons.photo_library_rounded,
                  size: 100,
                  color: Colors.white,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: const Duration(seconds: 2),
                      color: Colors.white.withOpacity(0.8),
                    )
                    .scale(
                      duration: const Duration(seconds: 2),
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                    ),
                const SizedBox(height: 32),

                // App Name Animation
                Text(
                  'My Gallery',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 800))
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),

                // Tagline Animation
                Text(
                  'Store your memories securely',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 800),
                    )
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 48),

                // Loading Animation
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 600),
                    )
                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0)),
                const SizedBox(height: 24),

                // Loading Text Animation
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 600),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}