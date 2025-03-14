import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CounselingScreen extends StatelessWidget {
  const CounselingScreen({super.key});

  Future<void> _launchWhatsApp() async {
    // Ganti dengan nomor WhatsApp pendeta
    final Uri whatsapp = Uri.parse(
        'https://wa.me/6281233415132?text=Shalom%20Pendeta%2C%20saya%20ingin%20konseling');
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF132054),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konseling',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF132054),
                image: DecorationImage(
                  image: const AssetImage('assets/images/counseling.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Konseling',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bible Verse Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: Color(0xFF132054),
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"Sebab Aku ini mengetahui rancangan-rancangan apa yang ada pada-Ku mengenai kamu, demikianlah firman TUHAN, yaitu rancangan damai sejahtera dan bukan rancangan kecelakaan, untuk memberikan kepadamu hari depan yang penuh harapan."',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Yeremia 29:11',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Available Times Section
                  Text(
                    'Jadwal Konseling',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildScheduleItem(
                          day: 'Selasa',
                          time: '18:00 WIB',
                        ),
                        const Divider(height: 24),
                        _buildScheduleItem(
                          day: 'Sabtu',
                          time: '16:00 WIB',
                        ),
                        const Divider(height: 24),
                        _buildScheduleItem(
                          day: 'Sesuai Perjanjian',
                          time: '',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // WhatsApp Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _launchWhatsApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF25D366), // WhatsApp green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            'Hubungi Pendeta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pastikan untuk membuat janji terlebih dahulu sebelum bertemu dengan pendeta.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required String day,
    required String time,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
