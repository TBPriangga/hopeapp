import 'package:flutter/material.dart';

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
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '2',
      name: 'Indria',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 3-5 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Bu Puji, Bu Yani, Bu Erna',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '3',
      name: 'Pratama A',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 6-7 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Sdri. Ebi dan Bu Vitri',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '4',
      name: 'Pratama B',
      category: 'Anak',
      description: 'Kelas ini beranggotakan anak berusia 8-9 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Bu Ari dan Bu Arwhien',
      classPhotoUrl: 'https://example.com/photos/mentor1.jpg',
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
