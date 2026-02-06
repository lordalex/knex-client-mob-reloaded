import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/auth/auth_providers.dart';

/// Profile tab screen showing user info, settings navigation, and sign-out.
///
/// Displays the user's photo, name, and email from [userProfileProvider].
/// Provides navigation to favorites, history, language, list config, and
/// profile editing screens. Includes dark mode toggle and sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Profile header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: _profileImage(profile?.photo),
                  child: profile?.photo == null
                      ? Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                if (profile != null) ...[
                  Text(
                    '${profile.firstName} ${profile.lastName}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else
                  Text(
                    'Not signed in',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),

          // Edit profile
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profileCreate'),
          ),

          // Favorites
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Favorites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/favorites'),
          ),

          // History
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/history'),
          ),

          const Divider(),

          // List config
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Sort & Distance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/listConfig'),
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/changeLanguage'),
          ),

          // Dark mode toggle
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),

          const Divider(),

          // App version
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: Text(
              AppConstants.appVersion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Sign out
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sign Out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _signOut(context, ref),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  ImageProvider? _profileImage(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    if (photo.startsWith('http')) return NetworkImage(photo);
    try {
      return MemoryImage(base64Decode(photo));
    } catch (_) {
      return null;
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear state
    ref.read(userProfileProvider.notifier).state = null;
    ref.read(activeTicketProvider.notifier).state = null;
    ref.read(ticketHistoryProvider.notifier).state = [];
    ref.read(userProfileCreatedProvider.notifier).state = false;
    ref.read(base64PhotoProvider.notifier).state = '';

    await ref.read(authServiceProvider).signOut();
  }
}
