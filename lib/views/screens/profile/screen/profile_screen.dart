import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../models/user_model.dart';
import '../../../../viewsModels/auth/login_viewmodel.dart';
import '../../../widgets/customBottomNav.dart';
import '../widget/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Set to 3 for Profile tab
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();

    try {
      final user = authService.currentUser;
      if (user != null) {
        final userData = await firestoreService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading user data: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        // Navigator.pushNamed(context, AppRoutes.add);
        break;
      case 2:
        // Navigator.pushNamed(context, AppRoutes.menu);
        break;
      case 3:
        // Already in profile
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Tampilkan dialog konfirmasi
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Keluar',
      message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      onConfirm: () async {
        try {
          // Tutup dialog konfirmasi
          Navigator.pop(context);

          // Tampilkan loading
          DialogHelper.showLoadingDialog(
            context: context,
          );

          // Ambil instance AuthService & LoginViewModel
          final authService = Provider.of<AuthService>(context, listen: false);
          final loginViewModel =
              Provider.of<LoginViewModel>(context, listen: false);

          // Proses logout
          await authService.logout();

          // Reset form login
          loginViewModel.resetForm();

          if (context.mounted) {
            // Tutup dialog loading
            Navigator.pop(context);

            // Navigate ke login screen dan hapus semua route sebelumnya
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        } catch (e) {
          if (context.mounted) {
            // Tutup dialog loading jika terjadi error
            Navigator.pop(context);

            // Tampilkan error dialog
            DialogHelper.showErrorDialog(
              context: context,
              title: 'Gagal Keluar',
              message: 'Terjadi kesalahan saat keluar. Silakan coba lagi.',
            );
          }
        }
      },
      onCancel: () {
        // Tutup dialog konfirmasi jika user memilih batal
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Column(
                                  children: [
                                    // Profile Image
                                    Stack(
                                      children: [
                                        ProfileAvatar(
                                          photoUrl: _userData?.photoUrl,
                                          radius: 40,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Color(0xFF132054),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Profile Info
                                    Text(
                                      _userData?.name ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF132054),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userData?.email ?? 'No Email',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_userData?.phoneNumber != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _userData!.phoneNumber!,
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

                        // Menu Card
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
                                  Navigator.pushNamed(context, '/edit-profile');
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
                                      context, '/change-password');
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                icon: Icons.logout,
                                title: 'Keluar',
                                iconColor: Colors.red,
                                textColor: Colors.red,
                                onTap: () => _handleLogout(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
}
