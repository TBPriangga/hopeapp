import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import '../../../models/discipleship/discipleship_model.dart';

class DiscipleshipClassScreen extends StatefulWidget {
  const DiscipleshipClassScreen({super.key});

  @override
  State<DiscipleshipClassScreen> createState() =>
      _DiscipleshipClassScreenState();
}

class _DiscipleshipClassScreenState extends State<DiscipleshipClassScreen> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Semua',
    'Anak',
    'Remaja-Pemuda',
    'Dewasa Muda',
    'Dewasa Senior',
  ];

  final List<DiscipleshipClassModel> _classes = [
    DiscipleshipClassModel(
      id: '1',
      name: 'Batita',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia di bawah 3 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Bu Vero dan Bu Lia',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2F1000346694%20-%20Sutiyani%20dwipras.jpg?alt=media&token=6cb6549c-3daf-47fc-89b0-46116efd1e34',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '2',
      name: 'Indria',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 3-5 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Bu Puji, Bu Yani, Bu Erna',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FIMG_1941%20-%20maria%20febriyanti.jpeg?alt=media&token=a33c1dbc-f7e2-4e72-a11b-b6c9df35665c',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '3',
      name: 'Pratama A',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 6-7 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Sdri. Ebi dan Bu Vitri',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2F20241208_233117%20-%20Ary%20Koes%20Herna%20Ningsih.jpg?alt=media&token=3978ff63-6c53-4393-8cd2-fe5e53c2b9c5',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '4',
      name: 'Pratama B',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 8-9 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Bu Ari dan Bu Arwhien',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-12%20at%2009.05.45.jpeg?alt=media&token=e2681827-4566-413c-b989-27f0b1059f75',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '5',
      name: 'Madya',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 10-11 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Bu Ira dan Bu Dini',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '6',
      name: 'Golgota',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putra dan putri usia SMP',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Amel',
      classPhotoUrl: 'https://example.com/photos/mentor2.jpg',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '7',
      name: 'Yordan',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putra berusia SMA',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Feri',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-15%20at%2019.09.34.jpeg?alt=media&token=70ff2e5a-34d5-4a22-ba97-debd7e15fa7b',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '8',
      name: 'Getsemani',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putra berusia SMA',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Adhit',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-15%20at%2019.09.34.jpeg?alt=media&token=70ff2e5a-34d5-4a22-ba97-debd7e15fa7b',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '9',
      name: 'Yerusalem',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putri usia SMP-SMA',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Sdri. Vinni',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-15%20at%2012.33.47.jpeg?alt=media&token=39d3c755-887e-4d05-9b38-9965d416f15d',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '10',
      name: 'Betlehem',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemudi usia kuliah dan bekerja',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Ayu',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FBC54D1CC-BA16-4F2E-BF81-56A0B8943109%20-%20Ayu%20Wahyuningsih.jpeg?alt=media&token=1da5d2bb-072c-451f-b6cc-452933e47db5',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '11',
      name: 'Roma',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemuda usia kuliah dan bekerja',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Made',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2F2bcbd369-6563-438f-b602-527735f58c84%20-%20Made%20Djati.jpeg?alt=media&token=5f91e0ca-4c92-414c-aa3f-3cf340562850',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '12',
      name: 'Karmel',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemuda usia kuliah dan bekerja',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Yosua',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2F20240121_105738%20-%20Yosua%20Eka%20Timesa.jpg?alt=media&token=40b7f624-df89-469f-aa71-c6c9577f678a',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '13',
      name: 'Kalvari',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemudi usia kuliah dan bekerja',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Grace',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-12%20at%2009.53.49.jpeg?alt=media&token=3d8ff2c1-62b6-417b-ab7a-cd31a8d2ac1e',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '14',
      name: 'En Gedi',
      category: 'Remaja-Pemuda',
      description:
          'Kelas ini beranggotakan pemuda, pemudi usia bekerja dan dewasa muda',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Ony',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FIMG-20230408-WA0011%20-%20Ony%20Wahyudiantaro.jpg?alt=media&token=0cad4b81-0078-44ea-9d16-b93f1c4742e2',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '15',
      name: 'Israel',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Sdr. Opi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FIMG-20240623-WA0003%20-%20Tri%20Cahyo%20Novianto.jpg?alt=media&token=10927afa-fbc6-45d5-89a9-89e299f2cdfc',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '16',
      name: 'Henokh',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Gad Eko',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FIMG-20240623-WA0003%20-%20Tri%20Cahyo%20Novianto.jpg?alt=media&token=10927afa-fbc6-45d5-89a9-89e299f2cdfc',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '17',
      name: 'Noah',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Nana',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FScreenshot%20(978)%20-%20Indriana%20Parwitasari.png?alt=media&token=375397c1-f112-417a-90ac-9d88ed085722',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '18',
      name: 'Debora',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Nine',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '19',
      name: 'Samuel',
      category: 'Dewasa Muda',
      description: 'Kelas ini beranggotakan pria dari usia dewasa muda ',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Ika',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FIMG-20221211-WA0005%20-%20Ary%20Koes%20Herna%20Ningsih.jpg?alt=media&token=d1730dad-ed72-448a-a0df-33cf3f1b3b55',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '20',
      name: 'Yesua',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Budi',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '21',
      name: 'El-Shaddai',
      category: 'Dewasa Muda',
      description: 'Kelas ini beranggotakan wanita dari usia dewasa muda ',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Lita',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Remaja',
    ),
    DiscipleshipClassModel(
      id: '22',
      name: 'Kasih',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan wanita dari usia dewasa senior',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Indah Suparman',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-14%20at%2005.43.09.jpeg?alt=media&token=0016535e-83ef-4012-8b95-4a511e6629dd',
      location: 'Dewasa Senior',
    ),
    DiscipleshipClassModel(
      id: '23',
      name: 'Sukacita',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan wanita dari usia dewasa senior',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bu Sutiyah & Bu Dewi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-12%20at%2008.44.50.jpeg?alt=media&token=83ce1ac5-a6a1-45c5-86cb-822714810d8f',
      location: 'Dewasa Senior',
    ),
    DiscipleshipClassModel(
      id: '24',
      name: 'Setia',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan pria dari usia dewasa senior',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Edi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-12%20at%2010.02.22.jpeg?alt=media&token=a1821519-634e-4920-aab7-c995fc25020e',
      location: 'Dewasa Senior',
    ),
    DiscipleshipClassModel(
      id: '25',
      name: 'Sabar',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan pria dari usia dewasa senior',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Bp. Edi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2FWhatsApp%20Image%202024-12-12%20at%2010.02.22.jpeg?alt=media&token=a1821519-634e-4920-aab7-c995fc25020e',
      location: '',
    ),
  ];

  List<DiscipleshipClassModel> get filteredClasses {
    if (_selectedCategory == null || _selectedCategory == 'Semua') {
      return _classes;
    }
    return _classes.where((c) => c.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Kelas Pemuridan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Category Filter
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory ||
                        (category == 'Semua' && _selectedCategory == null);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        backgroundColor: Colors.black.withOpacity(0.1),
                        selectedColor: Colors.white,
                        checkmarkColor: const Color(0xFF132054),
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF132054)
                                : Colors.white,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              // Class List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredClasses.length,
                  itemBuilder: (context, index) {
                    final classData = filteredClasses[index];
                    return _buildClassCard(classData);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(DiscipleshipClassModel classData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Class Photo Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                classData.classPhotoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF132054),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.group_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          // Content Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: classData.categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            classData.categoryIcon,
                            size: 16,
                            color: classData.categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            classData.category,
                            style: TextStyle(
                              color: classData.categoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  classData.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132054),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  classData.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Info Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.person,
                        'Pembimbing',
                        classData.mentor,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        Icons.schedule,
                        'Jadwal',
                        classData.schedule,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        Icons.location_on,
                        'Lokasi',
                        classData.location,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF132054),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
