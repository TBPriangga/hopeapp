import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        onItemTapped(index);
        // Handle navigation based on index
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            // Handle Add navigation
            break;
          case 2:
            // Handle Menu navigation
            break;
          case 3:
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF132054),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          activeIcon: Icon(Icons.add_box),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          activeIcon: Icon(Icons.menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
