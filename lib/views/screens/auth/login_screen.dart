import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../viewsModels/auth/login_viewmodel.dart';
import '../../../app/routes/app_routes.dart';
import '../../widgets/customTextField.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
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
                            'Masuk Akun',
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
                          label: 'E-mail',
                          hintText: 'Cth : ayudimas@gmail.com',
                          controller: viewModel.emailController,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Kata Sandi',
                          hintText: '••••••••••',
                          isPassword: true,
                          controller: viewModel.passwordController,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () async {
                                    if (await viewModel.login()) {
                                      if (context.mounted) {
                                        DialogHelper.showSuccessDialog(
                                          context: context,
                                          title: 'Login Berhasil',
                                          message:
                                              'Selamat datang ${viewModel.currentUser?.name}',
                                          buttonText: 'Lanjutkan',
                                          onPressed: () {
                                            Navigator.pop(
                                                context); // Tutup dialog
                                            // Navigate to home screen
                                            Navigator.pushReplacementNamed(
                                                context, AppRoutes.home);
                                          },
                                        );
                                      }
                                    } else if (viewModel.errorMessage != null) {
                                      // Tampilkan error dialog jika ada error
                                      if (context.mounted) {
                                        DialogHelper.showErrorDialog(
                                          context: context,
                                          title: 'Login Gagal',
                                          message: viewModel.errorMessage!,
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF132054),
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
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
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
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {},
                              fillColor: WidgetStateProperty.all(Colors.white),
                            ),
                            const Text(
                              'Lupa kata sandi ?',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Setel Ulang',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum memiliki akun? Silahkan',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.register);
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                              ),
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Perbarui bagian ini di LoginScreen
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'atau lanjutkan dengan',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () async {
                                // Panggil Google Sign In
                                final result =
                                    await viewModel.signInWithGoogle();

                                if (result['success']) {
                                  if (result['isNewUser']) {
                                    // User baru perlu melengkapi profile
                                    if (context.mounted) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.completeProfile,
                                        arguments: result['userData'],
                                      );
                                    }
                                  } else {
                                    // User sudah ada, tampilkan success dialog
                                    if (context.mounted) {
                                      DialogHelper.showSuccessDialog(
                                        context: context,
                                        title: 'Login Berhasil',
                                        message: 'Selamat datang!',
                                        buttonText: 'Lanjutkan',
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Tutup dialog
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.home,
                                          );
                                        },
                                      );
                                    }
                                  }
                                } else {
                                  // Tampilkan error jika gagal
                                  if (context.mounted) {
                                    DialogHelper.showErrorDialog(
                                      context: context,
                                      title: 'Login Gagal',
                                      message: result['error'],
                                    );
                                  }
                                }
                              },
                              child: Image.asset(
                                'assets/icons/google_icon.png',
                                height: 24,
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
          );
        },
      ),
    );
  }
}
