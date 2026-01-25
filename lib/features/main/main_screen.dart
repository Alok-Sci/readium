import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/features/home/home_screen.dart';
import 'package:readium/features/history/views/history_screen.dart';
import 'package:readium/features/settings/views/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return _pages[index];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: context.colorScheme.secondary,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(AppAssets.home,
                color: context.colorScheme.secondary,height: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AppAssets.articles,
                color: context.colorScheme.secondary,height: 24),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AppAssets.setting,
                color: context.colorScheme.secondary,height: 24),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
