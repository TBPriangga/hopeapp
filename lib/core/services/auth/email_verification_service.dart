import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailVerificationService {
  // Metode untuk verifikasi email menggunakan regex dasar
  // Ini hanya validasi format email, bukan keberadaan sebenarnya
  static bool isValidEmailFormat(String email) {
    // Regex untuk format email dasar
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // Metode untuk validasi domain email dengan cek MX record
  // Ini bisa dilakukan dengan API
  static Future<bool> validateEmailDomain(String email) async {
    try {
      // Ekstrak domain dari email
      final domain = email.split('@').last;

      // Menggunakan API publik untuk memeriksa MX record domain
      // Catatan: Ini adalah contoh, API mungkin memerlukan key atau memiliki batasan
      final response = await http
          .get(
            Uri.parse('https://dns-api.org/MX/$domain'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Jika MX record ditemukan, domain email valid
        return data.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error validating email domain: $e');
      // Jika gagal, anggap saja valid (pendekatan yang lebih permisif)
      return true;
    }
  }

  // Metode gabungan untuk validasi email yang lebih baik tanpa API eksternal
  static Future<Map<String, dynamic>> validateEmail(String email) async {
    // Step 1: Validasi format
    if (!isValidEmailFormat(email)) {
      return {
        'isValid': false,
        'message': 'Format email tidak valid',
      };
    }

    // Step 2: Validasi domain
    try {
      bool isDomainValid = await validateEmailDomain(email);
      if (!isDomainValid) {
        return {
          'isValid': false,
          'message': 'Domain email tidak valid atau tidak dapat menerima email',
        };
      }
    } catch (e) {
      // Jika ada error, lanjutkan saja dan anggap valid
      print('Error in domain validation: $e');
    }

    // Tambahan: Validasi sederhana untuk domain lazim
    final domain = email.split('@').last.toLowerCase();
    if (domain.contains('example.com') || domain.contains('test.com')) {
      return {
        'isValid': false,
        'message': 'Email menggunakan domain contoh yang tidak valid',
      };
    }

    // Validasi tambahan untuk email temporer
    List<String> tempDomains = [
      'mailinator.com',
      'tempmail.com',
      'temp-mail.org',
      'fakeinbox.com',
      'guerrillamail.com',
      'yopmail.com',
      'sharklasers.com',
      'mailnesia.com',
      '10minutemail.com'
    ];

    if (tempDomains.any((d) => domain.contains(d))) {
      return {
        'isValid': false,
        'message': 'Alamat email temporer tidak diperbolehkan',
      };
    }

    // Jika semua validasi lolos
    return {
      'isValid': true,
      'message': 'Email valid',
    };
  }
}
