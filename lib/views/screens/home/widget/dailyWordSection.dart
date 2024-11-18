import 'package:flutter/material.dart';

class DailyWordSection extends StatelessWidget {
  const DailyWordSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'ROTI HIDUP',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ajarlah kami menghitung hari-hari kami sedemikian, hingga kami beroleh hati yang bijaksana. - Mazmur 90:12',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
