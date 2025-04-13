import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../viewsModels/auth/register_viewmodel.dart';

class EmailVerificationScreen extends StatelessWidget {
  final Function onVerificationComplete;
  final Function onCancel;

  const EmailVerificationScreen({
    Key? key,
    required this.onVerificationComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async {
        // Konfirmasi sebelum kembali
        return _showCancelConfirmationDialog(context, viewModel);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Email'),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _showCancelConfirmationDialog(context, viewModel).then((cancel) {
                if (cancel) {
                  onCancel();
                }
              });
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Icon dan status
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    viewModel.isEmailVerified
                        ? Icons.check_circle
                        : Icons.email_outlined,
                    size: 60,
                    color: viewModel.isEmailVerified
                        ? Colors.green
                        : viewModel.isVerificationTimedOut
                            ? Colors.red
                            : primaryColor,
                  ),
                ),

                const SizedBox(height: 30),

                // Judul
                Text(
                  viewModel.isEmailVerified
                      ? 'Email Berhasil Diverifikasi!'
                      : viewModel.isVerificationTimedOut
                          ? 'Waktu Verifikasi Habis'
                          : 'Verifikasi Email Anda',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Pesan
                Text(
                  viewModel.isEmailVerified
                      ? 'Terima kasih telah memverifikasi email Anda. Silakan lanjutkan untuk melengkapi pendaftaran.'
                      : viewModel.isVerificationTimedOut
                          ? 'Waktu verifikasi telah habis. Silakan coba lagi untuk mendaftar.'
                          : 'Kami telah mengirimkan email verifikasi ke ${viewModel.currentUser?.email ?? "email Anda"}. Silakan periksa kotak masuk Anda dan klik tautan verifikasi untuk melanjutkan pendaftaran.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Countdown timer
                if (!viewModel.isEmailVerified &&
                    !viewModel.isVerificationTimedOut)
                  Column(
                    children: [
                      const Text(
                        'Waktu Tersisa:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          viewModel.countdownText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: viewModel.remainingSeconds < 60
                                ? Colors.red
                                : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tidak menerima email?',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.resendVerificationEmail(),
                        child: Text(
                          'Kirim Ulang Email Verifikasi',
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                const Spacer(),

                // Button
                if (viewModel.isEmailVerified)
                  ElevatedButton(
                    onPressed: () => onVerificationComplete(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                else if (viewModel.isVerificationTimedOut)
                  ElevatedButton(
                    onPressed: () => onCancel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final isVerified = await viewModel
                                    .checkEmailVerificationStatus();
                                if (isVerified) {
                                  onVerificationComplete();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Email belum diverifikasi. Silakan periksa email Anda dan klik tautan verifikasi.'),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          viewModel.isLoading ? 'Memuat...' : 'Refresh Status',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            _showCancelConfirmationDialog(context, viewModel)
                                .then((cancel) {
                          if (cancel) {
                            onCancel();
                          }
                        }),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Batalkan Registrasi',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showCancelConfirmationDialog(
      BuildContext context, RegisterViewModel viewModel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Registrasi?'),
        content: const Text(
            'Jika Anda membatalkan registrasi, seluruh proses akan dibatalkan dan Anda perlu memulai dari awal lagi. Yakin ingin membatalkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              viewModel.cancelRegistration();
              Navigator.of(context).pop(true);
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
