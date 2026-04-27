import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_mobile/core/theme/app_colors.dart';
import 'package:ondas_mobile/features/player/presentation/widgets/mini_player_widget.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', path: '/home'),
    _TabItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Search', path: '/search'),
    _TabItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music, label: 'Library', path: '/library'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', path: '/profile'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const MiniPlayerWidget(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.spotifyGreen.withValues(alpha: 0.2),
        destinations: _tabs
            .asMap()
            .entries
            .map(
              (entry) => NavigationDestination(
                icon: Icon(
                  entry.value.icon,
                  color: entry.key == selectedIndex ? AppColors.spotifyGreen : AppColors.silver,
                ),
                selectedIcon: Icon(entry.value.activeIcon, color: AppColors.spotifyGreen),
                label: entry.value.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
