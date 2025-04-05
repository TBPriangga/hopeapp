import 'package:flutter/material.dart';
import '../screens/notifications/notifications_badge.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF132054),
      title: Image.asset(
        'assets/logo/hope_logo_old.png',
        height: 70,
      ),
      centerTitle: true,
      actions: const [
        NotificationBadge(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
