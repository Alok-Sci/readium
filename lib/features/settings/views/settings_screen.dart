import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:readium/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:readium/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentThemeMode = ThemeMode.system;
  String _databasePath = '';
  String _appVersion = '';
  String _buildDate = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load theme mode
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    _currentThemeMode = ThemeMode.values[themeModeIndex];

    // Load database path
    final dbHelper = DatabaseHelper();
    _databasePath = await dbHelper.getDatabasePath();

    // Load app info
    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _buildDate = DateTime.now().toString().split(' ')[0]; // Placeholder

    setState(() {
      _isLoading = false;
    });
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  Future<void> _changeThemeMode(ThemeMode newMode) async {
    setState(() {
      _currentThemeMode = newMode;
    });

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', newMode.index);

    // Update app theme
    MyApp.of(context)?.changeThemeMode(newMode);
  }

  Future<void> _changeDatabasePath() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final dbHelper = DatabaseHelper();
        await dbHelper.changeDatabasePath(selectedDirectory);

        setState(() {
          _databasePath = '$selectedDirectory/readium.db';
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database path updated successfully'),
            backgroundColor: context.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change database path: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Read History'),
        content: Text(
          'Are you sure you want to clear all read history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.clearAllHistory();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Read history cleared successfully'),
            backgroundColor: context.colorScheme.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset('assets/icons/icon.png', width: 40, height: 40),
            SizedBox(width: 12),
            Text('About Readium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: $_appVersion', style: context.textTheme.bodyMedium),
            SizedBox(height: 8),
            Text(
              'Build Date: $_buildDate',
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Readium is a free and open-source Medium article reader that allows you to read Medium articles without a subscription.',
              style: context.textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Text(
              'Changelog (v$_appVersion):',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Initial release\n'
              '• Read Medium articles for free\n'
              '• Read history tracking\n'
              '• Deep linking support\n'
              '• Dark/Light theme support',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 130,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text("Settings", style: context.textTheme.displayMedium),
              ),
              30.height,
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: context.colorScheme.tertiaryContainer,
              height: 1.0,
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        automaticallyImplyLeading: false,
        flexibleSpace: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("Settings", style: context.textTheme.displayMedium),
            ),
            30.height,
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: context.colorScheme.tertiaryContainer,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          20.height,

          // Appearance Setting
          SettingsTile(
            title: 'Appearance',
            subtitle: _getThemeModeLabel(_currentThemeMode),
            onTap: () {},
            leadingIcon: Icons.palette_outlined,
            trailingWidget: PopupMenuButton<ThemeMode>(
              onSelected: _changeThemeMode,
              itemBuilder: (context) => ThemeMode.values.map((mode) {
                final isSelected = _currentThemeMode == mode;
                return PopupMenuItem<ThemeMode>(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(
                        _getThemeModeIcon(mode),
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getThemeModeLabel(mode),
                        style: TextStyle(
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: context.colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                );
              }).toList(),
              elevation: 8,
              child: Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          Divider(color: context.colorScheme.tertiaryContainer, height: 0),

          // Storage Path Setting
          SettingsTile(
            title: 'Change Storage Path',
            subtitle: _databasePath,
            onTap: _changeDatabasePath,
            leadingIcon: Icons.folder_outlined,
          ),
          Divider(color: context.colorScheme.tertiaryContainer, height: 0),

          // Clear History Setting
          SettingsTile(
            title: 'Clear Read History',
            subtitle: 'Remove all articles from history',
            onTap: _clearHistory,
            leadingIcon: Icons.delete_outline_rounded,
          ),
          Divider(color: context.colorScheme.tertiaryContainer, height: 0),

          // Hidden tiles (as per requirements)
          // Report Bug - Hidden
          // Have a Suggestion - Hidden
          // Rate the App - Hidden

          // About Setting
          SettingsTile(
            title: 'About',
            subtitle: 'Version $_appVersion',
            onTap: _showAboutDialog,
            leadingIcon: Icons.info_outline_rounded,
          ),

          Spacer(),

          // Footer
          RichText(
            text: TextSpan(
              style: context.textTheme.labelMedium,
              children: [
                TextSpan(text: 'Made with ❤️ by '),
                TextSpan(
                  text: 'Alok Singh',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri url = Uri.parse('https://github.com/Alok-Sci');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                ),
              ],
            ),
          ),
          10.height,
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Widget? trailingWidget;
  final VoidCallback onTap;
  const SettingsTile({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    this.trailingWidget,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        title,
        style: context.textTheme.headlineSmall!.copyWith(fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.labelMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          trailingWidget ??
          Icon(
            Icons.chevron_right_rounded,
            color: context.colorScheme.secondary,
          ),
      onTap: onTap,
    );
  }
}
