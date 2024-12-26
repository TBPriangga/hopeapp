import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WeddingRegistrationScreen extends StatelessWidget {
  const WeddingRegistrationScreen({super.key});

  Future<void> _launchGoogleForm() async {
    final Uri url = Uri.parse('https://forms.gle/your-google-form-link');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
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
          'Pemberkatan Nikah',
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
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF132054),
                image: DecorationImage(
                  image: const AssetImage('assets/images/wedding.jpg'),
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
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Pendaftaran Pernikahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bible Verse
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
                          '"Demikianlah mereka bukan lagi dua, melainkan satu. Karena itu, apa yang telah dipersatukan Allah, tidak boleh diceraikan manusia."',
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
                          'Matius 19:6',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description Section

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      'Pernikahan adalah sebuah Lembaga pertama yang didirikan oleh Allah sendiri sejak pada mulanya. Pernikahan membawa manusia dapat semakin melayani dan memuliakan Allah melalui relasi penuh kasih, penuh hormat, serta penuh keintiman seksual di antara laki-laki dan Perempuan. Itu sebanya, bagi Anda yang rindu untuk menikah, maka Anda dapat menghubungi Panitia Keanggotaan (Bu Lita - +62 813-3905-1349)',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Registration Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _launchGoogleForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF132054),
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
                          Icon(Icons.app_registration),
                          SizedBox(width: 8),
                          Text(
                            'Daftar Pernikahan',
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
                            'Pendaftaran harus dilakukan minimal 3 bulan sebelum tanggal pernikahan yang direncanakan.',
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
}
