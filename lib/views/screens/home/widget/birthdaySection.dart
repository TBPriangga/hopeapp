import 'package:flutter/material.dart';

class BirthdaySection extends StatelessWidget {
  const BirthdaySection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> birthdayPeople = [
      {'name': 'Callie', 'image': 'assets/images/callie.png'},
      {'name': 'Ella', 'image': 'assets/images/ella.png'},
      {'name': 'Gracia', 'image': 'assets/images/gracia.png'},
      {'name': 'Celine', 'image': 'assets/images/celine.png'},
      {'name': 'Dey', 'image': 'assets/images/dhea.png'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Jemaat Yang Berulang Tahun Minggu Ini :',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: birthdayPeople.map((person) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(person['image']!),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person['name']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
