import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/features/main/main_screen.dart';
import 'package:readium/features/article/views/article_screen.dart';
import 'package:readium/core/theme/app_theme.dart';
import 'package:readium/core/services/deep_link_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // Static method to access state from anywhere
  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final DeepLinkService _deepLinkService = DeepLinkService();
  ThemeMode _themeMode = ThemeMode.system;

  // Getter for theme mode
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _initializeDeepLinking();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeModeIndex];
    });
  }

  void _initializeDeepLinking() {
    _deepLinkService.initialize((String mediumUrl) {
      // Navigate to article screen when a deep link is received
      _handleDeepLink(mediumUrl);
    });
  }

  void _handleDeepLink(String mediumUrl) {
    // Use a post-frame callback to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // If we're on the home screen, pass the URL to it
        // Otherwise, navigate to a new article screen
        Navigator.of(context).pushNamed('/article', arguments: mediumUrl);
      }
    });
  }

  // Method to change theme mode
  void changeThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(context),
        darkTheme: AppTheme.darkTheme(context),
        themeMode: _themeMode,
        home: MainScreen(),
        routes: {
          '/article': (context) {
            final String mediumUrl = ModalRoute.of(context)!.settings.arguments as String;
            return ArticleScreen(mediumUrl: mediumUrl);
          },
        },
      ),
    );
  }
}
