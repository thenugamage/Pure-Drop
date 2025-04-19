// navigationbar.dart
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/report_page.dart';
import '../pages/settings_page.dart';
import '../pages/profile_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final GlobalKey<NavigatorState> navigatorKey;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, icon: Icons.home, label: 'Home', index: 0),
            _navItem(context, icon: Icons.bar_chart, label: 'Analysis', index: 1),
            const SizedBox(width: 40), // FAB space
            _navItem(context, icon: Icons.settings, label: 'Setting', index: 3),
            _navItem(context, icon: Icons.person_outline, label: 'Profile', index: 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        onTap(index);
        _handleNavigation(context, index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF33C4FF) : Colors.black54,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF33C4FF) : Colors.black54,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1: // Analysis
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportPage()),
        );
        break;
      case 3: // Setting
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingPage()),
        );
        break;
      case 4: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }
}