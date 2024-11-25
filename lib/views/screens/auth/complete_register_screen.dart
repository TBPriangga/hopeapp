import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewsModels/auth/register_complete.dart';
import '../../widgets/customTextField.dart';
import '../../widgets/customDateField.dart';

class CompleteProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const CompleteProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompleteProfileViewModel(userData),
      child: Consumer<CompleteProfileViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFF3949AB),
              elevation: 0,
              title: const Text(
                'Lengkapi Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              image: userData['photoUrl'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(userData['photoUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: userData['photoUrl'] == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Color(0xFF3949AB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    if (viewModel.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Pre-filled fields (dari Google)
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.emailController,
                      enabled: false,
                      hintText: 'Email',
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Nama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.nameController,
                      enabled: false,
                      hintText: 'Nama',
                    ),
                    const SizedBox(height: 16),

                    // Required additional info
                    const Text(
                      'Alamat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.addressController,
                      hintText: 'Masukkan alamat lengkap anda',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tanggal Lahir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomDateField(
                      controller: viewModel.birthDateController,
                      onDateSelected: viewModel.updateBirthDate,
                      hintText: 'Pilih tanggal lahir',
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: viewModel.phoneController,
                      hintText: 'Masukkan nomor telepon aktif',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                if (await viewModel.completeProfile()) {
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3949AB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan & Lanjutkan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
