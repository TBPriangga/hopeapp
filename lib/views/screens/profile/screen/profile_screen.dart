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
  final int _selectedIndex = 4;
  late ProfileViewModel _viewModel;
  bool _isLoggingOut = false;

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
      if (_viewModel.error != null &&
          !_viewModel.error!.contains('offline') &&
          mounted) {
        _showErrorAndNavigate(_viewModel.error!);
      }
    } catch (e) {
      if (mounted) {
        _showErrorAndNavigate(e.toString());
      }
    }
  }

  void _showErrorAndNavigate(String message) {
    DialogHelper.showErrorDialog(
      context: context,
      title: 'Error',
      message: message,
      buttonText: 'Login',
      onPressed: () {
        Navigator.pop(context); // Close dialog
        _navigateToLogin(); // Navigate to login
      },
    );
  }

  void _navigateToLogin() {
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
        Navigator.pushReplacementNamed(context, AppRoutes.form);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.dailyWordList);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.about);
        break;
    }
  }

  // Improved logout handler
  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    // Show loading dialog
    if (mounted) {
      DialogHelper.showLoadingDialog(context: context);
    }

    try {
      // Call logout method
      final success = await _viewModel.logout();

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        // Navigate to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.error ?? 'Gagal logout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _confirmLogout() {
    // Add network check
    if (_viewModel.isOfflineMode) {
      DialogHelper.showConfirmationDialog(
        context: context,
        title: 'Mode Offline',
        message:
            'Anda sedang dalam mode offline. Data sesi akan dihapus lokal namun tidak akan sepenuhnya logout dari server. Lanjutkan?',
        confirmText: 'Lanjutkan',
        cancelText: 'Batal',
        onConfirm: _handleLogout,
      );
    } else {
      DialogHelper.showConfirmationDialog(
        context: context,
        title: 'Keluar',
        message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
        confirmText: 'Keluar',
        cancelText: 'Batal',
        onConfirm: _handleLogout,
      );
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap, // Parameter tidak berubah
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Data tidak tersedia',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Offline mode indicator
                      Widget offlineBanner = const SizedBox.shrink();
                      if (viewModel.isOfflineMode) {
                        offlineBanner = Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          color: Colors.orange.withOpacity(0.8),
                          child: const Row(
                            children: [
                              Icon(Icons.wifi_off,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Mode Offline - Menggunakan data lokal',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Offline banner if needed
                                offlineBanner,

                                const SizedBox(height: 8),

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
                                        title: _isLoggingOut
                                            ? 'Proses Keluar...'
                                            : 'Keluar',
                                        iconColor: Colors.red,
                                        textColor: Colors.red,
                                        onTap: _isLoggingOut
                                            ? () {} // Fungsi kosong sebagai pengganti null
                                            : _confirmLogout,
                                      ),
                                    ],
                                  ),
                                ),
                                // Tambahkan padding di bawah untuk memastikan versi terlihat
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),

                          // Versi aplikasi di bagian bawah
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Text(
                              'Versi ${viewModel.appVersion}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
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
