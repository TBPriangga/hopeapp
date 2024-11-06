import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../viewsModels/auth/register_viewmodel.dart';
import '../../widgets/customDateField.dart';
import '../../widgets/customTextField.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Color(0xFF132054).withOpacity(0.8),
                      Color(0xFF2B478A).withOpacity(0.8),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          Center(
                            child: Image.asset(
                              'assets/logo/hope_logo.png',
                              height: 50,
                            ),
                          ),
                          const SizedBox(height: 48),
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
                          if (viewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            label: 'Email',
                            hintText: 'Cth : johndoe@gmail.com',
                            controller: viewModel.emailController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Nama',
                            hintText: 'Cth : Johndoe',
                            controller: viewModel.nameController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Kata sandi',
                            hintText: '••••••••••',
                            isPassword: true,
                            controller: viewModel.passwordController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Alamat',
                            hintText: 'Cth : Serayu 12 Malang',
                            controller: viewModel.addressController,
                          ),
                          const SizedBox(height: 16),
                          CustomDateField(
                            label: 'Tanggal Lahir',
                            controller: viewModel.birthDateController,
                            onDateSelected: (date) =>
                                viewModel.updateBirthDate(date),
                            errorText: viewModel.errorMessage, // Opsional
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'No. HP/WA',
                            hintText: 'Cth : 0812345678',
                            controller: viewModel.phoneController,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (await viewModel.register()) {
                                        if (context.mounted) {
                                          DialogHelper.showSuccessDialog(
                                            context: context,
                                            title: 'Registrasi Berhasil',
                                            message:
                                                'Akun Anda telah berhasil dibuat. Silahkan login untuk melanjutkan.',
                                            buttonText: 'Login',
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Tutup dialog
                                              Navigator.pushReplacementNamed(
                                                  context, AppRoutes.login);
                                            },
                                          );
                                        }
                                      } else if (viewModel.errorMessage !=
                                          null) {
                                        // Tampilkan error dialog jika ada error
                                        if (context.mounted) {
                                          DialogHelper.showErrorDialog(
                                            context: context,
                                            title: 'Registrasi Gagal',
                                            message: viewModel.errorMessage!,
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF132054),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah terdaftar. Silahkan',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.login);
                                },
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                ),
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
