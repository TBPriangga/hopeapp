import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../viewsModels/auth/register_viewmodel.dart';
import '../../widgets/customDateField.dart';
import '../../widgets/customTextField.dart';
import '../profile/widget/profile_avatar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _acceptTerms = false;
  String? _confirmPasswordError;
  Timer? _debounceTimer;
  Timer? _verificationCheckTimer;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _debounceTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  // Metode untuk memulai pengecekan status verifikasi secara berkala
  void _startVerificationCheck(RegisterViewModel viewModel) {
    // Batalkan timer yang mungkin masih berjalan
    _verificationCheckTimer?.cancel();

    // Buat timer baru untuk pengecekan setiap 3 detik
    _verificationCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      final verified = await viewModel.checkEmailVerificationStatus();

      if (verified) {
        // Jika sudah terverifikasi, hentikan timer
        timer.cancel();

        if (context.mounted) {
          // Tampilkan dialog sukses verifikasi
          DialogHelper.showSuccessDialog(
            context: context,
            title: 'Email Terverifikasi',
            message:
                'Email Anda telah berhasil diverifikasi. Silakan lengkapi data lainnya untuk menyelesaikan registrasi.',
            buttonText: 'Lanjutkan',
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions untuk responsive layout
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/worship_bg.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment(0.5, 0),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF132054).withOpacity(0.8),
                      const Color(0xFF2B478A).withOpacity(0.8),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: size.height - padding.top - padding.bottom,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.03),

                            // Logo Section
                            Center(
                              child: Image.asset(
                                'assets/logo/hope_logo_old.png',
                                height: size.height * 0.15,
                              ),
                            ),

                            // Title Section
                            const Center(
                              child: Text(
                                'Daftar Akun',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Lengkapi data diri Anda',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // Error Message
                            if (viewModel.errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(top: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red[300], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        viewModel.errorMessage!,
                                        style: TextStyle(
                                            color: Colors.red[300],
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: size.height * 0.02),

                            // Verification Email Sent Message
                            if (viewModel.verificationEmailSent)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            color: Colors.green[400], size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Link verifikasi telah dikirim ke email Anda',
                                            style: TextStyle(
                                                color: Colors.green[400],
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Silakan cek email Anda dan klik link verifikasi untuk melanjutkan proses pendaftaran.',
                                      style: TextStyle(
                                          color: Colors.green[400],
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () async {
                                            await viewModel
                                                .resendVerificationEmail();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Email verifikasi telah dikirim ulang'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.refresh,
                                              size: 16),
                                          label: const Text('Kirim Ulang'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.green[400],
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            final verified = await viewModel
                                                .checkEmailVerificationStatus();
                                            if (context.mounted) {
                                              if (verified) {
                                                DialogHelper.showSuccessDialog(
                                                  context: context,
                                                  title: 'Email Terverifikasi',
                                                  message:
                                                      'Email Anda telah berhasil diverifikasi. Silakan lengkapi data lainnya untuk menyelesaikan registrasi.',
                                                  buttonText: 'Lanjutkan',
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Tutup dialog
                                                  },
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Email belum diverifikasi. Silakan cek email Anda.'),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.verified_user,
                                              size: 16),
                                          label: const Text('Cek Status'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.green[400],
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            // Email dan Verifikasi Section
                            _buildEmailVerificationSection(viewModel),

                            // Form Registrasi Lainnya (hanya muncul setelah verifikasi)
                            if (viewModel.isEmailVerified) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'Lengkapi Data Diri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Foto Profil Section (tambahan baru)
                              _buildProfileImageSection(viewModel),

                              // Form Fields
                              _buildRemainingFormFields(viewModel),

                              // Pertanyaan Status Baptis dan Keanggotaan
                              _buildChurchStatusSection(viewModel),

                              // Terms and Conditions
                              _buildTermsAndConditions(),

                              SizedBox(height: size.height * 0.03),

                              // Complete Registration Button
                              _buildCompleteRegistrationButton(
                                  context, viewModel),
                            ],

                            SizedBox(height: size.height * 0.02),

                            // Login Link
                            _buildLoginLink(context),

                            SizedBox(height: size.height * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Profile Image Section (tambahan baru)
  Widget _buildProfileImageSection(RegisterViewModel viewModel) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              // Profile image
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Consumer<RegisterViewModel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.isUploadingImage) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    }

                    return ProfileAvatar(
                      photoUrl: viewModel.selectedImage?.path,
                      radius: 55,
                      isLocalImage: viewModel.selectedImage != null,
                    );
                  },
                ),
              ),

              // Camera button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context, viewModel),
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Foto Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context, RegisterViewModel viewModel) {
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
                  viewModel.pickImage();
                },
              ),
              const Divider(height: 1),
              _buildPhotoOption(
                icon: Icons.camera_alt,
                title: 'Ambil Foto',
                onTap: () {
                  Navigator.pop(context);
                  viewModel.takePhoto();
                },
              ),
              if (viewModel.selectedImage != null) ...[
                const Divider(height: 1),
                _buildPhotoOption(
                  icon: Icons.delete,
                  title: 'Hapus Foto',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.removePhoto();
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

  Widget _buildEmailVerificationSection(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Email Field
        TextField(
          controller: viewModel.emailController,
          enabled:
              !viewModel.verificationEmailSent && !viewModel.isEmailVerified,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Cth: johndoe@gmail.com',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: viewModel.isVerifyingEmail
                ? Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(6),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : viewModel.emailValidationMessage != null
                    ? Icon(
                        viewModel.isEmailValid
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color:
                            viewModel.isEmailValid ? Colors.green : Colors.red,
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3949AB),
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            // Validasi email format dengan debouncing
            _debounceTimer?.cancel();
            if (value.isNotEmpty) {
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                viewModel.checkEmailFormat(value.trim());
              });
            } else {
              viewModel.resetEmailValidation();
            }
          },
        ),

        // Email Validation Message
        if (viewModel.emailValidationMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              viewModel.emailValidationMessage!,
              style: TextStyle(
                color: viewModel.isEmailValid ? Colors.green : Colors.red[300],
                fontSize: 12,
              ),
            ),
          ),

        // Password Section (muncul hanya jika email valid dan belum diverifikasi)
        if (viewModel.showVerifyButton && !viewModel.verificationEmailSent) ...[
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Kata Sandi',
            hintText: '••••••••••',
            isPassword: true,
            controller: viewModel.passwordController,
            prefixIcon: const Icon(Icons.lock_outlined),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Konfirmasi Kata Sandi',
            hintText: '••••••••••',
            isPassword: true,
            controller: _confirmPasswordController,
            prefixIcon: const Icon(Icons.lock_outlined),
            errorText: _confirmPasswordError,
          ),
          const SizedBox(height: 20),

          // Verify Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.verified_user),
              label: const Text('Verifikasi Email'),
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      // Validasi password
                      if (viewModel.passwordController.text.isEmpty) {
                        setState(() {
                          _confirmPasswordError = 'Password tidak boleh kosong';
                        });
                        return;
                      }

                      if (viewModel.passwordController.text.length < 6) {
                        setState(() {
                          _confirmPasswordError = 'Password minimal 6 karakter';
                        });
                        return;
                      }

                      // Validasi konfirmasi password
                      if (viewModel.passwordController.text !=
                          _confirmPasswordController.text) {
                        setState(() {
                          _confirmPasswordError =
                              'Konfirmasi password tidak sesuai';
                        });
                        return;
                      }

                      setState(() {
                        _confirmPasswordError = null;
                      });

                      // Kirim email verifikasi
                      final success = await viewModel.sendVerificationEmail();

                      if (success && context.mounted) {
                        // Tampilkan dialog
                        DialogHelper.showSuccessDialog(
                          context: context,
                          title: 'Verifikasi Email',
                          message:
                              'Link verifikasi telah dikirim ke email Anda. Silakan cek email dan klik link tersebut untuk memverifikasi akun.',
                          buttonText: 'OK',
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog

                            // Mulai pengecekan verifikasi berkala
                            _startVerificationCheck(viewModel);
                          },
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF132054),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRemainingFormFields(RegisterViewModel viewModel) {
    return Column(
      children: [
        CustomTextField(
          label: 'Nama',
          hintText: 'Cth : Johndoe',
          controller: viewModel.nameController,
          prefixIcon: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Alamat',
          hintText: 'Cth : Serayu 12 Malang',
          controller: viewModel.addressController,
          maxLines: 2,
          prefixIcon: const Icon(Icons.home_outlined),
        ),
        const SizedBox(height: 16),
        CustomDateField(
          label: 'Tanggal Lahir',
          controller: viewModel.birthDateController,
          onDateSelected: (date) => viewModel.updateBirthDate(date),
          hintText: 'Pilih tanggal lahir Anda',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'No. HP/WA',
          hintText: 'Cth : 0812345678',
          controller: viewModel.phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
      ],
    );
  }

  Widget _buildChurchStatusSection(RegisterViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Keanggotaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Status Baptis
          Row(
            children: [
              const Text(
                'Apakah Anda sudah dibaptis?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              ToggleButtons(
                constraints: const BoxConstraints(
                  minWidth: 60.0,
                  minHeight: 36.0,
                ),
                borderRadius: BorderRadius.circular(8),
                onPressed: (index) {
                  viewModel.setBaptismStatus(index == 0);
                },
                isSelected: [viewModel.isBaptized, !viewModel.isBaptized],
                selectedColor: Colors.white,
                fillColor: const Color(0xFF3949AB),
                color: Colors.white70,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Ya'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Tidak'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Keanggotaan
          const Text(
            'Status Keanggotaan:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Radio button untuk status keanggotaan
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: viewModel.isChurchMember,
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setMembershipStatus(value);
                  }
                },
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.white70;
                  },
                ),
              ),
              const Text(
                'Anggota Jemaat',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Radio<bool>(
                value: false,
                groupValue: viewModel.isChurchMember,
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setMembershipStatus(value);
                  }
                },
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.white70;
                  },
                ),
              ),
              const Text(
                'Partisipan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Asal Gereja (muncul jika partisipan)
          if (!viewModel.isChurchMember) ...[
            const SizedBox(height: 12),
            TextField(
              controller: viewModel.originChurchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                viewModel.setOriginChurch(value);
              },
              decoration: InputDecoration(
                labelText: 'Asal Gereja',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Nama gereja asal Anda',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                prefixIcon: Icon(
                  Icons.church,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: const Color(0xFF132054),
              checkColor: Colors.white,
              side: const BorderSide(
                color: Colors.white,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Saya menyetujui ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle terms and conditions tap
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Syarat & Ketentuan'),
                            content: const SingleChildScrollView(
                              child: Text(
                                'Berikut adalah syarat dan ketentuan penggunaan aplikasi Hope.\n\n1. Akun hanya diperuntukkan bagi anggota jemaat.\n2. Data pribadi akan dijaga kerahasiaannya.\n3. Informasi yang diinputkan adalah informasi yang sebenarnya.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Tutup'),
                              ),
                            ],
                          ),
                        );
                      },
                  ),
                  const TextSpan(
                    text: ' yang berlaku',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteRegistrationButton(
      BuildContext context, RegisterViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (viewModel.isLoading || !_acceptTerms)
            ? null
            : () async {
                if (await viewModel.completeRegistration()) {
                  if (context.mounted) {
                    DialogHelper.showSuccessDialog(
                      context: context,
                      title: 'Registrasi Berhasil',
                      message:
                          'Akun Anda telah berhasil dibuat. Silakan login untuk melanjutkan.',
                      buttonText: 'Login',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF132054),
          disabledBackgroundColor: Colors.grey.withOpacity(0.5),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF132054),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Daftar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah terdaftar? Silahkan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
