import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';

class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({super.key});

  void _handleServiceTap(BuildContext context, String serviceType) {
    switch (serviceType) {
      case 'KRISTEN BARU':
        Navigator.pushNamed(context, AppRoutes.baptismRegistration);
        break;
      case 'PRANIKAH':
        Navigator.pushNamed(context, AppRoutes.weddingRegistration);
        break;
      case 'PERSEMBAHAN':
        Navigator.pushNamed(context, AppRoutes.offeringInfo);
        break;
      case 'KONSELING':
        Navigator.pushNamed(context, AppRoutes.counseling);
        break;
      case 'MULTIMEDIA':
        Navigator.pushNamed(context, AppRoutes.youtube);
        break;
      case 'PEMURIDAN':
        Navigator.pushNamed(context, AppRoutes.discipleship);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        'icon': Icons.chat,
        'label': 'KONSELING',
        'description': 'Layanan Konseling'
      },
      {
        'icon': Icons.attach_money,
        'label': 'PERSEMBAHAN',
        'description': 'Informasi Persembahan'
      },
      {
        'icon': Icons.play_circle,
        'label': 'MULTIMEDIA',
        'description': 'Pelayanan Media'
      },
      {
        'icon': Icons.favorite_border,
        'label': 'PRANIKAH',
        'description': 'Pemberkatan Nikah'
      },
      {
        'icon': Icons.people,
        'label': 'PEMURIDAN',
        'description': 'Program Pemuridan'
      },
      {
        'icon': Icons.water,
        'label': 'KRISTEN BARU',
        'description': 'Pendaftaran Baptis'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () =>
                    _handleServiceTap(context, services[index]['label']),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF132054),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          services[index]['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        services[index]['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          services[index]['description'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
