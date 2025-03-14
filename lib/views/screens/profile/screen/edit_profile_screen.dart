import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/dialog_helper.dart';
import '../../../../viewsModels/auth/edit_profile_viewmodel.dart';
import '../widget/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late EditProfileViewModel _viewModel;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  bool _isInitialized = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Inisialisasi animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _viewModel = Provider.of<EditProfileViewModel>(context, listen: false);
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    await _viewModel.loadUserData();
    if (mounted && _animationController != null) {
      _animationController!.forward();
    }

    // Monitor perubahan pada form
    _viewModel.nameController.addListener(_onFieldChanged);
    _viewModel.phoneController.addListener(_onFieldChanged);
    _viewModel.addressController.addListener(_onFieldChanged);
    _viewModel.birthDateController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges && mounted) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    if (_viewModel.nameController.hasListeners) {
      _viewModel.nameController.removeListener(_onFieldChanged);
    }
    if (_viewModel.phoneController.hasListeners) {
      _viewModel.phoneController.removeListener(_onFieldChanged);
    }
    if (_viewModel.addressController.hasListeners) {
      _viewModel.addressController.removeListener(_onFieldChanged);
    }
    if (_viewModel.birthDateController.hasListeners) {
      _viewModel.birthDateController.removeListener(_onFieldChanged);
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges || _viewModel.selectedImage != null) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perubahan belum disimpan'),
          content: const Text(
              'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tetap di halaman',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, _) {
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F7FA),
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3949AB), Color(0xFF283593)],
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () async {
                    if (await _onWillPop()) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
                title: const Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              body: viewModel.isLoading && !_isInitialized
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                      ),
                    )
                  : _fadeAnimation != null
                      ? FadeTransition(
                          opacity: _fadeAnimation!,
                          child: _buildMainContent(
                              viewModel, context, isWideScreen),
                        )
                      : _buildMainContent(viewModel, context, isWideScreen),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(
      EditProfileViewModel viewModel, BuildContext context, bool isWideScreen) {
    return Stack(
      children: [
        // Main Content
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Profile Image Section
                _buildProfileImageSection(viewModel),

                const SizedBox(height: 30),

                // Form Content in a Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Title
                          const Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF3949AB)),
                              SizedBox(width: 8),
                              Text(
                                'Informasi Pribadi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3949AB),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),

                          // Error Message if present
                          if (viewModel.errorMessage != null)
                            _buildErrorMessage(viewModel.errorMessage!),

                          // Form Fields in layout based on screen size
                          isWideScreen
                              ? _buildWideScreenForm(viewModel, context)
                              : _buildNarrowScreenForm(viewModel, context),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSaveButton(viewModel, context),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageSection(EditProfileViewModel viewModel) {
    return Center(
      child: Stack(
        children: [
          Hero(
            tag: 'profileImage',
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: Consumer<EditProfileViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isUploadingImage) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                        ),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: ProfileAvatar(
                      photoUrl: viewModel.selectedImage?.path ??
                          viewModel.userData?.photoUrl,
                      radius: 65,
                      isLocalImage: viewModel.selectedImage != null,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showPhotoOptions(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3949AB),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildPhotoOption(
                icon: Icons.photo_library,
                title: 'Pilih dari Galeri',
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.pickImage();
                  setState(() => _hasChanges = true);
                },
              ),
              const Divider(height: 1),
              _buildPhotoOption(
                icon: Icons.camera_alt,
                title: 'Ambil Foto',
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.takePhoto();
                  setState(() => _hasChanges = true);
                },
              ),
              if (_viewModel.userData?.photoUrl != null ||
                  _viewModel.selectedImage != null) ...[
                const Divider(height: 1),
                _buildPhotoOption(
                  icon: Icons.delete,
                  title: 'Hapus Foto',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Add remove photo functionality to your viewmodel
                    // _viewModel.removePhoto();
                    setState(() => _hasChanges = true);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF3949AB),
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideScreenForm(
      EditProfileViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        // Row 1: Name and Email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Nama',
                controller: viewModel.nameController,
                hintText: 'Masukkan nama anda',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                label: 'Email',
                controller: viewModel.emailController,
                hintText: 'Masukkan email anda',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Row 2: Phone and Birth Date
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Nomor Telepon',
                controller: viewModel.phoneController,
                hintText: 'Masukkan nomor telepon anda',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                label: 'Tanggal Lahir',
                controller: viewModel.birthDateController,
                hintText: 'Pilih tanggal lahir',
                icon: Icons.cake_outlined,
                readOnly: true,
                onTap: () => _selectDate(context, viewModel),
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Row 3: Address
        _buildFormField(
          label: 'Alamat',
          controller: viewModel.addressController,
          hintText: 'Masukkan alamat anda',
          icon: Icons.home_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildNarrowScreenForm(
      EditProfileViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        _buildFormField(
          label: 'Nama',
          controller: viewModel.nameController,
          hintText: 'Masukkan nama anda',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Email',
          controller: viewModel.emailController,
          hintText: 'Masukkan email anda',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: false,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Nomor Telepon',
          controller: viewModel.phoneController,
          hintText: 'Masukkan nomor telepon anda',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Tanggal Lahir',
          controller: viewModel.birthDateController,
          hintText: 'Pilih tanggal lahir',
          icon: Icons.cake_outlined,
          readOnly: true,
          onTap: () => _selectDate(context, viewModel),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        const SizedBox(height: 20),
        _buildFormField(
          label: 'Alamat',
          controller: viewModel.addressController,
          hintText: 'Masukkan alamat anda',
          icon: Icons.home_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF3949AB)),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3949AB),
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[200]!,
              ),
            ),
          ),
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, EditProfileViewModel viewModel) async {
    DateTime? initialDate;
    if (viewModel.birthDateController.text.isNotEmpty) {
      try {
        initialDate =
            DateFormat('dd/MM/yyyy').parse(viewModel.birthDateController.text);
      } catch (e) {
        initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
      }
    } else {
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3949AB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3949AB),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.updateBirthDate(picked);
      setState(() => _hasChanges = true);
    }
  }

  Widget _buildSaveButton(
      EditProfileViewModel viewModel, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3949AB), Color(0xFF283593)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: viewModel.isLoading
              ? null
              : () async {
                  if (await viewModel.saveProfile()) {
                    if (context.mounted) {
                      setState(() => _hasChanges = false);
                      DialogHelper.showSuccessDialog(
                        context: context,
                        title: 'Berhasil',
                        message: 'Profil berhasil diperbarui',
                        buttonText: 'OK',
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                        },
                      );
                    }
                  }
                },
          child: Center(
            child: viewModel.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
