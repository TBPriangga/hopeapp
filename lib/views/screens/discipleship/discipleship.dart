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
      mentor: 'Bu Vero dan Bu Lia',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FBatita.jpeg?alt=media&token=41fa83ff-cc1e-4dc9-93b9-05f0e3f77525',
    ),
    DiscipleshipClassModel(
      id: '2',
      name: 'Indria',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 3-5 tahun',
      mentor: 'Bu Puji, Bu Yani, Bu Erna',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FIndria.jpg?alt=media&token=3c25feeb-e572-4a6b-97c5-dafa191d4a55',
    ),
    DiscipleshipClassModel(
      id: '3',
      name: 'Pratama A',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 6-7 tahun',
      mentor: 'Sdri. Ebi dan Bu Vitri',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FPratama%20A.jpeg?alt=media&token=f2af7f7f-5c8d-403e-8888-7e93327d1031',
    ),
    DiscipleshipClassModel(
      id: '4',
      name: 'Pratama B',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 8-9 tahun',
      mentor: 'Bu Ari dan Bu Arwhien',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FPratama%20B_Betul.jpeg?alt=media&token=e04a0199-c4e9-4f89-83c9-c128230d2ef8',
    ),
    DiscipleshipClassModel(
      id: '5',
      name: 'Madya',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 10-11 tahun',
      mentor: 'Bu Ira dan Bu Dini',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fmadya.jpeg?alt=media&token=31aebf30-fd6b-43f4-bb9a-4f1c9e5f0e13',
    ),
    DiscipleshipClassModel(
      id: '6',
      name: 'Golgota',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putra dan putri usia SMP',
      mentor: 'Bu Amel',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FGolgota%20Betul.jpeg?alt=media&token=98e43b94-8380-4dff-a35a-e5e83f1bc42e',
    ),
    DiscipleshipClassModel(
      id: '7',
      name: 'Yordan',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putra berusia SMA',
      mentor: 'Bp. Feri',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fyordan%20dan%20getsemani.jpeg?alt=media&token=a02da843-d866-437d-97f2-87f3429f9e2c',
    ),
    DiscipleshipClassModel(
      id: '8',
      name: 'Getsemani',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putra berusia SMA',
      mentor: 'Bp. Adhit',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fyordan%20dan%20getsemani.jpeg?alt=media&token=a02da843-d866-437d-97f2-87f3429f9e2c',
    ),
    DiscipleshipClassModel(
      id: '9',
      name: 'Yerusalem',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan remaja putri usia SMP-SMA',
      mentor: 'Sdri. Vinni',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fyerusalem.jpeg?alt=media&token=cb1d5762-22ef-4204-8fca-b1901503e5e5',
    ),
    DiscipleshipClassModel(
      id: '10',
      name: 'Betlehem',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemudi usia kuliah dan bekerja',
      mentor: 'Bu Ayu',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FBetlehem%20Betul.jpeg?alt=media&token=ef92ea17-678e-4c0b-905d-fa89c78cc0b1',
    ),
    DiscipleshipClassModel(
      id: '11',
      name: 'Roma',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemuda usia kuliah dan bekerja',
      mentor: 'Bp. Made',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Froma.jpeg?alt=media&token=b23e9f35-7032-49ea-853c-ac725cf443ee',
    ),
    DiscipleshipClassModel(
      id: '12',
      name: 'Karmel',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemuda usia kuliah dan bekerja',
      mentor: 'Bp. Yosua',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2F20240121_105738%20-%20Yosua%20Eka%20Timesa.jpg?alt=media&token=40b7f624-df89-469f-aa71-c6c9577f678a',
    ),
    DiscipleshipClassModel(
      id: '13',
      name: 'Kalvari',
      category: 'Remaja-Pemuda',
      description: 'Kelas ini beranggotakan pemudi usia kuliah dan bekerja',
      mentor: 'Bu Grace',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fkalvari.jpg?alt=media&token=334f63fe-6ffa-4d47-94b6-f3bbbdbacb5f',
    ),
    DiscipleshipClassModel(
      id: '14',
      name: 'En Gedi',
      category: 'Remaja-Pemuda',
      description:
          'Kelas ini beranggotakan pemuda, pemudi usia bekerja dan dewasa muda',
      mentor: 'Bp. Ony',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FEn%20Gedi.jpg?alt=media&token=1b47bbde-5d9a-4f56-b92f-f319af0bc261',
    ),
    DiscipleshipClassModel(
      id: '15',
      name: 'Israel',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      mentor: 'Sdr. Opi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FIsrael.jpg?alt=media&token=23680019-9fdc-454d-8354-45db1b54b15d',
    ),
    DiscipleshipClassModel(
      id: '16',
      name: 'Henokh',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      mentor: 'Bp. Gad Eko',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FHenokh.jpg?alt=media&token=c9821290-05ef-4385-b931-238cb0eaedb3',
    ),
    DiscipleshipClassModel(
      id: '17',
      name: 'Noah',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      mentor: 'Bu Nana',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FNoah%20Betul.jpeg?alt=media&token=b9be95c1-3026-484c-8804-2d7d0dc2d118',
    ),
    DiscipleshipClassModel(
      id: '18',
      name: 'Debora',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      mentor: 'Bu Nine',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FDebora%20Betul.jpeg?alt=media&token=7aa4df0f-66f6-45d4-8da2-e5140126f2c5',
    ),
    DiscipleshipClassModel(
      id: '19',
      name: 'Samuel',
      category: 'Dewasa Muda',
      description: 'Kelas ini beranggotakan pria dari usia dewasa muda ',
      mentor: 'Bp. Ika',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fsamuel.jpg?alt=media&token=586ae476-1e0f-47fa-a020-52bcc0b7dfa0',
    ),
    DiscipleshipClassModel(
      id: '20',
      name: 'Yesua',
      category: 'Dewasa Muda',
      description:
          'Kelas ini beranggotakan pria dan wanita dari usia dewasa muda',
      mentor: 'Bp. Budi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FYesua%20Betul.jpeg?alt=media&token=d1dc4b61-964c-4263-9278-ac0a35a9542f',
    ),
    DiscipleshipClassModel(
      id: '21',
      name: 'El-Shaddai',
      category: 'Dewasa Muda',
      description: 'Kelas ini beranggotakan wanita dari usia dewasa muda ',
      mentor: 'Bu Lita',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FEl%20Shadai.jpeg?alt=media&token=4d34b9df-f60c-424b-a5b5-64973bf01a7b',
    ),
    DiscipleshipClassModel(
      id: '22',
      name: 'Kasih',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan wanita dari usia dewasa senior',
      mentor: 'Bu Indah Suparman',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fkasih.jpeg?alt=media&token=c23e2f77-9b44-4c9b-bd92-bdd05775f83a',
    ),
    DiscipleshipClassModel(
      id: '23',
      name: 'Sukacita',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan wanita dari usia dewasa senior',
      mentor: 'Bu Sutiyah & Bu Dewi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2Fsukacita.jpeg?alt=media&token=2c079ef9-da5c-4ccf-b87a-e6cb05538e2d',
    ),
    DiscipleshipClassModel(
      id: '24',
      name: 'Setia',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan pria dari usia dewasa senior',
      mentor: 'Bp. Edi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FSetia%20Betul%20B.jpeg?alt=media&token=c931fe1b-2c7d-420f-91da-32246ff2347e',
    ),
    DiscipleshipClassModel(
      id: '25',
      name: 'Sabar',
      category: 'Dewasa Senior',
      description: 'Kelas ini beranggotakan pria dari usia dewasa senior',
      mentor: 'Bp. Edi',
      classPhotoUrl:
          'https://firebasestorage.googleapis.com/v0/b/hopeapp-513f1.firebasestorage.app/o/image_class%2Fclassupdate%2FSetia%20Betul%20B.jpeg?alt=media&token=c931fe1b-2c7d-420f-91da-32246ff2347e',
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
                        backgroundColor: Colors.black.withOpacity(0.3),
                        selectedColor: Colors.white,
                        checkmarkColor: const Color(0xFF132054),
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF132054)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
                  child: _buildInfoRow(
                    Icons.person,
                    'Pembimbing',
                    classData.mentor,
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
