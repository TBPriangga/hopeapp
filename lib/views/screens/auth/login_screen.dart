import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../viewsModels/auth/login_viewmodel.dart';
import '../../widgets/customTextField.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

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
                      const Color(0xFF2B478A).withOpacity(0.8),
                      const Color(0xFF132054).withOpacity(0.8),
                    ],
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo Section
                            SizedBox(height: size.height * 0.01),
                            Center(
                              child: Image.asset(
                                'assets/logo/hope_logo_old.png',
                                height: size.height * 0.20,
                              ),
                            ),

                            // Title Section
                            const Center(
                              child: Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Masuk ke akun Anda',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.04),

                            // Error Message
                            if (viewModel.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
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
                            ],

                            // Login Form
                            CustomTextField(
                              label: 'Email',
                              hintText: 'Cth : johndoe@gmail.com',
                              controller: viewModel.emailController,
                              prefixIcon: const Icon(Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Kata Sandi',
                              hintText: '••••••••••',
                              isPassword: true,
                              controller: viewModel.passwordController,
                              prefixIcon: const Icon(Icons.lock_outlined),
                            ),
                            const SizedBox(height: 8),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.forgotPassword);
                                },
                                child: const Text(
                                  'Lupa kata sandi?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            ElevatedButton(
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
                                              Navigator.pop(context);
                                              Navigator.pushReplacementNamed(
                                                  context, AppRoutes.home);
                                            },
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF132054),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF132054),
                                      ),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Belum memiliki akun? ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.register);
                                  },
                                  child: const Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
