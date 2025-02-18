import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../widgets/customBottomNav.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.dailyWordList);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.about);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> formMenus = [
      {
        'icon': Icons.chat,
        'label': 'KONSELING',
        'description': 'Layanan Konseling',
        'route': AppRoutes.counseling,
      },
      {
        'icon': Icons.attach_money,
        'label': 'PERSEMBAHAN',
        'description': 'Informasi Persembahan',
        'route': AppRoutes.offeringInfo,
      },
      {
        'icon': Icons.favorite_border,
        'label': 'PRANIKAH',
        'description': 'Pemberkatan Nikah',
        'route': AppRoutes.weddingRegistration,
      },
      {
        'icon': Icons.school,
        'label': 'KELAS PEMURIDAN',
        'description': 'Program Kelas Pemuridan',
        'route': AppRoutes.discipleshipClass,
      },
      {
        'icon': Icons.water,
        'label': 'KRISTEN BARU',
        'description': 'Pendaftaran Keanggotaan/Baptisan',
        'route': AppRoutes.baptismRegistration,
      },
      {
        'icon': Icons.child_care,
        'label': 'PENYERAHAN ANAK',
        'description': 'Pendaftaran Penyerahan Anak',
        'route': AppRoutes.childDedication,
      },
    ];

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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: formMenus.length,
                  itemBuilder: (context, index) {
                    final menu = formMenus[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, menu['route'] ?? '');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF132054),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                menu['icon'],
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              menu['label'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                menu['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}
