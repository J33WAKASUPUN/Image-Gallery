import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/login_screen.dart';
import '../widgets/base64_or_network_image.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (ctx, authProvider, themeProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const SizedBox.shrink();
        }

        return Drawer(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Drawer Header
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile image with border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: user.profilePicture.isNotEmpty == true
                                ? Base64OrNetworkImage(
                                    imageUrl: user.profilePicture,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildProfileFallback(context),
                                  )
                                : _buildProfileFallback(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // User Email
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Main drawer items in Expanded to push logout to bottom
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.home_rounded,
                        title: 'Home',
                        onTap: () => Navigator.pop(context),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.photo_library_rounded,
                        title: 'My Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          // Add navigation to gallery if needed
                        },
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          // Add navigation to settings if needed
                        },
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      // Theme Toggle
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        child: SwitchListTile.adaptive(
                          secondary: Icon(
                            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Logout button at bottom
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () => _showLogoutDialog(context, authProvider),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileFallback(BuildContext context) {
    return Icon(
      Icons.person,
      size: 50,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text('Are you sure you want to logout?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await authProvider.logout();
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }
}