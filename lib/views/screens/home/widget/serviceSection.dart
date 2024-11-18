import 'package:flutter/material.dart';

class ServiceGridSection extends StatelessWidget {
  const ServiceGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.chat, 'label': 'KONSELING'},
      {'icon': Icons.favorite, 'label': 'DIAKONIA'},
      {'icon': Icons.play_circle, 'label': 'MULTIMEDIA'},
      {'icon': Icons.music_note, 'label': 'MUSIK'},
      {'icon': Icons.people, 'label': 'PEMURIDAN'},
      {'icon': Icons.water, 'label': 'KRISTEN BARU'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'PELAYANAN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Column(
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
                  const SizedBox(height: 4),
                  Text(
                    services[index]['label'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
