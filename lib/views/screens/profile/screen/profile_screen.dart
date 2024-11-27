import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../viewsModels/profile/profile_viewmodel.dart';
import '../../../widgets/customBottomNav.dart';
import '../widget/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3;
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(
      authService: context.read<AuthService>(),
      firestoreService: FirestoreService(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _viewModel.loadUserData();
      if (_viewModel.error != null && mounted) {
        _showErrorAndLogout(_viewModel.error!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorAndLogout(e.toString());
      }
    }
  }

  void _showErrorAndLogout(String message) {
    DialogHelper.showErrorDialog(
      context: context,
      title: 'Error',
      message: message,
    );
    _handleLogout();
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        // Already in profile
        break;
    }
  }

  void _confirmLogout() {
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Keluar',
      message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      onConfirm: _handleLogout,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF132054),
    Color textColor = const Color(0xFF132054),
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 24,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFEFE5DC),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF132054),
                Color(0xFF2B478A),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final userData = viewModel.userData;
                      if (userData == null) {
                        return const Center(child: Text('No user data found'));
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  ProfileAvatar(
                                    photoUrl: userData.photoUrl,
                                    radius: 40,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    userData.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF132054),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userData.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (userData.phoneNumber != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      userData.phoneNumber!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.person_outline,
                                    title: 'Edit Profil',
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/edit-profile');
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.settings_outlined,
                                    title: 'Lorem',
                                    onTap: () {
                                      // Handle Lorem
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.notifications_outlined,
                                    title: 'Lorem',
                                    onTap: () {
                                      // Handle Lorem
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.book_outlined,
                                    title: 'Lorem',
                                    onTap: () {
                                      // Handle Lorem
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.lock_outline,
                                    title: 'Ubah Kata Sandi',
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/change-password',
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.logout,
                                    title: 'Keluar',
                                    iconColor: Colors.red,
                                    textColor: Colors.red,
                                    onTap: _confirmLogout,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
