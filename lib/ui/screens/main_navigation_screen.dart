import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';
import 'countries_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    final List<Widget> screens = [
      HomeScreen(
        onNavigateToTab: _onSelectTab,
        onOpenDrawer: _openDrawer,
      ),
      CountriesScreen(onNavigateToTab: _onSelectTab),
      const SearchScreen(),
      FavoritesScreen(onNavigateToTab: _onSelectTab),
      DownloadsScreen(onNavigateToTab: _onSelectTab),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onNavigateToTab: _onSelectTab),
      body: Stack(
        children: [
          // IndexedStack preserves state across all 5 screens
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Floating Persistent Mini Player above Navigation Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayerBar(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          border: Border(top: BorderSide(color: AppTheme.borderOf(context), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onSelectTab,
          height: 64,
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: tr.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.public_outlined),
              selectedIcon: const Icon(Icons.public_rounded),
              label: tr.navCountries,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search_rounded),
              label: tr.navSearch,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: tr.navFavorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.download_outlined),
              selectedIcon: const Icon(Icons.download_done_rounded),
              label: tr.navDownloads,
            ),
          ],
        ),
      ),
    );
  }
}
