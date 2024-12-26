// birthday_verse.dart
import 'dart:math';

class BirthdayVerse {
  final String reference;
  final String content;

  BirthdayVerse({
    required this.reference,
    required this.content,
  });
}

class BirthdayVerseHelper {
  static final List<BirthdayVerse> _verses = [
    BirthdayVerse(
      reference: "Amsal 3:16",
      content:
          "Karena oleh aku umurmu diperpanjang, dan tahun-tahun hidupmu ditambah.",
    ),
    BirthdayVerse(
      reference: "Amsal 9:11",
      content:
          "Karena oleh aku umurmu diperpanjang, dan tahun-tahun hidupmu ditambah.",
    ),
    BirthdayVerse(
      reference: "Mazmur 145:17",
      content:
          "Tuhan itu adil dalam segala hal jalanNya dan penuh kasih serta setia dalam segala perbuatanNya.",
    ),
    BirthdayVerse(
      reference: "Yeremia 17:7",
      content:
          "Diberkatilah orang yang mengandalkan Tuhan, yang menaruh harapannya pada Tuhan!",
    ),
    BirthdayVerse(
      reference: "Yeremia 29:11",
      content:
          "Sebab Aku ini mengetahui rancangan-rancangan apa yang ada padaKu mengenai kamu, demikianlah firman Tuhan, yaitu rancangan damai sejahtera dan bukan rancangan kecelakaan, untuk memberikan kepadamu hari depan yang penuh harapan.",
    ),
    BirthdayVerse(
      reference: "Pengkotbah 11:8",
      content:
          "Oleh sebab itu jikalau orang panjang umurnya, biarlah ia bersukacita di dalamnya, tetapi hendaklah ia ingat akan hari-hari yang gelap, karena banyak jumlahnya. Segala sesuatu yang datang adalah kesia-siaan.",
    ),
    BirthdayVerse(
      reference: "Yakobus 1:17",
      content:
          "Setiap pemberian yang baik dan setiap anugerah yang sempurna, datangnya dari atas, diturunkan dari Bapa segala terang; padaNya tidak ada perubahan atau bayangan karena pertukaran.",
    ),
    BirthdayVerse(
      reference: "Efesus 2:10",
      content:
          "Karena kita ini buatan Allah, diciptakan dalam Kristus Yesus untuk melakukan pekerjaan baik, yang dipersiapkan Allah sebelumnya. Ia mau, supaya kita hidup di dalamnya.",
    ),
    BirthdayVerse(
      reference: "Roma 15:13",
      content:
          "Semoga Allah, sumber pengharapan, memenuhi kamu dengan segala sukacita dan damai sejahtera dalam iman kamu, supaya oleh kekuatan Roh Kudus kamu berlimpah-limpah dalam pengharapan.",
    ),
    BirthdayVerse(
      reference: "Roma 5:5",
      content:
          "Dan pengharapan tidak mengecewakan, karena kasih Allah telah dicurahkan di dalam hari kita oleh Roh Kudus yang telah dikaruniakan kepada kita.",
    ),
  ];

  static BirthdayVerse getRandomVerse() {
    final random = Random();
    return _verses[random.nextInt(_verses.length)];
  }
}
